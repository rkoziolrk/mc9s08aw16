/*
 * lin_core.c - LIN transport core for the MC9S08AW16 MFL module: the LIN
 *              critical section, the scheduled-response timer, the frame-
 *              handler plumbing, the node state/reset, and the ISO-TP
 *              (diagnostic) receive/transmit state machines.
 *
 * This is the AW16 reconstruction of the transport layer the AW32 part keeps
 * in its lin_transport.c.  The functions here are driven from the SCI/LIN
 * byte engine (lin.c), the LIN application layer (lin_app.c) and the TPM2
 * tick ISR; they are faithful structural reconstructions of
 * reference/application.asm (the byte-level ISO-TP buffer arithmetic is
 * anchored with [0xXXXX] addresses, not claimed bit-exact).
 *
 * Shared RAM state (absolute addresses):
 *   [0x00B0] LIN critical-section nesting
 *   [0x00B8] ISO-TP sub-state     [0x00B9] ISO-TP busy flag
 *   [0x00C1..0x00C5] schedule / wake down-counters
 *   [0x01CB:0x01CC] scheduled-response delay (16-bit)
 *   [0x01CD:0x01CE] ISO-TP remaining length / block offset
 *   [0x01CF] consecutive-frame sequence number
 *   [0x01D0:0x01D1] receive/transmit buffer offset
 *   [0x01D2] NAD/service of the frame in progress
 *   [0x01D3] service result     [0x01D4] request-pending   [0x01D5] TP state
 *   [0x01D6:0x01D7] N_Cr timeout     [0x01D9] diagnostic mode
 *   [0x01E2] frame index     [0x01E3] wake reload     [0x01E4] 'S' sanity mark
 *   [0x01E9] node address (NAD)      [0x01EA] frame flags
 *   [0x01EB] length     [0x01EC] frame type    [0x01ED] PID   [0x01EE] prev PID
 *   [0x01EF] frame argument
 */
#include "app.h"

#define R8(a)      (*(volatile byte *)(a))
#define FLASH8(a)  (*(const volatile byte *)(a))
static word rd16(word a) { return (word)((R8(a) << 8) | R8(a + 1)); }
static void wr16(word a, word v) { R8(a) = (byte)(v >> 8); R8(a + 1) = (byte)v; }

/* leaf helpers reconstructed elsewhere / deepest transport leaves */
extern void Sci_Init(void);           /* [0xCF10] */
extern void Sci_SendByte(byte data);  /* [0xCF36] */
void Lin_SendWakeup(void);            /* [0xDE08] fwd */
extern void LinSci_RxOn(void);         /* [0xDDFE] */
extern void LinSci_RxOff(void);        /* [0xDE04] */
extern void LinErr_Set(byte code);     /* [0xCA41] */
void LinDiag_AutoConfig(void);         /* [0xCA87] diagnostic auto-config */
void LinApp_SendError(byte code);      /* [0xCA54] */
void Lin_SleepArm(void);               /* [0xCA6B] */
void Lin_SleepCheck(void);             /* [0xCA75] */
void LinNode_Rearm(void);              /* [0xDAB6] */
void LinNode_Wake(void);               /* [0xDAC5] */

/* ====================================================================== */
/* Critical section (SCI-interrupt masking)                                */
/* ====================================================================== */

/* [0xD16E]/[0xD175] save CCR with SEI / conditionally restore I bit */
/* (the exact CCR save/restore is modelled as a plain enter/leave here) */

/* ======================================================================
 * Lin_CritEnter  [0xD136]
 * Enter the LIN critical section: raise the nesting count [0x00B0] and mask
 * the SCI TX interrupt (SCI1C2 b5 = 0, SCI1C3 &= 0xF1) with interrupts
 * briefly disabled.
 * ====================================================================== */
void Lin_CritEnter(void)
{
    R8(0x00B0)++;
    EnterCritical();
    SCI1C2 &= (byte)~0x20;
    SCI1C3 &= 0xF1;
    ExitCritical();
}

/* ======================================================================
 * Lin_CritExit  [0xD14E]
 * Leave the LIN critical section: on the outermost level re-enable the SCI
 * TX/error interrupts (SCI1C2 b5 = 1, SCI1C3 |= 0x0E).
 * ====================================================================== */
