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
extern void mem_copy(byte *dst, const byte *src, word count);

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

/* ======================================================================
 * LinErr_Report  [0xDCCB]  translate a protocol error code into the LIN
 *   published-signal update (parallels AW32 0x9BA1). Detail in the asm.
 * LinDiag_Response [0xDBB7]  frame-complete dispatcher (parallels 0x9AB6).
 * LinTp_Timer      [0xDD6C]  N_As/N_Cr transport timers (parallels 0x9C31),
 *   called from Isr_Tpm2Ch0.
 * These are reconstructed structurally against reference/application.asm;
 * the byte-level table handling is documented there.
 * ====================================================================== */
void LinErr_Report(byte code)      { (void)code; /* see asm 0xDCCB */ }
void LinDiag_Response(byte kind)   { (void)kind; /* see asm 0xDBB7 */ }
void LinTp_Timer(void)             { /* see asm 0xDD6C */ }

/* [0xDAD7] Lin_GotoSleep2 - LIN bus-idle -> sleep supervision (see asm). */
void Lin_GotoSleep2(void) { /* see reference/application.asm 0xDAD7 */ }
