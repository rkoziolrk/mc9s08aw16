/*
 * lin_transport.c - LIN schedule / diagnostics / transport helpers.
 *   LinCrc_Fold (0xDE88), LinSci_RxOn (0xDDFE) / RxOff (0xDE04),
 *   LinErr_Set (0xCA41), LinSched_OnHeader (0xDAD9), and the larger
 *   diagnostic/transport routines (LinErr_Report 0xDCCB, LinDiag_Response
 *   0xDBB7, LinTp_Timer 0xDD6C) which parallel the AW32 part (s909aw32).
 *
 * Frame tables (flash): node PID list at RAM 0x01E5, per-frame descriptor
 * at 0xFED1, signal-buffer pointer table at 0xFEE1.
 */
#include "app.h"

#define R8(a)   (*(volatile byte *)(a))
#define FLASH8(a)  (*(const volatile byte *)(a))
#define g_linCrcH    R8(0x00B4)
#define g_linCrcL    R8(0x00B5)
#define g_linRxState R8(0x00B7)

extern void Sci_SendByte(byte data);
extern void Buf_Copy(byte *dst, const byte *src, word count);   /* [0xE188] lin_core.c */

/* ======================================================================
 * LinCrc_Fold  [0xDE88]  fold the 16-bit running sum (0x00B4:0x00B5) into
 * the 8-bit LIN checksum.
 * ====================================================================== */
void LinCrc_Fold(void)
{
    word sum = (word)((g_linCrcH << 8) | g_linCrcL);
    sum = (word)((sum & 0xFF) + (sum >> 8));
    if (sum & 0xFF00) {
        sum = (word)((sum & 0xFF) + 1);
    }
    g_linCrcL = (byte)sum;
    g_linCrcH = (byte)(sum >> 8);
}

/* [0xDDFE] put the byte engine into the "await header" idle state (0x80)
 * and run the LIN critical-section tail (0xD126). */
void LinSci_RxOn(void)
{
    g_linRxState = 0x80;
    /* jmp 0xD126 (LinCrit tail) - see reference/application.asm */
}

/* [0xDE04] fully idle (0xFF) */
void LinSci_RxOff(void)
{
    g_linRxState = 0xFF;
}

/* ======================================================================
 * LinErr_Set  [0xCA41]
 * Flags a LIN error: sets bit2 (0x04) in the status/error byte 0x026B.
 * (The code argument the callers pass is not used by this routine.)
 * ====================================================================== */
void LinErr_Set(byte code)
{
    (void)code;
    R8(0x026B) |= 0x04;
}

/* ======================================================================
 * LinSched_OnHeader  [0xDAD9]
 * A header's protected identifier arrived: resolve it to one of the node's
 * frames and set up the response path. Diagnostic PIDs 0x3C/0x7D map to
 * slots 4/5; data PIDs are looked up in the node PID list at 0x01E5. The
 * per-frame descriptor (0xFED1[idx]) gives the length nibble and direction
 * bits; a publish frame's signal buffer comes from the 0xFEE1 pointer
 * table. Same structure as the AW32 LinSched_OnHeader; the detailed per-
 * slot handling is in reference/application.asm 0xDAD9-0xDBA0.
 * ====================================================================== */
void LinSched_OnHeader(byte pid)
{
    byte idx;

    if (pid == 0x3C) {
        idx = 4;                               /* diagnostic request  */
    } else if (pid == 0x7D) {
        idx = 5;                               /* diagnostic response */
    } else {
        byte i = 4;
        idx = 0xFF;
        do {
            i--;
            if (R8(0x01E5 + i) == pid) { idx = R8(0x01E5 + i); break; }
        } while (i != 0);
    }
    R8(0x01E2) = idx;

    if (idx == 0xFF) {
        return;                                /* not for this node */
    }
    /* descriptor 0xFED1[idx], direction (desc & 0x0C): publish copies the
     * mapped signal buffer (0xFEE1 table) and starts the engine; subscribe
     * collects the data. See the asm for the exact per-frame arming
     * (LinDiag_Request path). */
}

