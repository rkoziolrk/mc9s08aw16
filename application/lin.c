/*
 * lin.c - LIN slave communication driver (SCI1 physical layer).
 *         Core: Sci_Init (0xCF10), Sci_SendByte (0xCF36), Isr_Sci1 (0xCF46).
 *
 * Same design as the AW32 sibling (s909aw32): 8-N-1, polled/interrupt SCI1,
 * LIN BREAK detected as a framing error, SYNC-field auto-baud via a TPM2
 * input capture. The received/transmitted bytes of a frame are driven from
 * the SCI interrupt through two state machines:
 *     Lin_RxByte       [0xDEA6]  a byte was received
 *     Lin_TxByteOrErr  [0xDFB6]  BREAK / bus error
 * (reconstructed in a later pass; see PROGRESS.md).
 */
#include "app.h"


/* ======================================================================
 * Sci_Init  [0xCF10]
 * SCI1 for LIN: SBR=0x41 (refined by auto-baud), 8-bit no parity, receiver
 * + error interrupts enabled (SCI1C3=0x0E), SCI1S2=0x04, SCI1C2=0x2C
 * (RIE|TE|RE). Reads S1/D once to clear flags.
 * ====================================================================== */
void Sci_Init(void)
{
    volatile byte dummy;
    SCI1BDH = 0x00;
    SCI1BDL = 0x41;
    SCI1C1  = 0x00;
    SCI1C3  = 0x0E;
    dummy   = SCI1S1;
    dummy   = SCI1D;
    SCI1S2  = 0x04;
    SCI1C2  = SCI_C2_RIE | SCI_C2_TE | SCI_C2_RE;   /* 0x2C */
    (void)dummy;
}

/* ======================================================================
 * Sci_SendByte  [0xCF36]
 * Reads S1 (TDRE handshake) and writes one byte to the data register.
 * ====================================================================== */
void Sci_SendByte(byte data)
{
    volatile byte dummy = SCI1S1;
    SCI1D = data;
    (void)dummy;
}

/* ======================================================================
 * Isr_Sci1  [0xCF46]  (SCI1 receive / error interrupt)
 * Reads S1 and the data register, then:
 *   - error (NF|FE|PF, 0x0E): FE(0x02)->event 2 (BREAK), OR(0x08)->event 3,
 *     else event 4  -> Lin_TxByteOrErr(event);
 *   - RDRF (0x20): byte received -> Lin_RxByte(data).
 * ====================================================================== */
INTERRUPT void Isr_Sci1(void)
{
    byte s1   = SCI1S1;
    byte data = SCI1D;

    if (s1 & (SCI_S1_NF | SCI_S1_FE | SCI_S1_PF)) {   /* 0x0E */
        if (s1 & SCI_S1_FE) {
            Lin_TxByteOrErr(2);                        /* framing error = BREAK */
        } else if (s1 & SCI_S1_OR) {
            Lin_TxByteOrErr(3);                        /* overrun */
        } else {
            Lin_TxByteOrErr(4);
        }
    } else if (s1 & SCI_S1_RDRF) {
        Lin_RxByte(data);
    }
}

/* ---- LIN byte-engine state (zero page) -------------------------------- */
#define R8(a)        (*(volatile byte *)(a))
#define g_linTpState   R8(0x00B1)
#define g_linBufPtr    (*(byte * volatile *)0x00B2)
#define g_linCrcH      R8(0x00B4)
#define g_linCrcL      R8(0x00B5)
#define g_linByteCnt   R8(0x00B6)
#define g_linRxState   R8(0x00B7)
#define g_linRespTimer R8(0x00C1)      /* re-armed to 0xA1 on each byte */

extern void LinErr_Set(byte code);            /* [0xCA41] */
extern void LinErr_Report(byte code);         /* [0xDCCB] */
extern void LinSci_RxOn(void);                /* [0xDDFE] */
extern void Lin_GotoSleep2(void);             /* [0xDAD7] */
extern void LinSched_OnHeader(byte pid);      /* [0xDAD9] */
extern void LinCrc_Fold(void);                /* [0xDE88] */
extern void LinDiag_Response(byte kind);      /* [0xDBB7] */

