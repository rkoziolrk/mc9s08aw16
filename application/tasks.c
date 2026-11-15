/*
 * tasks.c - The periodic tasks dispatched by the cooperative scheduler
 *           (Scheduler_Run in main.c) on the MC9S08AW16 MFL module.
 *
 * The time base ticks at 1 ms (TPM2 CH0); Scheduler_Run runs the three
 * periodic tasks at their divisors:
 *     Task_2Ticks   every  2 ticks  [0xC644]
 *     Task_10Ticks  every 10 ticks  [0xC64A]   (round-robin over 10 slots)
 *     Task_25Ticks  every 25 ticks  [0xC6B7]
 *
 * Addresses in brackets are the absolute flash/RAM addresses of the original.
 */
#include "app.h"

extern byte g_slot10 AT(0x01A2);   /* 1..10 round-robin slot counter */

/* ---- callees (lin_app.c reconstructs the LIN-application ones) --------- */
/* all slot callees are prototyped in app.h now; just the slot-4 latch here */
extern byte g_heatReq AT(0x0266);   /* heating request latch (slot 4) */

/* ======================================================================
 * Task_2Ticks  [0xC644]
 * Sample the backlight dimming input (Coding_Sample) and service the COP.
 * ====================================================================== */
void Task_2Ticks(void)
{
    Coding_Sample();            /* [0xF80A] */
    COP_Feed();                 /* [0xC739] */
}

/* ======================================================================
 * Task_10Ticks  [0xC64A]
 * The main 10 ms task.  Each run it advances the round-robin slot, services
 * the flash task, the LIN housekeeping, the coding/wheel detection and the
 * button scan, then runs the slot-specific work.  The slot table (flash
 * 0xC665, index = g_slot10-1, 10 entries) selects:
 *     slots 0,2,6 : LinApp_DecodeCommand
 *     slots 1,3,5,7 : Backlight_Control + SelfTest_Task
 *     slot 4 : Heating_Task + LinApp_DecodeCommand (+ clear heat request)
 *     slot 8 : LinApp_DecodeCommand + Port_Refresh
 *     slot 9 : Heating_Task + SelfTest_Task + Power_Task + Supervise_Tick +
 *              Backlight_Task
 * ====================================================================== */
void Task_10Ticks(void)
{
    g_slot10++;

    NvmTask_Run();              /* [0xC6F6] */
    Lin_Housekeep();           /* [0xCD0A] */
    Detect_Task();             /* [0xE337] coding/wheel detection */
    Buttons_Scan();            /* [0xE7F8] button scan + debounce */

    if ((byte)(g_slot10 - 1) < 0x0A) {
        switch ((byte)(g_slot10 - 1)) {
        case 0: case 2: case 6:            /* [0xC67B] */
            LinApp_DecodeCommand();
            break;
        case 1: case 3: case 5: case 7:    /* [0xC680] */
            Backlight_Control();
            SelfTest_Task();
            break;
        case 4:                            /* [0xC688] */
            Heating_Task();
            LinApp_DecodeCommand();
            if (g_heatReq == 1) {
                g_heatReq = 0;
            }
            break;
        case 8:                            /* [0xC699] */
            LinApp_DecodeCommand();
            Port_Refresh();
            break;
        case 9:                            /* [0xC6A1] */
            Heating_Task();
            SelfTest_Task();
            Power_Task();
            Supervise_Tick();
            Backlight_Task();
            break;
        default:
            break;
        }
    } else {
        g_slot10 = 0;                      /* [0xC6B0] wrap */
    }

    NvmTask_Run();             /* [0xC6B4] tail service */
}

/* ======================================================================
 * Task_25Ticks  [0xC6B7]
 * Build the node status and decrement the soft timers.
 * ====================================================================== */
void Task_25Ticks(void)
{
    Supervise_Task();             /* [0xCCD3] */
    Timers_Tick();             /* [0xEC3A] */
}
