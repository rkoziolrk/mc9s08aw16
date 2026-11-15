/*
 * lin_app.c - LIN application layer for the MC9S08AW16 MFL module: decode of
 *             the subscribed command frame, node supervision / bus-timeout,
 *             and the LIN error-state flags.  (AW16 counterpart of the AW32
 *             lin_signals.c command-decode + status path.)
 *
 * The node is a LIN slave.  The master writes a command frame whose bytes land
 * in the receive image at [0x01BD..0x01C8]; LinApp_DecodeCommand unpacks them
 * into the control variables that drive the detection engine (wheel_io.c) and
 * the backlight:
 *
 *   [0x01BD] lo nibble -> g_ctl02AE (detect duration)
 *   [0x01BD] hi nibble -> g_ctl02AF (drive level)
 *   [0x01BE] lo nibble -> g_ctl02B0 (drive-level table index)
 *   [0x01BE] b4        -> g_ctl02B1 (enable gate)
 *   [0x01BE] b5        -> g_ctl02B2 (busy/moving gate)
 *   [0x01BE] b6        -> g_ctl02B3 (trigger edge)
 *   [0x01C7] & 0x7F    -> g_dimLevel [0x02AA] (backlight dimming command)
 *   [0x01C8] b0        -> g_ctl02AB (enable bit)
 *
 * The LIN error/state flags live in g_linFlags [0x026B]:
 *   b0  bus-activity timeout / status request pending
 *   b1  (cleared on wake)
 *   b2  comms error latch (suppresses command decode)
 *
 * Addresses in brackets are the absolute flash/RAM addresses of the original.
 */
#include "app.h"

byte g_linFlags  AT(0x026B);   /* LIN error / state flags */
byte g_dimLevel  AT(0x02AA);   /* backlight dimming command from the bus */

/* received command-frame image (written by the LIN transport) */
extern byte g_rx01BD AT(0x01BD);
extern byte g_rx01BE AT(0x01BE);
extern byte g_rx01C7 AT(0x01C7);
extern byte g_rx01C8 AT(0x01C8);

/* control variables consumed by wheel_io.c (see there) */
extern byte g_ctl02AE AT(0x02AE);
extern byte g_ctl02AF AT(0x02AF);
extern byte g_ctl02B0 AT(0x02B0);
extern byte g_ctl02B1 AT(0x02B1);
extern byte g_ctl02B2 AT(0x02B2);
extern byte g_ctl02B3 AT(0x02B3);
byte g_ctl02AB AT(0x02AB);

/* node-supervision counters (LIN activity watchdog) */
extern byte g_statCount AT(0x01B6);   /* saturating status counter */

/* ---- LIN transport core (reconstructed elsewhere; externs for now) ---- */
void   Lin_ResetState(void);   /* [0xCD1B] */
void   LinNode_InitState(void);   /* [0xD65A] lin_core.c */
void   LinSched_Reset(void);       /* [0xD17B] lin_core.c */
void   LinFrame_SetIdle(void);     /* [0xE02C] lin_core.c */
void   LinFrame_RxStep(void);      /* [0xE037] lin_core.c */
void   LinSched_Tick(void);        /* [0xD191] lin_core.c */
void   LinNode_SchedTick(void);    /* [0xD722] lin_core.c */
byte   LinNode_SetMode(byte mode); /* [0xD6D2] lin_core.c */

/* ======================================================================
 * LinApp_DecodeCommand  [0xCC7E]   (called from Task_10Ticks slots 0/2/4/6/8)
 * Unpack the subscribed command frame into the detection/backlight control
 * variables.  While the comms-error latch (g_linFlags b2) is set, decoding is
 * suppressed and the dimming level is forced to its default (0x50).
 * ====================================================================== */