void Lin_CritExit(void)
{
    if (R8(0x00B0) != 0) {
        R8(0x00B0)--;
    }
    if (R8(0x00B0) == 0) {
        EnterCritical();
        SCI1C2 |= 0x20;
        SCI1C3 |= 0x0E;
        ExitCritical();
    }
}

/* ====================================================================== */
/* Buffer helpers                                                          */
/* ====================================================================== */

/* ======================================================================
 * Buf_Copy  [0xE188]   (a.k.a. mem_copy)
 * Copy 'count' bytes from 'src' to 'dst' (used throughout the ISO-TP paths).
 * ====================================================================== */
void Buf_Copy(byte *dst, const byte *src, word count)
{
    while (count--) {
        *dst++ = *src++;
    }
}

/* ======================================================================
 * Buf_Fill  [0xE13A]
 * Fill 'count' bytes at 'dst' with 'value' (walking downward, as the asm).
 * ====================================================================== */
void Buf_Fill(byte *dst, byte value, word count)
{
    while (count--) {
        dst[count] = value;
    }
}

/* ======================================================================
 * Buf_Clear  [0xE15C]
 * Clear 'count' bytes at 'dst'.
 * ====================================================================== */
void Buf_Clear(byte *dst, word count)
{
    while (count--) {
        *dst++ = 0;
    }
}

/* ======================================================================
 * Buf_CopyIdx  [0xE1C6]
 * Indexed copy used to lay out the frame descriptor/signal tables: copy
 * 'count' bytes from (srcBase+off) to (dstBase+off).  Modelled as a plain
 * copy of the two base pointers.
 * ====================================================================== */
void Buf_CopyIdx(byte *dst, const byte *src, word count)
{
    Buf_Copy(dst, src, count);
}

/* ====================================================================== */
/* Scheduled-response timer                                                */
/* ====================================================================== */

/* ======================================================================
 * LinSched_Reset  [0xD17B]   (called from LinApp_Init)
 * Clear the scheduled-response state [0x01CB..0x01D5].
 * ====================================================================== */
void LinSched_Reset(void)
{
    R8(0x01D5) = 0; R8(0x01D4) = 0;
    R8(0x01D0) = 0; R8(0x01D1) = 0;
    R8(0x01CB) = 0; R8(0x01CC) = 0;
}

/* frame plumbing used by the schedule tick */
byte LinFrame_Done(void);          /* [0xE114] */
byte LinFrame_Abort(byte arg);     /* [0xE0EC] */
void LinSched_Arm(byte type, word len);   /* [0xD1C6] */

/* ======================================================================
 * LinSched_Tick  [0xD191]   (called from Lin_Housekeep)
 * Advance the scheduled-response delay [0x01CB]; when it expires, fire the
 * pending response (LinFrame_Done for [0x01D5], else LinFrame_Abort for
 * [0x01D4]).
 * ====================================================================== */
void LinSched_Tick(void)
{
    word t;
    Lin_CritEnter();                   /* [0xD136] */

    t = rd16(0x01CB);
    if (t != 0) {
        wr16(0x01CB, --t);
        if (t == 0) {
            if (R8(0x01D5) != 0) {
                R8(0x01D5) = 0; R8(0x01D4) = 0;
                LinFrame_Done();        /* [0xE114] */
            } else if (R8(0x01D4) != 0) {
                R8(0x01D5) = 0; R8(0x01D4) = 0;
                LinFrame_Abort(1);      /* [0xE0EC] */
            }
        }
    }
    Lin_CritExit();                    /* [0xD14E] */
}

/* ======================================================================
 * LinSched_Arm  [0xD1C6]
 * Arm a scheduled response in 100 ticks ([0x01CC]=0x64) carrying 'type'
 * [0x01D2 from 0x01E9] and 'len' [0x01CD]; returns busy if one is pending.
 * ====================================================================== */
