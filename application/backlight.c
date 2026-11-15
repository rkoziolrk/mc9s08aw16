/*
 * backlight.c - Button backlight PWM driver for the MC9S08AW16 MFL module
 *               (the AW16 counterpart of the AW32 backlight path in
 *               wheel_io.c).
 *
 * The button backlighting is driven by TPM1 channel 2 as an edge-aligned PWM
 * (TPM1 MOD = 0xC8 = 200 steps, set in Tpm1_Init).  The commanded brightness
 * is the normalised value produced by the analogue acquisition chain in
 * inputs.c, g_level [0x026C:0x026D] (see note below); the TPM1 overflow ISR
 * (Backlight_Isr, 0xF3B7) loads it into the compare register TPM1C2V so the
 * LED duty tracks the commanded level smoothly.
 *
 * Note on g_level [0x026C]: this is the brightness the backlight PWM follows.
 * It is derived from ADC channel 0x0A via Coding_Normalize (inputs.c); on this
 * A6 C7 part channel 0x0A carries the dashboard dimming level, so g_level is
 * effectively the backlight dimming command.  The GPIO straps (inputs.c,
 * Coding_Calibrate) are the actual steering-wheel *variant* coding - they are
 * two different things that the earlier "coding" naming conflated; see
 * DEVICE.md.
 *
 * Addresses in brackets are the absolute flash/RAM addresses of the original.
 */
#include "app.h"

extern byte g_codingNormLo;   /* [0x026C] backlight level, low byte  */
extern byte g_codingNormHi;   /* [0x026D] backlight level, high byte */
extern byte g_codingNormOk;   /* [0x0265] 1 = level valid            */

byte g_blPending AT(0x0263);  /* re-init request latch */

/* ======================================================================
 * Backlight_Isr  [0xF3B7]   (TPM1 overflow vector)
 * On each TPM1 overflow, while the level is valid (g_codingNormOk), load the
 * backlight PWM compare with the inverted brightness (0x00C8 - level) so a
 * larger g_level means a dimmer LED, then clear the TPM1 overflow flag (TOF,
 * TPM1SC bit 0x80).
 * ====================================================================== */
INTERRUPT void Backlight_Isr(void)
{
    if (g_codingNormOk == 1) {
        word level = ((word)g_codingNormHi << 8) | g_codingNormLo;
        word pwm   = (word)0x00C8 - level;          /* inverted duty */
        TPM1C2VH = (byte)(pwm >> 8);
        TPM1C2VL = (byte)(pwm & 0xFF);
    }
    TPM1SC &= 0x7F;                                  /* clear TOF */
}

/* ======================================================================
 * Backlight_PwmOff  [0xF464]
 * Disable the PWM channel: drop PTF bit0, clear TPM1C2SC and park the compare
 * at full-off (0x00C8).
 * ====================================================================== */
void Backlight_PwmOff(void)
{
    PTFD    &= (byte)~0x01;
    TPM1C2SC = 0x00;
    PTFD    &= (byte)~0x01;
    TPM1C2VH = 0xC8;
    TPM1C2VL = 0x00;
}

/* ======================================================================
 * Backlight_Init  [0xF3F1]   (called from App_InitAll via sub_F3F1, 0xC574)
 * Park the PWM and clear the re-init request latch.
 * ====================================================================== */
void Backlight_Init(void)
{
    Backlight_PwmOff();           /* [0xF464] */
    g_blPending = 0;
}

/* ======================================================================
 * Backlight_IsOn  [0xF41A]
 * Returns 1 if the PWM channel is currently active (TPM1C2SC bit 0x20 set).
 * ====================================================================== */
byte Backlight_IsOn(void)
{
    return (TPM1C2SC & 0x20) ? 1 : 0;
}

/* ======================================================================
 * Backlight_Restart  [0xF428]
 * Re-arm the PWM channel: stop TPM1 briefly, and (when no re-init is pending)
 * re-enable edge-aligned PWM on channel 2 (TPM1C2SC = 0x24), park the compare
 * at 0xC8, reset the counter and mark the level valid.  Restores TPM1SC.
 * ====================================================================== */
void Backlight_Restart(void)
{
    byte saved = TPM1SC;          /* [0x01A6] */
    TPM1SC = 0x00;                /* stop the timer */

    if (g_blPending == 0) {
        g_codingNormOk = 0;
        PTFD    &= (byte)~0x01;
        TPM1C2VH = 0xC8;
        TPM1C2VL = 0x00;
        TPM1C2SC = 0x24;          /* edge-aligned PWM, channel enable */
        TPM1CNTL = 0x55;          /* reset counter */
        g_codingNormOk = 1;
    }
    TPM1SC = saved;
}

/* ======================================================================
 * Backlight_Task  [0xF3F8]   (called from Task_10Ticks, 0xC6AD)
 * When a re-init is pending (g_blPending), park the PWM, pulse PTF bit0,
 * settle, clear the latch and restart the channel.  Always leaves PTF bit0
 * low on exit.
 * ====================================================================== */
void Backlight_Task(void)
{
    if (g_blPending != 0) {
        Backlight_PwmOff();       /* [0xF464] */
        PTFD |= 0x01;
        Delay_Loop(0x64);
        g_blPending = 0;
        Backlight_Restart();      /* [0xF428] */
    }
    PTFD &= (byte)~0x01;
}

/* ======================================================================
 * Backlight_Control  [0xE796]   (called from Task_10Ticks slots 1/3/5/7)
 * Turn the backlight on/off and set its level from the dimming command
 * g_dimLevel [0x02AA] and the enable gate [0x023C]:
 *   - dim command 0x7E ("off") or the gate not set -> level 0, PWM off;
 *   - otherwise the level is min(g_dimLevel, 0x50) written to [0x026E] and,
 *     if the PWM is not already running, the channel is (re)started.
 * The level [0x026E] is then scaled by Coding_Normalize into the PWM duty.
 * ====================================================================== */
extern byte g_dimLevel;              /* [0x02AA] */
extern byte g_codingRaw2;            /* [0x026E] backlight level */

void Backlight_Control(void)
{
    if (g_dimLevel == 0x7E || *(volatile byte *)0x023C != 1) {
        g_codingRaw2 = 0;
        Backlight_PwmOff();          /* [0xF464] */
        return;
    }

    g_codingRaw2 = (g_dimLevel < 0x65) ? g_dimLevel : 0x50;
    if (g_codingRaw2 == 0) {
        Backlight_PwmOff();          /* [0xF464] */
        return;
    }
    if (Backlight_IsOn() == 0) {     /* [0xF41A] */
        Backlight_Init();            /* [0xF3F1] */
        Coding_Normalize();          /* [0xE27D] level -> PWM duty */
        Backlight_Restart();         /* [0xF428] */
    }
}

/* ======================================================================
 * Backlight_SetGate  [0xE7CB]
 * Set the backlight enable gate [0x023C] (0 = force off).
 * ====================================================================== */
void Backlight_SetGate(byte on) { *(volatile byte *)0x023C = on; }
