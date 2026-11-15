/*
 * heating.c - Steering-wheel heating control for the MC9S08AW16 MFL module
 *             (the AW16 counterpart of the AW32 heating.c).
 *
 * The heated steering wheel is an optional feature (enabled by the equipment
 * bits in the state byte [0x019C]).  A NTC temperature sensor is read on ADC
 * channel 0x03 with open/short detection, low-pass filtered and mapped through
 * the interpolation table at flash 0x0164 into the heating-output level
 * g_heatOut [0x02A0].  A start-up blanking timer g_heatTimer [0x0264] holds the
 * output in the "ramp" state (0xFE) for a few ticks after enable.
 *
 * Output encoding of g_heatOut [0x02A0]:
 *   0xFF  feature disabled / NTC open  (no heating)
 *   0xFE  ramp / blanked (start-up timer running)
 *   0xFD  NTC short
 *   else  commanded heating level from the NTC curve
 *
 * The feature gate is (state[0x019C] & 0x06): the heating path runs only when
 * those bits read 0x02 or 0x06 (equipped + enabled).
 *
 * Addresses in brackets are the absolute flash/RAM addresses of the original.
 */
#include "app.h"

byte g_heatOut   AT(0x02A0);   /* heating output level */
byte g_heatTimer AT(0x0264);   /* start-up blanking timer */

extern byte g_cfg019C AT(0x019C);

/* NTC running-average accumulator [0x010A] and interpolation table [0x0164] */
#define HEAT_NTC_ACC  (*(volatile byte *)0x010A)
byte Table_Interp(const byte *table, byte x);   /* [0xF535] */

/* ======================================================================
 * Heating_OutputInit  [0xF607]   (called from App_InitAll, 0xC589)
 * Sets the heating output to its idle default: disabled (0xFF) unless the
 * equipment gate is satisfied, in which case it starts in the "ramp" state
 * (0xFE) and arms the blanking timer (0x0264 = 6).
 * ====================================================================== */
void Heating_OutputInit(void)
{
    byte gate = (byte)(g_cfg019C & 0x06);
    if (gate == 0x02 || gate == 0x06) {
        g_heatOut   = 0xFE;            /* ramp */
        g_heatTimer = 0x06;
    } else {
        g_heatOut = 0xFF;             /* disabled */
    }
}

/* ======================================================================
 * Heating_Task  [0xF628]   (called from Task_10Ticks, slots 0xC688/0xC6A1)
 * Read the NTC on ADC ch 0x03, detect open/short, filter and map to the
 * heating output.  While the blanking timer runs the output is forced to the
 * "ramp" state (0xFE).  Returns/stores the new level in g_heatOut.
 * ====================================================================== */
void Heating_Task(void)
{
    byte gate = (byte)(g_cfg019C & 0x06);
    byte result;

    if (gate != 0x02 && gate != 0x06) {
        g_heatOut = 0xFF;             /* feature disabled */
        return;
    }

    {
        byte ntc = Adc_Read(0x03);
        if (ntc >= 0xF8) {
            result = 0xFD;            /* NTC short */
        } else if (ntc < 0x15) {
            result = 0xFF;            /* NTC open */
        } else {
            /* filter the NTC and map through the 0x0164 curve */
            HEAT_NTC_ACC = Filter_Avg(HEAT_NTC_ACC, ntc, 4);   /* [0xF4AB] */
            result = Table_Interp((const byte *)0x0164, HEAT_NTC_ACC);  /* [0xF535] */
        }
    }

    /* start-up blanking: hold "ramp" until the timer runs out */
    if (g_heatTimer != 0) {
        g_heatTimer--;
        result = 0xFE;
    }

    g_heatOut = result;
}