void LinSched_Arm(byte type, word len)
{
    Lin_CritEnter();
    if (R8(0x01D5) == 0) {
        R8(0x01D5) = 0x03;
        R8(0x01CC) = 0x64;
        R8(0x01CB) = 0;
        wr16(0x01CD, len);
        R8(0x01D2) = R8(0x01E9);
        (void)type;
    }
    Lin_CritExit();
}

/* ======================================================================
 * LinSched_Busy  [0xD1FB]
 * Returns 1 while a request/response is in progress ([0x01D5] in {3,6}).
 * ====================================================================== */
byte LinSched_Busy(void)
{
    byte s = R8(0x01D5);
    return (s == 0x03 || s == 0x06) ? 1 : 0;
}

/* ======================================================================
 * LinSched_Abort  [0xD61D]
 * Abort an in-progress transfer, clearing the ISO-TP buffer state.
 * ====================================================================== */
void LinSched_Abort(void)
{
    byte s = R8(0x01D5);
    if (s == 0x04 || s == 0x05 || s == 0x07) {
        R8(0x01D5) = 0; R8(0x01D4) = 0;
        R8(0x01CB) = 0; R8(0x01CC) = 0;
        LinFrame_Done();               /* [0xE114] */
        return;
    }
    if (R8(0x01D4) != 0) {             /* dbnza: act only when ==1 */
        return;
    }
    R8(0x01D5) = 0; R8(0x01D4) = 0;
    R8(0x01CD) = 0; R8(0x01CE) = 0;
    R8(0x01D0) = 0; R8(0x01D1) = 0;
    LinFrame_Abort(1);                 /* [0xE0EC] tail */
}

/* ====================================================================== */
/* Frame-handler plumbing ([0x01EA] flag byte)                             */
/* ====================================================================== */

/* ======================================================================
 * LinFrame_SetIdle  [0xE02C]   (from LinApp_Init)
 * Set the frame engine to the idle/await state: [0x01EA] = (.. & 0xFC)|0x08.
 * ====================================================================== */
void LinFrame_SetIdle(void)
{
    R8(0x01EA) = (byte)((R8(0x01EA) & 0xFC) | 0x08);
}

void LinFrame_Begin(byte pid, byte arg);   /* [0xE083] fwd */

/* ======================================================================
 * LinFrame_RxStep  [0xE037]   (from Lin_Housekeep)
 * If a new frame arrived ([0x01EA] b0), process it: the diagnostic
 * auto-config PID 0x22 goes to LinDiag_AutoConfig, everything else begins a
 * normal frame (type 0x11).
 * ====================================================================== */
void LinFrame_RxStep(void)
{
    if (R8(0x01EA) & 0x01) {
        R8(0x01EA) &= (byte)~0x01;
        if (R8(0x01ED) == 0x22) {
            LinDiag_AutoConfig();      /* [0xCA87] */
        } else {
            LinFrame_Begin(0x11, 0);   /* [0xE083] via [0xE050] */
        }
    }
}

/* forward decls for the dispatch */
void LinFrame_Dispatch(void);          /* [0xE11E] */

/* ======================================================================
 * LinFrame_Begin  [0xE083]
 * Start handling a received frame: stash the PID [0x01EE], mark the engine
 * busy ([0x01ED]=0x7F), set type [0x01EC]=3 and dispatch.
 * ====================================================================== */
void LinFrame_Begin(byte pid, byte arg)
{
    (void)pid;
    R8(0x01EE) = R8(0x01ED);
    R8(0x01ED) = 0x7F;
    R8(0x01EF) = arg;
    R8(0x01EC) = 0x03;
    R8(0x01EB) = 0;
    LinFrame_Dispatch();               /* [0xE11E] */
}

/* ======================================================================
 * LinFrame_Classify  [0xE0AE]
 * Classify a frame against the node (NAD 0x7E = functional broadcast clears
 * b2; a length >= 0x41 marks a long/segmented frame b1) and return non-zero
 * when the frame is segmented.
 * ====================================================================== */
byte LinFrame_Classify(byte nad, word len)
{
    byte r = 0;
    if ((R8(0x01EA) & 0x02) == 0) {
        wr16(0x01EB, len);
        if (nad == 0x7E) {
            R8(0x01EA) &= (byte)~0x04;
        } else {
            R8(0x01EA) |= 0x04;
        }
        if (len >= 0x41) {
            R8(0x01EA) |= 0x02;
            r = 1;
        }
    }
    return r;
}