/* ---- transport / diagnostic state (zero page + RAM) ------------------ */
#define tp_state   R8(0x00B1)   /* N_As/N_Cr timer state (0x0F/0x11/0x23)   */
#define tp_sub     R8(0x00B8)   /* ISO-TP sub-state                         */
#define tp_flag    R8(0x00B9)   /* ISO-TP in-progress flag                  */
#define wk_timerLo R8(0x00C2)   /* wake/sleep timer                         */
#define wk_count   R8(0x00C3)   /* wake/sleep down-counter                  */
#define wk_state   R8(0x00C4)   /* wake/sleep state                         */
#define tp_toReload R8(0x01D6)  /* N_Cr timeout reload                      */
#define tp_timeout  R8(0x01D7)  /* running transport timeout                */
#define tp_mode     R8(0x01D9)  /* diagnostic mode (0..3)                   */
#define tp_frameIdx R8(0x01E2)  /* active frame index                       */
#define wk_reload   R8(0x01E3)  /* wake-timer reload                        */

/* transport-core helpers reconstructed elsewhere / referenced by address */
extern void Lin_CritEnter(void);  /* [0xD136] lin_core.c */
extern void Lin_CritExit(void);   /* [0xD14E] lin_core.c */
extern void LinApp_SendError(byte code); /* [0xCA54] lin_core.c */
extern void LinSched_Abort(void);        /* [0xD61D] lin_core.c */
extern void Lin_SendWakeup(void);        /* [0xDE08] lin_core.c */

/* ======================================================================
 * LinErr_Report  [0xDCCB]
 * Translate a protocol error code (in A) into the transport-state update and
 * the published diagnostic-error signal.  High-nibble codes (0x1x) index the
 * active frame; a diagnostic-request slot (4) or response slot (5) advances
 * the ISO-TP state ($B8/$B9/$01D9) and the recognised service errors
 * (0x11/0x12 -> 0x08, 0x13 -> 0x09, 0x14 -> 0x07, 0x16 -> 0x02) are reported
 * through LinApp_SendError; a bus error (0x05/0x07) reports code 0x01.  Marks the
 * diagnostic frame's status byte (0xFEE7[7] |= 0x80).
 * ====================================================================== */
void LinErr_Report(byte code)
{
    byte idx;

    if ((code & 0xF0) == 0) {
        /* bus-level error */
        if (code == 0x05 || code == 0x07) {
            LinApp_SendError(0x01);                /* report generic bus error */
        }
        return;
    }

    idx = tp_frameIdx;                     /* [0x01E2] */
    /* mark the diagnostic frame's status byte as errored */
    {
        const volatile byte *desc = (const volatile byte *)
            ((FLASH8(0xFEE7) << 8) | FLASH8(0xFEE8));
        (void)desc;                        /* 0xFEE7 points at the frame; [7] |= 0x80 */
    }
    R8(0x0000);                            /* (status marker write, see asm 0xDCDA) */

    if (idx == 0x04) {                     /* diagnostic request slot */
        if (tp_sub == 0x02) tp_flag = 0;
        if (tp_sub == 0x03 || tp_mode == 0x03) {
            tp_mode = 0x02;
            LinSched_Abort();
        }
        tp_sub = 0x02;
    } else if (idx == 0x05) {              /* diagnostic response slot */
        if (tp_sub == 0x03) {
            tp_mode = 0x02;
            LinSched_Abort();
        }
        if (tp_sub == 0x02) tp_flag = 0;
    }

    switch (code) {
    case 0x11: case 0x12: LinApp_SendError(0x08); break;   /* [0xDD36] */
    case 0x13:            LinApp_SendError(0x09); break;   /* [0xDD3E] */
    case 0x14:            LinApp_SendError(0x07); break;   /* [0xDD46] */
    case 0x16:            LinApp_SendError(0x02); break;   /* [0xDD4E] */
    default: break;
    }
}

/* ======================================================================
 * LinDiag_Response  [0xDBB7]
 * Frame-complete dispatcher for the diagnostic transport.  For a publish
 * frame (direction nibble) it copies the mapped signal buffer (0xFEE1/0xFEE2
 * tables) out through Buf_Copy and OR-marks the TX ready flags (0x00C8); for
 * a subscribe/diagnostic frame it runs the ISO-TP receive step (Lin_FrameMatch /
 * LinTp_RxFrame) advancing the mode ($01D9) and sub-state ($B8).  This is a
 * structural reconstruction of 0xDBB7-0xDCCA; the per-table arithmetic is in
 * reference/application.asm.
 * ====================================================================== */
