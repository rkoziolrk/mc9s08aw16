/*
 * sensor.c - ADC analogue front-end + single-conversion read.
 *            Sensor_Init (0xE229), Adc_Read (0xE246).
 */
#include "app.h"

/* ======================================================================
 * Sensor_Init  [0xE229]
 * ADC1: long sample, bus/2, 8-bit (ADC1CFG=0x41), SW trigger / compare off,
 * enable the analogue function on AD0..AD3 (APCTL1=0x0F), clear compare regs.
 * ====================================================================== */
void Sensor_Init(void)
{
    ADC1CFG = 0x41;
    ADC1SC2 = 0x00;
    APCTL1  = 0x0F;
    APCTL2  = 0x0F >> 1;   /* LSRA of 0x0F = 0x07 */
    APCTL3  = 0x00;
    ADC1CVL = 0x00;
    ADC1CVH = 0x00;
}

/* ======================================================================
 * Adc_Read  [0xE246]
 * Start a single SW-triggered conversion on 'channel' (masked to 5 bits);
 * channel 0x1F powers the ADC down and returns 0xFF. Otherwise wait for
 * COCO and return the 8-bit result (ADC1RL).
 * ====================================================================== */
byte Adc_Read(byte channel)
{
    channel &= 0x1F;
    if (channel == 0x1F) {
        ADC1SC1 = 0x1F;
        return 0xFF;
    }
    ADC1SC1 = channel;
    Delay_Loop(2);
    while ((ADC1SC1 & ADC_SC1_COCO) == 0) {
    }
    return ADC1RL;
}
