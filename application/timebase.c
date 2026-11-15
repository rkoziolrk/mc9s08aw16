/*
 * timebase.c - TPM time base and PWM init.
 *   Isr_Tpm2Ch0 (0xC743)  1 ms time base (output compare) + scan/LIN ticks
 *   Tpm1_Init   (0xC792)  TPM1 PWM (backlight) setup
 *   Tpm2_Init   (0xC7B6)  TPM2: CH0 time base, CH1 LIN auto-baud capture
 */
#include "app.h"

extern void LinTp_Timer(void);   /* [0xDD6C] */
extern void Scan_Isr(void);      /* [0xE537] button-ladder/backlight 1 ms tick */

word g_tpm2NextCompare AT(0x01A4);   /* [0x01A4] next CH0 compare value */

/* ======================================================================
 * Isr_Tpm2Ch0  [0xC743]   TPM2 channel-0 output compare
 * Re-arms the compare 0x270E (~1 ms) later, clears CH0F, and every 2nd
 * interrupt raises the tick flag (advancing g_tickCount and running the LIN
 * transport timer); the scan/PWM tick runs on every interrupt.
 * ====================================================================== */
INTERRUPT void Isr_Tpm2Ch0(void)
{
    volatile byte dummy = TPM2C0SC;
    g_tpm2NextCompare = TPM2C0V;
    TPM2C0SC &= 0x7F;                      /* clear CH0F */
    g_tpm2NextCompare += 0x270E;           /* +9998 bus clocks */
    TPM2C0V = g_tpm2NextCompare;

    if ((byte)((++*(volatile byte *)0x0104) >> 1) == 1) {
        g_tickFlag = 1;
        *(volatile byte *)0x0104 = 0;
        LinTp_Timer();                     /* [0xDD6C] */
        g_tickCount++;
    }
    Scan_Isr();                            /* [0xE537] */
    (void)dummy;
}

/* ======================================================================
 * Tpm1_Init  [0xC792]   TPM1: bus/2, overflow, modulo 0xC800; CH2 prepared,
 * other channels off (the backlight PWM channel is configured at run time).
 * ====================================================================== */
void Tpm1_Init(void)
{
    TPM1SC   = 0x49;
    TPM1MODH = 0xC8;
    TPM1MODL = 0x00;
    TPM1C2VH = 0xC8;
    TPM1C2VL = 0x00;
    TPM1C2SC = 0x00;
    TPM1C0SC = 0x00;
    TPM1C1SC = 0x00;
    TPM1C3SC = 0x00;
}

/* ======================================================================
 * Tpm2_Init  [0xC7B6]   TPM2: bus/1 free-running; CH0 = output compare time
 * base (interrupt, software compare), CH1 = input capture for LIN auto-baud.
 * ====================================================================== */
void Tpm2_Init(void)
{
    g_tpm2NextCompare = 0x270E;
    TPM2SC   = 0x08;
    TPM2MODH = 0x00;
    TPM2MODL = 0x00;
    TPM2C0SC = 0x50;                       /* CH0IE | MS0A */
    TPM2C1SC = 0x00;
    TPM2C0V  = g_tpm2NextCompare;
    TPM2C1VH = 0x00;
    TPM2C1VL = 0x00;
}