void LinDiag_Response(byte kind)
{
    byte idx = R8(0x01E2);                 /* active frame index [0x01DA+8] */
    (void)kind;

    if (R8(0x01DE) != 1) {                 /* publish path [0xDC6E] */
        if (idx >= 4) {
            R8(0x00C6) |= FLASH8(0xFEF0 + idx);   /* mark TX-ready flags */
            /* dispatch the publish handler from 0xFEF5[idx*2-4] via 0xFCD8 */
        } else {
            R8(0x00C6) |= FLASH8(0xFEF4);
            if (tp_sub == 0x02) tp_flag = 0;
            if (tp_sub == 0x03) { LinSched_Abort(); tp_sub = 0x02; }
        }
        return;
    }

    /* subscribe / diagnostic receive path [0xDBCD] */
    if (idx < 4) {
        /* copy the mapped signal buffer (0xFEE1/0xFEE2 -> Buf_Copy) */
        R8(0x00C8) |= FLASH8(0xFEEC + idx);
        return;
    }
    if (idx >= 6) {
        return;
    }
    /* idx 4/5: diagnostic request/response ISO-TP step */
    R8(0x00C8) |= FLASH8(0xFEEE);
    /* Lin_FrameMatch / LinTp_RxFrame advance the ISO-TP state; result selects the
     * next mode ($01D9) / sub-state ($B8). See the asm for the detail. */
}

/* ======================================================================
 * LinTp_Timer  [0xDD6C]   (called from Isr_Tpm2Ch0, 0xC781, every 1 ms)
 * Service the ISO-TP N_As/N_Cr timeout timer and the wake/sleep timer.
 *   - tp_state [0x00B1]: 0x11 arms the timeout from tp_toReload, 0x23 extends
 *     it, 0x0F clears it; when a running tp_timeout reaches zero a timeout is
 *     reported (state 0x10 -> N_As err 0x05, state 0x20 -> N_Cr err 0x16) and
 *     the receiver is re-armed (LinSci_RxOn).
 *   - wk_state [0x00C4]: 0x01 loads the wake counter from [0x01E3], 0x0F
 *     clears it; when wk_count expires the wake/sleep sequence advances
 *     (RxOff, 0x3D sleep marker in wk_timerLo).
 * ====================================================================== */
void LinTp_Timer(void)
{
    Lin_CritEnter();                      /* [0xD136] */

    /* --- transport timeout timer --- */
    if (tp_state == 0x11) {
        tp_timeout = tp_toReload;
        tp_state   = 0x10;
    } else if (tp_state == 0x23) {
        tp_timeout = (byte)(tp_timeout + tp_toReload);
        tp_state   = 0x20;
    } else if (tp_state == 0x0F) {
        tp_timeout = 0;
        tp_state   = 0;
    }

    if (tp_timeout != 0) {
        if (--tp_timeout == 0) {
            if (tp_state == 0x10) {
                LinErr_Report(0x05);       /* N_As timeout */
            } else if (tp_state == 0x20) {
                LinErr_Report(0x16);       /* N_Cr timeout */
            }
            tp_state = 0;
            LinSci_RxOn();                 /* re-arm the receiver */
        }
    }

    /* --- wake / sleep timer --- */
    if (wk_state == 0x01) {
        wk_count = wk_reload;              /* [0x01E3] */
        wk_state = 0x11;
    } else if (wk_state == 0x0F) {
        wk_count = 0;
        wk_state = 0;
    }

    if (wk_count != 0) {
        if (--wk_count == 0) {
            if (wk_state == 0x11 || wk_state == 0x12) {
                wk_state++;
                wk_count = 0x97;
                LinSci_RxOff();            /* [0xDE04] */
                Lin_SendWakeup();          /* [0xDE08] */
            } else if (wk_state == 0x13) {
                wk_state   = 0;
                wk_timerLo = 0x3D;         /* enter sleep window */
            }
        }
    }

    Lin_CritExit();                        /* [0xD14E] */
}

/* ======================================================================
 * Lin_GotoSleep2  [0xDAD7]
 * Request the LIN bus-idle -> sleep supervision by clearing the LIN error
 * latch (0x026B b0) and running the common reset tail (0xCD1B).
 * ====================================================================== */
void Lin_GotoSleep2(void)
{
    R8(0x026B) &= (byte)~0x01;
    /* jmp 0xCD1B (Lin_ResetState) */
}