/* ======================================================================
 * LinFrame_Abort  [0xE0EC]
 * Abort the frame in progress: decrement the length counter [0x01EB] and set
 * the retry flags ([0x01EA] |= 0x09) unless the response bit [0x01ED] b6 is
 * set.
 * ====================================================================== */
byte LinFrame_Abort(byte arg)
{
    if ((R8(0x01ED) & 0x40) == 0 && arg == 0) {
        wr16(0x01EB, (word)(rd16(0x01EB) - 1));
        R8(0x01EA) |= 0x09;
    } else {
        R8(0x01EA) &= (byte)~0x02;
    }
    return 0;
}

/* ======================================================================
 * LinFrame_Done  [0xE114]
 * Mark the frame engine not-busy ([0x01EA] b1 = 0); returns 0.
 * ====================================================================== */
byte LinFrame_Done(void)
{
    R8(0x01EA) &= (byte)~0x02;
    return 0;
}

/* ======================================================================
 * LinFrame_Dispatch  [0xE11E]
 * If the frame is a diagnostic one ([0x01EA] b2), arm a scheduled response
 * ([0x01EC]/[0x01EB]); otherwise finish it.
 * ====================================================================== */
void LinFrame_Dispatch(void)
{
    if (R8(0x01EA) & 0x04) {
        LinSched_Arm(R8(0x01EC), rd16(0x01EB));   /* [0xD1C6] */
    } else {
        LinFrame_Done();                          /* [0xE114] */
    }
}

/* ======================================================================
 * Lin_ResetState  [0xCD1B]
 * Unpack the configuration nibbles ([0x019C]/[0x019B]) into the working
 * state [0x01B0..0x01B2] and seed [0x01C0]=0xF0.
 * ====================================================================== */
void Lin_ResetState(void)
{
    R8(0x01B2) = (byte)(R8(0x019C) >> 4);
    R8(0x01B0) = (byte)(R8(0x019C) & 0x0F);
    R8(0x01B1) = (byte)(R8(0x019B) & 0x0F);
    R8(0x01C0) = 0xF0;
    /* (continues clearing the LIN working block - see asm 0xCD38+) */
}

/* ====================================================================== */
/* Node state / reset                                                      */
/* ====================================================================== */

/* ======================================================================
 * LinNode_InitFramesPub  [0xDA3D] / LinNode_InitFramesAll  [0xDA78]
 * Lay out the publish (2) / all (4) frame descriptors from the flash tables
 * at 0xFEE1 (signal-buffer ptr), 0xFEDF/0xFED1 (length nibble), 0xFEE2 and
 * 0xFF09/0xFF0A, via Buf_CopyIdx.  Structural: the per-entry table walk is in
 * the asm (0xDA40.. / 0xDA7D..).
 * ====================================================================== */
void LinNode_InitFramesPub(void)
{
    byte i;
    for (i = 0; i < 2; i++) {
        if (((FLASH8(0xFEE1 + i * 2) << 8) | FLASH8(0xFEE2 + i * 2)) != 0) {
            /* Buf_CopyIdx(descDst, descSrc, FLASH8(0xFEDF+i)); */
        }
    }
}
void LinNode_InitFramesAll(void)
{
    byte i;
    for (i = 2; i < 4; i++) {
        if (((FLASH8(0xFEE1 + i * 2) << 8) | FLASH8(0xFEE2 + i * 2)) != 0) {
            /* Buf_CopyIdx(descDst, descSrc, FLASH8(0xFED1+i)>>4); */
        }
    }
}

/* ======================================================================
 * LinNode_Reset  [0xD67F]
 * Full LIN node reset: verify the 'S' sanity mark [0x01E4]==0x53 (else
 * LinErr_Set 0x21), clear the schedule/wake timers, set the diagnostic mode
 * ([0x01D9]=2, [0x00B8]=2), node address NAD=0x0A, frame index 0, (re)build
 * the frame tables (0xFECD descriptor base via Buf_CopyIdx), run DA3D/DA78,
 * clear the activity counters, re-init the SCI and leave the receiver off.
 * ====================================================================== */
