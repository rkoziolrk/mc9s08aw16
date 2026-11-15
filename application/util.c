/*
 * util.c - nestable critical sections and the calibrated delay
 *          (EnterCritical 0xF5E6, ExitCritical 0xF5F3, Delay_Loop 0xF497).
 */
#include "app.h"

byte g_criticalNesting AT(0x0109);   /* [0x0109] interrupt-disable nesting depth */

/* ======================================================================
 * EnterCritical [0xF5E6] / ExitCritical [0xF5F3]
 * Global nestable interrupt lock: SEI on first enter, CLI when the last
 * matching exit brings the depth back to 0 (depth saturates at 0x7E/0x7F).
 * ====================================================================== */
void EnterCritical(void)
{
    DisableInterrupts();
    if (g_criticalNesting < 0x7E) {
        g_criticalNesting++;
    }
}

void ExitCritical(void)
{
    if (g_criticalNesting != 0 && g_criticalNesting < 0x7F) {
        g_criticalNesting--;
    }
    if (g_criticalNesting == 0) {
        EnableInterrupts();
    }
}

/* ======================================================================
 * Delay_Loop [0xF497]
 * Calibrated busy-wait: counts H:X (seeded from A, high byte cleared) down
 * to zero, padded with BRN (branch-never) instructions for fixed timing.
 * Used for ADC settling and short hardware delays.
 * ====================================================================== */
byte Delay_Loop(word count)
{
    volatile word i = count & 0x00FF;
    while (i != 0) {
        i--;
    }
    return 0;
}
