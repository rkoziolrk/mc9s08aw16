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

extern void Lin_RxByte(byte data);       /* [0xDEA6] */
extern void Lin_TxByteOrErr(byte event); /* [0xDFB6] */

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