void LinNode_Reset(void)
{
    if (R8(0x01E4) != 0x53) {
        LinErr_Set(0x21);
    }
    R8(0x00C5) = 0; R8(0x00C3) = 0; R8(0x00C2) = 0; R8(0x00C1) = 0;
    R8(0x01D9) = 0x02;
    R8(0x00B8) = 0x02;
    R8(0x01E9) = 0x0A;                 /* NAD */
    R8(0x01E2) = 0x00;
    /* Buf_CopyIdx(descBase, (const byte*)0xFECD, 4) - frame descriptor seed */
    LinNode_InitFramesPub();           /* [0xDA3D] */
    LinNode_InitFramesAll();           /* [0xDA78] */
    R8(0x01B6) = 0; R8(0x01B4) = 0; R8(0x01B5) = 0;
    R8(0x01D6) = 0; R8(0x00B1) = 0; R8(0x01D7) = 0;
    Sci_Init();                        /* [0xCF10] */
    LinSci_RxOff();                    /* [0xDE04] */
}

/* ======================================================================
 * LinNode_InitState  [0xD65A]   (called from LinApp_Init)
 * Set the 'S' sanity mark, clear the two signal buffers at 0x00C6/0x00C8 and
 * run the full node reset.
 * ====================================================================== */
void LinNode_InitState(void)
{
    R8(0x01E4) = 0x53;
    Buf_Clear((byte *)0x00C6, 1);      /* [0xE15C] */
    Buf_Clear((byte *)0x00C8, 1);      /* [0xE15C] */
    LinNode_Reset();                   /* [0xD67F] */
}

/* ======================================================================
 * LinNode_SetMode  [0xD6D2]   (called from LinApp_Init)
 * Set the LIN operating mode (arg 1 = run, 2 = diag); validates the sanity
 * mark and the mode, then either arms the wake timer ([0x00C4]/[0x00C5],
 * reload [0x01E3]=0x97) or re-enables the receiver and the sleep timer
 * ([0x00C1]=0xA1).  Returns 1 on success.
 * ====================================================================== */
byte LinNode_SetMode(byte mode)
{
    byte ok = 1;
    Lin_CritEnter();                   /* [0xD136] */

    if (R8(0x01E4) != 0x53) {
        LinErr_Set(0x21);
    }
    if (mode != 0x01 && mode != 0x02) {
        LinErr_Set(0x03);
    }

    if (R8(0x00C5) == 0) {
        if (mode == 0x01) {
            R8(0x01E3) = 0x97;
            R8(0x00C4) = 0x01;
            R8(0x00C5) = 0x01;
            Lin_SendWakeup();          /* [0xDE08] */
        } else {
            LinSci_RxOn();             /* [0xDDFE] */
            LinNode_Wake();            /* [0xDAC5] */
            R8(0x00C1) = 0xA1;
        }
        ok = 0;
    }

    Lin_CritExit();                    /* [0xD14E] */
    return ok;
}

/* ======================================================================
 * LinNode_SchedTick  [0xD722]   (called from Supervise_Task)
 * Decrement the sleep/wake supervision timers ([0x00C2],[0x00C1]); on expiry
 * send the matching LIN management response (go-to-sleep / wake-up) through
 * LinApp_SendError and re-arm the node.
 * ====================================================================== */
void LinNode_SchedTick(void)
{
    Lin_CritEnter();                   /* [0xD136] */
    if (R8(0x01E4) != 0x53) {
        LinErr_Set(0x21);
    }

    if (R8(0x00C2) != 0 && --R8(0x00C2) == 0) {
        if (R8(0x00C5) == 0x01) {
            R8(0x00C5) = 0;
            LinApp_SendError(0x0A);    /* [0xCA54] */
        } else if (R8(0x00C5) == 0x02) {
            LinApp_SendError(0x04);
            LinNode_Rearm();           /* [0xDAB6] */
        }
    }
    if (R8(0x00C1) != 0 && --R8(0x00C1) == 0) {
        LinApp_SendError(0x03);
        LinNode_Rearm();
    }
    Lin_CritExit();                    /* [0xD14E] */
}