static void Lin_CrcAdd(byte b)
{
    word s = (word)(g_linCrcL + b);
    g_linCrcL = (byte)s;
    g_linCrcH = (byte)(g_linCrcH + (s >> 8));
}

/* ======================================================================
 * Lin_RxByte  [0xDEA6]   master receive/response state machine (via Isr_Sci1)
 * Identical design to the AW32 part; g_linRxState ($B7) selects the meaning
 * of the incoming byte. Publish frames are clocked out half-duplex (the
 * byte we put on the single-wire bus loops back and triggers the next).
 * ====================================================================== */
void Lin_RxByte(byte data)
{
    g_linRespTimer = 0xA1;

    switch (g_linRxState) {
    case 0x01:  /* PUBLISH: verify looped-back byte, send next / checksum */
        if (*g_linBufPtr != data) {
            LinErr_Report(0x11);
            LinSci_RxOn();
            g_linTpState = 0x0F;
            return;
        }
        if (--g_linByteCnt != 0) {
            g_linBufPtr++;
            Sci_SendByte(*g_linBufPtr);
            Lin_CrcAdd(*g_linBufPtr);
        } else {
            LinCrc_Fold();
            Sci_SendByte((byte)~g_linCrcL);
            g_linRxState = 0x02;
        }
        return;

    case 0x02:  /* PUBLISH: checksum byte looped back */
        LinSci_RxOn();
        g_linTpState = 0x0F;
        if ((byte)~g_linCrcL == data) {
            LinDiag_Response(2);
        } else {
            LinErr_Report(0x11);
        }
        return;

    case 0x08:  /* DIAGNOSTIC receive: data byte */
        if (g_linByteCnt == 0) {
            LinErr_Set(0x0B);
        }
        Lin_CrcAdd(data);
        *g_linBufPtr = data;
        g_linBufPtr++;
        if (--g_linByteCnt == 0) {
            g_linRxState = 0x09;
        }
        return;

    case 0x09:  /* DIAGNOSTIC receive: checksum byte */
        LinSci_RxOn();
        g_linTpState = 0x0F;
        LinCrc_Fold();
        if ((byte)~g_linCrcL == data) {
            LinDiag_Response(1);
        } else {
            LinErr_Report(0x14);
        }
        return;

    case 0x80:  /* idle in the RX direction */
        return;

    case 0x90:  /* diagnostic: expect 0x55 after the request PID */
        if (data == 0x55) {
            g_linRxState = 0xB0;
        } else {
            LinErr_Report(0x03);
            LinSci_RxOn();
            g_linTpState = 0x0F;
        }
        return;

    case 0xB0:  /* diagnostic request: NAD / first byte */
        R8(0x01D8) = data;
        LinSched_OnHeader(data);
        return;

    case 0xFF:  /* idle: bus activity -> go-to-sleep supervision */
        LinSci_RxOn();
        Lin_GotoSleep2();
        return;

    default:
        LinErr_Set(0x0B);
        return;
    }
}

/* ======================================================================
 * Lin_TxByteOrErr  [0xDFB6]  (bus BREAK / error handler)
 * event = 2 for a LIN BREAK (framing error), 3/4 for overrun / other error.
 * Flags the per-state protocol error and, on a BREAK, re-arms the receiver
 * for the next diagnostic request header (state 0x90).
 * ====================================================================== */
void Lin_TxByteOrErr(byte event)
{
    g_linRespTimer = 0xA1;

    switch (g_linRxState) {
    case 0x01: case 0x02:
        LinErr_Report(0x12);
        break;
    case 0x08: case 0x09:
        if (event == 2) {
            LinErr_Report(0x13);
            goto rearm;
        }
        LinErr_Report(0x13);
        LinSci_RxOn();
        g_linTpState = 0x0F;
        return;
    case 0x80:
        if (event != 2) return;
        break;
    case 0x90: case 0xB0:
        LinErr_Report(0x07);
        break;
    case 0xFF:
        LinSci_RxOn();
        Lin_GotoSleep2();
        return;
    default:
        LinErr_Set(0x0B);
        return;
    }

    if (event == 2) {
rearm:
        g_linRxState = 0x90;
        R8(0x01D6)   = 0x04;
        g_linTpState = 0x11;
    } else {
        LinSci_RxOn();
        g_linTpState = 0x0F;
    }
}

