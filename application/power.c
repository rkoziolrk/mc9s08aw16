/*
 * power.c - Low-power (STOP) sleep entry and the power/bus-timeout task for
 *           the MC9S08AW16 MFL module.
 *
 * When the master stops polling, the node saves its state and goes to sleep;
 * any enabled wake source (LIN activity) brings it back through a full
 * re-init.  Addresses in brackets are the absolute flash/RAM addresses of the
 * original.
 */
#include "app.h"

#if defined(AW16_HOSTCHECK)
#  define CPU_SEI()   ((void)0)
#  define CPU_STOP()  ((void)0)
#else
#  define CPU_SEI()   __asm__("sei")
#  define CPU_STOP()  __asm__("stop")
#endif

extern byte g_linFlags AT(0x026B);

void Nvm_RequestSave(void);     /* [0xC841] queue a configuration save */
void Backlight_SetGate(byte on);/* [0xE7CB] set the backlight enable gate [0x023C] */

/* ======================================================================
 * Sci_Disable  [0xCD10]
 * Disable the SCI1 transmitter/receiver (SCI1C2 = 0) before sleep.
 * ====================================================================== */
void Sci_Disable(void)
{
    SCI1C2 = 0x00;
}

/* ======================================================================
 * Tick_Advance  [0xC5DE]
 * Add 'ticks' to the time base counter (mod 100) under a critical section,
 * used to re-align the scheduler after a blocking flash operation.
 * ====================================================================== */
void Tick_Advance(byte ticks)
{
    EnterCritical();
    g_tickCount = (byte)((g_tickCount + ticks) % 100);
    ExitCritical();
}

/* ======================================================================
 * Wake_SetRequest  [0xC5CA]   (called from the LIN layer, 0xC974)
 * OR the wake-source bits into [0x0102] and set/clear the sleep-request bit
 * [0x0100] b1 from the running count (dbnza: set when the arg decrements to a
 * non-zero value).
 * ====================================================================== */
void Wake_SetRequest(byte bits)
{
    *(volatile byte *)0x0102 |= bits;
    if ((byte)(bits - 1) != 0) {
        *(volatile byte *)0x0100 |= 0x02;
    } else {
        *(volatile byte *)0x0100 &= (byte)~0x02;
    }
}

/* ======================================================================
 * Sleep_Enter  [0xC6BD]
 * Enter STOP: mask interrupts, disable the SCI, put the pins into their
 * low-power state, STOP, and on wake run the full App_InitAll and clear the
 * power-state byte [0x0100].
 * ====================================================================== */
void Sleep_Enter(void)
{
    CPU_SEI();                 /* [0xC6BD] mask interrupts                    */
    Sci_Disable();             /* [0xCD10] */
    Ports_SleepIo();           /* [0xF385] */
    Ports_SleepDir();          /* [0xF39B] */
    CPU_STOP();                /* [0xC6C7] wait for a wake source             */
    App_InitAll();             /* [0xC6C8] full re-init on wake */
    *(volatile byte *)0x0100 = 0;
}

/* ======================================================================
 * Power_Task  [0xC5A1]   (called from Task_10Ticks slot 9)
 * If a sleep request is pending ([0x0100] b1) go to sleep.  Otherwise, on a
 * LIN bus-activity timeout (g_linFlags b0), queue a configuration save, turn
 * the backlight gate off and latch the "saved" flag [0x0101] so it happens
 * once per timeout.
 * ====================================================================== */
void Power_Task(void)
{
    if (*(volatile byte *)0x0100 & 0x02) {
        Sleep_Enter();                      /* [0xC6BD] */
    }

    if ((g_linFlags & 0x01) && *(volatile byte *)0x0101 == 0) {
        *(volatile byte *)0x0100 = 0x01;
        Nvm_RequestSave();                  /* [0xC841] */
        Backlight_SetGate(0);               /* [0xE7CB] */
        *(volatile byte *)0x0101 = 0x01;
    }
}