/* ====================================================================== */
/* ISO-TP (diagnostic) receive / transmit state machines                   */
/* ====================================================================== */

/* ======================================================================
 * LinTp_RxFrame  [0xD20D]   (from LinDiag_Response)
 * ISO-TP receive handler for a diagnostic request frame in 'buf' (8 bytes:
 * NAD, PCI, data...).  Parses the PCI byte:
 *   0x0x  Single Frame  - a complete request of 1..6 bytes;
 *   0x1x  First Frame   - start of a segmented request, length in PCI+next;
 *   0x2x  Consecutive   - a continuation carrying the running sequence
 *                         number [0x01CF];
 * validating the NAD against the node ([0x01E9] or functional 0x7F),
 * assembling the payload into the diagnostic buffer (base 0x01ED) via
 * Buf_Copy, and advancing the TP state [0x01D5]/[0x01D4].  Returns a result
 * code (0 ignore, 1 armed, 2 segmented-in-progress, 3 error).  Structural
 * reconstruction of 0xD20D-0xD44B.
 * ====================================================================== */
byte LinTp_RxFrame(const byte *buf)
{
    byte nad = buf[0];
    byte pci = buf[1];

    if (nad < 0x80) {
        return 0;                      /* not addressed to a slave [0xD445] */
    }
    if (nad != R8(0x01E9) && nad != 0x7F) {
        return 3;                      /* wrong NAD [0xD43F] */
    }

    if ((pci & 0xF0) == 0x00) {        /* Single Frame [0xD24A] */
        byte len = pci & 0x0F;
        if (len == 0 || len >= 0x07) {
            return 3;
        }
        if (R8(0x01D4) == 1) { R8(0x01D5) = 0; R8(0x01D4) = 0; LinFrame_Done(); }
        LinFrame_Abort(1);             /* abort any pending [0xE0EC] */
        R8(0x01D3) = LinFrame_Classify(nad, len);   /* [0xE0AE] */
        if (R8(0x01D3) != 1 && R8(0x01D3) != 2) {
            return 3;
        }
        Buf_Copy((byte *)0x01ED, buf + 2, len);     /* [0xE188] */
        R8(0x01D4) = 0;
        return 2;
    }

    if ((pci & 0xF0) == 0x10) {        /* First Frame [0xD2C9] */
        word total = (word)(((pci & 0x0F) << 8) | buf[2]);
        if (total < 0x0007) {
            return 3;
        }
        if (R8(0x01D4) == 1) { R8(0x01D5) = 0; R8(0x01D4) = 0; LinFrame_Done(); }
        R8(0x01D3) = LinFrame_Classify(nad, total);
        if (R8(0x01D3) != 1 && R8(0x01D3) != 2) {
            return 3;
        }
        Buf_Copy((byte *)0x01ED, buf + 3, 5);       /* first 5 payload bytes */
        wr16(0x01CD, (word)(total - 5));
        R8(0x01CF) = 0x01;             /* next expected sequence */
        R8(0x01D1) = 0x05; R8(0x01D0) = 0x00;
        R8(0x01D2) = nad;
        R8(0x01D5) = 0x05;             /* segmented receive in progress */
        R8(0x01D4) = 1;
        return 1;
    }

    if ((pci & 0xF0) == 0x20) {        /* Consecutive Frame [0xD376] */
        if (R8(0x01D4) != 1) {
            return 3;
        }
        if (nad != R8(0x01D2)) {
            return 3;
        }
        if ((pci & 0x0F) != R8(0x01CF)) {
            /* sequence error -> abort [0xD42C] */
            R8(0x01CB) = 0; R8(0x01CC) = 0;
            LinFrame_Abort(1);
            R8(0x01D5) = 0; R8(0x01D4) = 0;
            return 3;
        }
        {
            word remain = rd16(0x01CD);
            word off = rd16(0x01D0);
            byte n = (remain < 6) ? (byte)remain : 6;
            Buf_Copy((byte *)(0x01ED + 1 + off), buf + 2, n);   /* [0xE188] */
            wr16(0x01D0, (word)(off + 6));
            R8(0x01CF) = (byte)((R8(0x01CF) + 1) & 0x0F);
            wr16(0x01CD, (word)(remain - n));
            if (remain <= 6) {         /* assembly complete */
                R8(0x01CD) = 0; R8(0x01CE) = 0;
                return 2;
            }
        }
        return 1;
    }

    if (R8(0x01D4) == 1) {             /* unexpected PCI while receiving */
        return 2;
    }
    return 3;
}