void LinApp_DecodeCommand(void)
{
    if (g_linFlags & 0x04) {               /* comms error -> safe defaults */
        g_dimLevel = 0x50;
        return;
    }

    g_dimLevel = (byte)(g_rx01C7 & 0x7F);  /* dimming level          */
    g_ctl02AF  = (byte)(g_rx01BD >> 4);    /* drive level (hi nibble)*/
    g_ctl02AE  = (byte)(g_rx01BD & 0x0F);  /* detect duration        */
    g_ctl02B0  = (byte)(g_rx01BE & 0x0F);  /* table index            */
    g_ctl02B3  = (byte)((g_rx01BE >> 6) & 0x01);   /* trigger edge   */
    g_ctl02B2  = (byte)((g_rx01BE >> 5) & 0x01);   /* busy gate      */
    g_ctl02AB  = (byte)(g_rx01C8 & 0x01);          /* enable bit     */
    g_ctl02B1  = (byte)((g_rx01BE >> 4) & 0x01);   /* enable gate    */
}

/* ======================================================================
 * Supervise_Tick  [0xCCFC]   (called from Task_10Ticks slot 9)
 * Increment the 16-bit no-activity timer [0x01B3:0x01B4], saturating at
 * 0xFFFF.
 * ====================================================================== */
void Supervise_Tick(void)
{
    word t = ((word)(*(volatile byte *)0x01B3) << 8) | *(volatile byte *)0x01B4;
    if (t < 0xFFFF) {
        t++;
        *(volatile byte *)0x01B3 = (byte)(t >> 8);
        *(volatile byte *)0x01B4 = (byte)(t & 0xFF);
    }
}

/* ======================================================================
 * Supervise_Task  [0xCCD3]   (called from Task_25Ticks)
 * Run the LIN schedule tick (LinNode_SchedTick), bump the saturating status counter
 * [0x01B6], and if the no-activity timer [0x01B3:0x01B4] has passed the
 * configured limit [0x0191:0x0192] raise the bus-timeout flag (g_linFlags b0).
 * ====================================================================== */
void Supervise_Task(void)
{
    word limit, elapsed;

    LinNode_SchedTick();                            /* [0xD722] LIN schedule tick */

    if (g_statCount < 0xFF) {
        g_statCount++;
    }

    limit   = ((word)(*(volatile byte *)0x0191) << 8) | *(volatile byte *)0x0192;
    elapsed = ((word)(*(volatile byte *)0x01B3) << 8) | *(volatile byte *)0x01B4;
    if (elapsed >= limit) {
        g_linFlags |= 0x01;                /* bus-activity timeout */
    }
}

/* ======================================================================
 * Lin_Housekeep  [0xCD0A]   (called from Task_10Ticks)
 * Per-10ms LIN housekeeping: run the receive/frame step (LinFrame_RxStep) then the
 * schedule/response handler (LinSched_Tick).
 * ====================================================================== */
void Lin_Housekeep(void)
{
    LinFrame_RxStep();                /* [0xE037] */
    LinSched_Tick();                /* [0xD191] */
}

/* ======================================================================
 * LinApp_Init  [0xCC56]   (called from App_InitAll, 0xC58C)
 * Re-initialise the LIN application/transport: reset the protocol state,
 * clear the frame handlers and the comms-error latch (g_linFlags b2), all
 * under a critical section.
 * ====================================================================== */
void LinApp_Init(void)
{
    *(volatile byte *)0x01B7 = 0;
    EnterCritical();
    Lin_ResetState();          /* [0xCD1B] */
    LinNode_InitState();                /* [0xD65A] */
    LinSched_Reset();                /* [0xD17B] */
    LinFrame_SetIdle();                /* [0xE02C] */
    g_linFlags &= (byte)~0x04; /* clear comms-error latch */
    LinNode_SetMode(2);               /* [0xD6D2] */
    ExitCritical();
}

/* NOTE: the comms-error latch setter at 0xCA41 (g_linFlags b2) is already
 * reconstructed as LinErr_Set() in lin_transport.c. */