/* ======================================================================
 * Lin_AutobaudIsr  [0xCFA2]   (TPM2 CH1 input-capture vector)
 * LIN sync-field autobaud.  Sci_Init arms TPM2 CH1 input capture; this ISR
 * is entered on each captured falling edge of the 0x55 sync byte and runs a
 * 5-phase state machine in g_abState [0x01BC]:
 *   phase 1: latch the first edge timestamp [0x01BA:0x01BB], go to 2;
 *   phase 2: measure the first bit period; reject it (restart at 1) if it is
 *            not below the plausibility threshold 0x2CC3, else go to 3;
 *   phase 3: latch, go to 4;
 *   phase 4: measure the next period into [0x01B8:0x01B9], go to 5;
 *   phase 5: measure the final period, accumulate, round (+0x20) and divide
 *            by 64 (>>6) to form the SCI baud divisor, and program
 *            SCI1BDH:SCI1BDL.
 * Timestamp deltas are computed modulo the 16-bit TPM2 counter (wrap aware).
 * The idle/await-header entry (0x01BC = 1, TPM2C1SC = 0x48) is set by
 * LinSci_RxOn's tail [0xD126].
 * ====================================================================== */
#define g_abState   R8(0x01BC)
#define g_abT0      R8(0x01BA)   /* previous capture, high */
#define g_abT0L     R8(0x01BB)   /* previous capture, low  */
#define g_abAcc     R8(0x01B8)   /* accumulated period, high */
#define g_abAccL    R8(0x01B9)   /* accumulated period, low  */

/* (now - prev) across the free-running 16-bit TPM2 counter */
static word cap_delta(word now, word prev)
{
    return (word)(now - prev);
}

INTERRUPT void Lin_AutobaudIsr(void)
{
    word now = ((word)TPM2C1VH << 8) | TPM2C1VL;
    word prev = ((word)g_abT0 << 8) | g_abT0L;

    (void)TPM2C1SC;                         /* ack the capture flag */

    switch (g_abState) {
    case 1:                                 /* [0xCFB9] first edge */
        TPM2C1SC = 0x44;
        g_abT0  = (byte)(now >> 8);
        g_abT0L = (byte)(now & 0xFF);
        g_abState = 2;
        break;

    case 2:                                 /* [0xCFCB] first period */
        TPM2C1SC = 0x48;
        if (cap_delta(now, prev) < 0x2CC3) {
            g_abState = 3;                  /* plausible sync bit */
        } else {
            g_abState = 1;                  /* reject, restart */
        }
        break;

    case 3:                                 /* [0xD01A] */
        TPM2C1SC = 0x48;
        g_abT0  = (byte)(now >> 8);
        g_abT0L = (byte)(now & 0xFF);
        g_abState = 4;
        break;

    case 4: {                               /* [0xD030] */
        word d = cap_delta(now, prev);
        TPM2C1SC = 0x48;
        g_abAcc  = (byte)(d >> 8);
        g_abAccL = (byte)(d & 0xFF);
        g_abT0  = (byte)(now >> 8);
        g_abT0L = (byte)(now & 0xFF);
        g_abState = 5;
        break;
    }

    case 5: {                               /* [0xD07E] final + divisor */
        word d = cap_delta(now, prev);
        word acc = (((word)g_abAcc << 8) | g_abAccL) + d;
        word div;
        acc += 0x20;                        /* rounding [0xD0DD] */
        div = (word)(acc >> 6);             /* /64 [0xD0EB-0xD0F3] */
        SCI1BDH = (byte)(div >> 8);
        SCI1BDL = (byte)(div & 0xFF);
        TPM2C1SC = 0x08;
        g_abState = 0;                      /* autobaud done */
        break;
    }

    default:                                /* [0xD110] */
        TPM2C1SC = 0x08;
        break;
    }
}