/* ======================================================================
 * LinTp_TxFrame  [0xD44C]   (from LinDiag_Response)
 * ISO-TP transmit: build the next response frame into 'buf' from the TP
 * state [0x01D5] (3 = prepare SF/FF, 6 = consecutive), copying from the
 * diagnostic buffer (base 0x01ED) with the correct PCI, and arming the next
 * step.  Structural reconstruction of 0xD44C-0xD5C6.
 * ====================================================================== */
void LinTp_TxFrame(byte *buf)
{
    byte state = R8(0x01D5);

    if (state == 0x03) {               /* first/single response [0xD458] */
        word len = rd16(0x01CD);
        R8(0x01CB) = 0; R8(0x01CC) = 0;
        buf[0] = R8(0x01D2);           /* NAD */
        if (len < 0x0007) {            /* Single Frame */
            buf[1] = (byte)R8(0x01CE);
            Buf_Copy(buf + 2, (const byte *)0x01ED, len);
            R8(0x01D5) = 0x04;         /* done after this frame */
            R8(0x01CD) = 0; R8(0x01CE) = 0;
        } else {                        /* First Frame */
            buf[1] = (byte)((R8(0x01CD) & 0x0F) | 0x10);
            buf[2] = R8(0x01CE);
            Buf_Copy(buf + 3, (const byte *)0x01ED, 5);
            wr16(0x01CD, (word)(len - 5));
            R8(0x01CF) = 0x01;
            R8(0x01D1) = 0x05; R8(0x01D0) = 0x00;
            R8(0x01D5) = 0x05;         /* consecutive frames to follow */
        }
        R8(0x01CC) = 0x14; R8(0x01CB) = 0;
        return;
    }

    if (state == 0x06) {               /* consecutive response [0xD50C] */
        word remain = rd16(0x01CD);
        R8(0x01CB) = 0; R8(0x01CC) = 0;
        buf[0] = R8(0x01D2);
        buf[1] = (byte)(R8(0x01CF) | 0x20);
        if (remain < 0x0007) {
            Buf_Copy(buf + 2, (const byte *)(0x01ED + rd16(0x01D0)), remain);
            R8(0x01D0) = 0; R8(0x01D1) = 0;
            R8(0x01CD) = 0; R8(0x01CE) = 0;
            R8(0x01D5) = 0x07;         /* transfer complete */
        } else {
            Buf_Copy(buf + 2, (const byte *)(0x01ED + rd16(0x01D0)), 6);
            wr16(0x01D0, (word)(rd16(0x01D0) + 6));
            wr16(0x01CD, (word)(remain - 6));
            R8(0x01D5) = 0x07;
            R8(0x01CF) = (byte)((R8(0x01CF) + 1) & 0x0F);
        }
        R8(0x01CC) = 0x14; R8(0x01CB) = 0;
    }
}

/* ======================================================================
 * LinTp_TxStep  [0xD5C7]   (from LinDiag_Response, frame sent)
 * Advance the transmit state machine after a response frame goes out: state
 * 4 completes the exchange (LinFrame_Done), states 5/7 schedule the next
 * consecutive frame (delay [0x01CC]=0x32) or finish when the buffer drains.
 * ====================================================================== */
byte LinTp_TxStep(void)
{
    byte s = R8(0x01D5);
    if (s == 0x04) {
        R8(0x01D5) = 0; R8(0x01CB) = 0; R8(0x01CC) = 0;
        return LinFrame_Done();        /* [0xE114] */
    }
    if (s == 0x05 || (s == 0x07 && rd16(0x01CD) != 0)) {
        R8(0x01D5) = 0x06;             /* queue next consecutive frame */
        R8(0x01CC) = 0x32; R8(0x01CB) = 0;
        return 1;
    }
    if (s == 0x07) {                   /* complete */
        R8(0x01D5) = 0; R8(0x01CB) = 0; R8(0x01CC) = 0;
        return LinFrame_Done();
    }
    return 3;
}

/* ====================================================================== */
/* LIN management responses + sleep handling                              */
/* ====================================================================== */

/* ======================================================================
 * LinApp_SendError  [0xCA54]
 * Latch the LIN error/status bit ([0x026B] b2) and, for any code other than
 * 0x03 (wake), force the dimming level [0x02AA] to its safe default 0x50.
 * ====================================================================== */
void LinApp_SendError(byte code)
{
    R8(0x026B) |= 0x04;
    if (code != 0x03) {
        R8(0x02AA) = 0x50;
    }
}

/* ======================================================================
 * Lin_SleepArm  [0xCA6B]
 * Clear the bus-timeout request ([0x026B] b0) and reset the LIN state.
 * ====================================================================== */
void Lin_SleepArm(void)
{
    R8(0x026B) &= (byte)~0x01;
    Lin_ResetState();                  /* [0xCD1B] */
}

/* ======================================================================
 * Lin_SleepCheck  [0xCA75]
 * Reset the LIN state; if no comms error is latched ([0x026B] b2 clear) raise
 * the bus-timeout request ([0x026B] b0).
 * ====================================================================== */
void Lin_SleepCheck(void)
{
    Lin_ResetState();                  /* [0xCD1B] */
    if ((R8(0x026B) & 0x04) == 0) {
        R8(0x026B) |= 0x01;
    }
}

/* ======================================================================
 * LinDiag_AutoConfig  [0xCA87]
 * Handle the diagnostic auto-addressing frame (PID 0x22): fold the two-byte
 * identifier [0x01EE:0x01EF] and, when the slot count [0x01EB]==2, apply the
 * assigned address through the fixed-point helper (0xFD89); otherwise begin a
 * normal diagnostic frame (type 0x13).  Structural reconstruction of
 * 0xCA87-0xCB40.
 * ====================================================================== */
void LinDiag_AutoConfig(void)
{
    word ident = (word)((R8(0x01EE) << 8) | R8(0x01EF));
    (void)ident;
    if (rd16(0x01EB) == 0x0002) {
        /* apply assigned NAD via the 0xFD89 runtime helper (see asm) */
    } else {
        LinFrame_Begin(0x13, 0);       /* [0xCB38 -> 0xE083] */
    }
}

/* ======================================================================
 * LinNode_Rearm  [0xDAB6]
 * Re-arm the node after a management response: clear the wake/sleep timers
 * ([0x00C5],[0x00C1]), run the sleep-check, rebuild the frame tables and
 * leave the receiver off.
 * ====================================================================== */
void LinNode_Rearm(void)
{
    R8(0x00C5) = 0; R8(0x00C1) = 0;
    Lin_SleepCheck();                  /* [0xCA75] */
    LinNode_InitFramesPub();           /* [0xDA3D] */
    LinNode_InitFramesAll();           /* [0xDA78] */
    LinSci_RxOff();                    /* [0xDE04] */
}

/* ======================================================================
 * LinNode_Wake  [0xDAC5]
 * On a wake event, (re)arm the publish state ([0x00C5]=2), rebuild the frame
 * tables and arm the bus-idle sleep supervision.
 * ====================================================================== */
void LinNode_Wake(void)
{
    if (R8(0x00C5) == 0 || --R8(0x00C5) == 0) {
        R8(0x00C5) = 0x02;
        LinNode_InitFramesPub();       /* [0xDA3D] */
        LinNode_InitFramesAll();       /* [0xDA78] */
        Lin_SleepArm();                /* [0xCA6B] */
    }
}

/* ======================================================================
 * Lin_SendWakeup  [0xDE08]
 * Transmit a LIN wake-up byte (0x80) and set the byte engine idle
 * ([0x00B7]=0xFF).
 * ====================================================================== */
void Lin_SendWakeup(void)
{
    Sci_SendByte(0x80);
    *(volatile byte *)0x00B7 = 0xFF;
}
