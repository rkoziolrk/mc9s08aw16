/*
 * wheel_io.c - Steering-wheel resistor read-out engine for the MC9S08AW16
 *              MFL module: the drive/excitation PWM ISR, the coding/ladder
 *              measurement helpers and the detection state machine.
 *
 * This is the AW16 counterpart of the AW32 `wheel_io.c` (Scan_Isr / the
 * ladder self-test / plausibility engine).  The module drives an excitation
 * output (PTED bit 0x04, with PTFD bit 0x10 as the complementary enable),
 * samples the coding divider (ADC ch 0x0A) and the button/scroll resistor
 * ladder (ADC ch 0x02), and runs a background state machine that decides
 * whether a plausible coded steering-wheel is connected.
 *
 * Signal / RAM map (absolute addresses verified against the image):
 *   Scan_Isr (0xE537, 1 ms)   software-PWM excitation waveform generator
 *   g_scanActive  [0x0239]    1 = waveform running
 *   g_scanCounter [0x0238]    PWM counter
 *   g_scanPeriod  [0x023A]    PWM period
 *   g_scanCompare [0x023B]    PWM compare (duty)
 *   g_scanPhase   [0x0237]    post-pulse settle phase
 *   g_measStatus  [0x0234]    plausibility status bits (b0 hi-side, b1 ratio,
 *                             b2 lo-side)
 *   g_ladderA/B   [0x0235/0x0236]   ladder ADC samples
 *   g_detTimer    [0x0231:0x0232]   16-bit detection timer (big-endian)
 *   g_codingState    [0x0233]    state machine state (0..8)
 *   g_detEdge     [0x0230]    one-shot edge latch
 *   g_detSel      [0x022F]    selected drive level (from table 0x0120)
 *
 * The compiler's fixed-point runtime (0xFE2A etc.) is called by address where
 * the original used it; those spots are transcriptions of the control flow,
 * not bit-exact reimplementations of the math library.
 */
#include "app.h"

/* ---- excitation / measurement state (RAM) ---------------------------- */
byte g_scanActive  AT(0x0239);
byte g_scanCounter AT(0x0238);
byte g_scanPeriod  AT(0x023A);
byte g_scanCompare AT(0x023B);
byte g_scanPhase   AT(0x0237);
byte g_measStatus  AT(0x0234);
byte g_ladderA     AT(0x0235);
byte g_ladderB     AT(0x0236);
byte g_detTimerHi  AT(0x0231);   /* 16-bit timer, high byte */
byte g_detTimerLo  AT(0x0232);   /* 16-bit timer, low byte  */
byte g_detEdge     AT(0x0230);
byte g_detSel      AT(0x022F);

/* shared with inputs.c */
extern byte g_codingState;       /* [0x0233] */
extern byte g_codingValid;       /* [0x029E] */
extern byte g_codingAdc;         /* [0x0267] filtered coding sample */

/* configuration / control block (loaded from NVM/LIN, see inputs.c) */
extern byte g_cfg019C AT(0x019C);
extern byte g_ctl02AE AT(0x02AE);   /* detect duration / threshold */
extern byte g_ctl02AF AT(0x02AF);   /* base drive level            */
extern byte g_ctl02B0 AT(0x02B0);   /* drive-level table index      */
extern byte g_ctl02B1 AT(0x02B1);   /* enable gate 1               */
extern byte g_ctl02B2 AT(0x02B2);   /* "busy/moving" gate          */
extern byte g_ctl02B3 AT(0x02B3);   /* trigger edge input          */
extern byte g_ctl0180 AT(0x0180);   /* window-size control         */

/* excitation drive pins */
#define DRIVE_HI()   (PTED |=  0x04)   /* PTE2 high-side excitation on  */
#define DRIVE_LO()   (PTED &= ~0x04)   /* PTE2 off                      */
#define ENABLE_OFF() (PTFD &= ~0x10)   /* PTF4 complementary enable off */
#define ENABLE_ON()  (PTFD |=  0x10)   /* PTF4 complementary enable on  */

/* ======================================================================
 * Drive_Off  [0xE649]
 * Stop the excitation waveform and release both drive pins.
 * ====================================================================== */
void Drive_Off(void)
{
    g_scanActive = 0;
    DRIVE_LO();
    ENABLE_OFF();
}

/* ======================================================================
 * Meas_ClearStatus  [0xE65C]
 * ====================================================================== */
void Meas_ClearStatus(void)
{
    g_measStatus = 0;
}

/* ======================================================================
 * Meas_LadderRatio  [0xE661]
 * Evaluate the two ladder samples: with g_ladderB == 0, or the quotient
 * g_ladderA / g_ladderB below 8, the "ratio low/short" status bit (b1) is
 * set; a quotient >= 8 clears it.  Returns the full status byte.
 * ====================================================================== */
byte Meas_LadderRatio(void)
{
    if (g_ladderB != 0) {
        byte q = (byte)(g_ladderA / g_ladderB);
        if (q >= 8) {
            g_measStatus &= (byte)~0x02;
        } else {
            g_measStatus |= 0x02;
        }
    } else {
        g_measStatus |= 0x02;
    }
    return g_measStatus;
}

/* ======================================================================
 * Meas_LowSide  [0xE6E4]
 * With the drive off, read the coding channel (0x0A) then the ladder (0x02).
 * If the coding/ladder quotient is >= 5 the "low-side open" bit (b2) is set
 * and 0 (plausible) is returned; otherwise 1 (implausible) is returned.
 * ====================================================================== */
byte Meas_LowSide(void)
{
    byte coding, sample, result = 1;

    Drive_Off();
    coding = Adc_Read(0x0A);
    Delay_Loop(0xF0);
    sample = Adc_Read(0x02);

    g_measStatus &= (byte)~0x01;       /* clear hi-side bit */
    if (sample != 0) {
        if ((byte)(coding / sample) >= 5) {
            g_measStatus |= 0x04;      /* low-side open */
            result = 0;
        }
    }
    return result;
}

/* ======================================================================
 * Meas_HighSide  [0xE67F]
 * Drive the high-side, read coding (0x0A) and ladder (0x02).  Set the
 * hi-side status bit (b0); if (coding << 3) is at least the ladder value
 * plus 0x12 (plausible loaded divider) the bit is cleared again and 0 is
 * returned, otherwise 1.  Releases the drive on exit.
 * ====================================================================== */
byte Meas_HighSide(void)
{
    byte coding, result = 1;
    word lhs;

    DRIVE_HI();
    ENABLE_OFF();
    coding = Adc_Read(0x0A);
    Delay_Loop(0xF0);
    g_ladderA = Adc_Read(0x02);

    g_measStatus |= 0x01;              /* assume hi-side fault */
    if (g_ladderA != 0) {
        lhs = (word)coding << 3;       /* coding * 8 [0xE6BA rolx chain] */
        /* plausible if (coding<<3) - (ladder + 0x12) does not borrow
         * [0xE6C7-0xE6D0 via the fixed-point runtime at 0xFE2A] */
        if (lhs >= (word)(g_ladderA + 0x12)) {
            g_measStatus &= (byte)~0x01;
            result = 0;
        }
    }
    Drive_Off();
    return result;
}

/* ======================================================================
 * Meas_Ladder2  [0xE729]
 * Two-point ladder read: sample ch 0x02, settle, sample again, run both
 * through the running-average filter (0xF4AB) accumulating into g_ladderB
 * via the scratch pair [0x0106/0x0107].
 * ====================================================================== */
void Meas_Ladder2(void)
{
    g_ladderB = Adc_Read(0x02);                 /* [0xE72F] */
    Delay_Loop(0x1E);
    *(volatile byte *)0x0107 = Adc_Read(0x02);  /* [0xE73E] */
    g_ladderB = Filter_Avg(g_ladderB, *(volatile byte *)0x0107, 1);  /* [0xF4AB] */
    Delay_Loop(0x1E);
    *(volatile byte *)0x0107 = Adc_Read(0x02);  /* [0xE768] */
    g_ladderB = Filter_Avg(g_ladderB, *(volatile byte *)0x0107, 1);  /* [0xF4AB] */
}

/* ======================================================================
 * Drive_PwmSetup  [0xE5A7]   (compare = base level, period 0x19)
 * Arm the excitation PWM with the given compare value.  A value below 0x1A
 * is treated as "parked" (compare 0x0A, period 0x19, waveform off).
 * ====================================================================== */
void Drive_PwmSetup(byte compare)
{
    if (compare < 0x1A) {
        g_scanCompare = 0x0A;
        g_scanPeriod  = 0x19;
        return;
    }
    if (compare != 0) {
        g_scanActive  = 1;
        g_scanCompare = compare;
        g_scanPeriod  = 0x19;
        g_scanCounter = 0;
        DRIVE_HI();
    } else {
        g_scanActive  = 0;
        DRIVE_LO();
    }
    ENABLE_OFF();
}

/* ======================================================================
 * Drive_PwmSetup2  [0xE5EC]   (period 0x14 variant, park compare 0x0C)
 * ====================================================================== */
void Drive_PwmSetup2(byte compare)
{
    if (compare < 0x15) {
        g_scanCompare = 0x0C;
        g_scanPeriod  = 0x14;
        return;
    }
    if (compare != 0) {
        g_scanActive  = 1;
        g_scanCompare = compare;
        g_scanPeriod  = 0x14;
        g_scanCounter = 0;
        DRIVE_HI();
    } else {
        g_scanActive  = 0;
        DRIVE_LO();
    }
    ENABLE_OFF();
}

/* ======================================================================
 * Drive_Stop  [0xE631]
 * Stop the waveform, release the pins and arm the settle phase (0x0237=4).
 * ====================================================================== */
void Drive_Stop(void)
{
    g_scanActive = 0;
    DRIVE_LO();
    ENABLE_OFF();
    g_scanPhase = 0x04;
}

/* ======================================================================
 * Scan_Isr  [0xE537]   (1 ms, called from the TPM tick at 0xC788)
 * Software-PWM generator for the excitation output and its post-pulse
 * settle phase:
 *   - while g_scanActive: toggle PTE2 by comparing g_scanCounter against the
 *     compare (g_scanCompare) and period (g_scanPeriod) thresholds, wrapping
 *     the counter at the period; PTF4 is held low during the pulse.
 *   - when idle: run down the settle phase g_scanPhase, kicking the two-point
 *     ladder read (Meas_Ladder2) and raising PTF4 at the end.
 * ====================================================================== */
INTERRUPT void Scan_Isr(void)
{
    if (g_scanActive != 0) {
        if (g_scanCounter >= g_scanPeriod) {
            /* period elapsed: restart the pulse */
            DRIVE_HI();
            ENABLE_OFF();
            g_scanCounter = 0;
        } else if (g_scanCounter < g_scanCompare) {
            DRIVE_HI();                /* within the duty window */
            ENABLE_OFF();
        } else {
            DRIVE_LO();                /* past the duty window */
            ENABLE_OFF();
        }
        g_scanCounter++;
        return;
    }

    /* waveform idle: settle-phase sequencer */
    if (g_scanPhase < 0x02) {
        DRIVE_LO();
        ENABLE_OFF();
        if (g_scanPhase != 0) {
            g_scanPhase--;
        }
    } else if (g_scanPhase == 0x02) {
        Meas_Ladder2();                /* [0xE729] two-point ladder read */
        DRIVE_LO();
        ENABLE_ON();                   /* raise PTF4 */
        g_scanPhase = 0;
    }
}

/* ======================================================================
 * Detect_Init  [0xE517]   (called from App_InitAll, 0xC586)
 * Reset the detection/measurement engine to its idle state.
 * ====================================================================== */
void Detect_Init(void)
{
    g_scanCompare = 0;
    g_scanPeriod  = 0;
    g_scanCounter = 0;
    g_scanPhase   = 0;
    g_ladderA     = 0x01;
    g_ladderB     = 0xFF;
    g_scanActive  = 0;
    Meas_ClearStatus();                /* [0xE65C] */
    Drive_Off();                       /* [0xE649] */
}

/* ======================================================================
 * Detect_Timer  [0xE348]
 * 16-bit up-counter at [0x0231:0x0232]; saturates/resets to 0 at 0xFFFF.
 * ====================================================================== */
static void Detect_Timer(void)
{
    word t = ((word)g_detTimerHi << 8) | g_detTimerLo;
    if (t < 0xFFFF) {
        t++;
        g_detTimerHi = (byte)(t >> 8);
        g_detTimerLo = (byte)(t & 0xFF);
    } else {
        g_detTimerHi = 0;
        g_detTimerLo = 0;
    }
}

/* small helpers for the 16-bit timer */
static word Det_Timer(void) { return ((word)g_detTimerHi << 8) | g_detTimerLo; }
static void Det_TimerReset(void) { g_detTimerHi = 0; g_detTimerLo = 0; }   /* [0xE50F] */

/* ======================================================================
 * Detect_StateMachine  [0xE35E]
 * Sequences a coding-resistor measurement.  Switch on g_codingState (0..8); a
 * state >= 9 resets.  The table at flash 0xE36C maps each state to its
 * handler:
 *   0 idle/trigger   -> arm drive / go measure (state 1 or 6)
 *   1 pre-charge     -> pick level from table 0x0120, state 2
 *   2 settle         -> wait window, stop drive, state 3
 *   3 first measure  -> ladder ratio; present (8) / retry (4/5)
 *   4 retry          -> re-arm (state 1) or time out (state 0)
 *   5 timeout branch -> state 0 or re-trigger (6)
 *   6 full plausib.  -> low+high side + ratio; present (8) / fail (0)
 *   7 (unused slot)
 *   8 present        -> latch g_codingValid = 1
 * This is a faithful transcription of the branch structure at 0xE381-0xE50D.
 * ====================================================================== */
void Detect_StateMachine(void)
{
    if (g_codingState >= 9) {             /* out of range -> reset [0xE366] */
        Drive_Off();
        g_codingState = 0;
        return;
    }

    switch (g_codingState) {
    case 0:                            /* [0xE381] idle / trigger */
        Drive_Off();
        if (g_ctl02B2 == 1 && g_ctl02B1 == 1 &&
            g_codingAdc >= 0x6F && g_codingAdc < 0xD1) {
            if (g_ctl02AE != 0) {
                Drive_PwmSetup((byte)(g_ctl02AF + 0x0A));   /* [0xE5A7] */
            } else {
                g_detTimerLo = 0x0F;   /* timer = 0x000F */
                g_detTimerHi = 0x00;
            }
            g_codingState = 1;
            Det_TimerReset();          /* [0xE50F] */
        } else {
            if (g_ctl02B3 == 1 && g_detEdge == 0 &&
                g_codingAdc >= 0x6F && g_codingAdc < 0xD1) {
                g_codingState = 6;
            }
            if (g_ctl02B3 != 0) {
                return;                /* wait for the edge to clear */
            }
            g_detEdge = 0;
        }
        break;

    case 1:                            /* [0xE3E2] pre-charge */
        if (Det_Timer() >= 0x0F && Det_Timer() <= g_ctl02AE) {
            byte idx = (byte)((g_ctl02B0 & 0x0F) + 0x61);
            g_detSel = *(volatile byte *)(0x0120 + idx);   /* table 0x0120 */
            Drive_PwmSetup2(g_detSel);  /* [0xE5EC] */
            Det_TimerReset();
            g_codingState = 2;
        }
        break;

    case 2:                            /* [0xE415] settle */
        if (((word)g_ctl0180 << 2) <= Det_Timer() || g_ctl02B2 == 0) {
            Drive_Off();
            Delay_Loop(0xFA);
            Drive_Stop();              /* [0xE631] */
            Det_TimerReset();
            g_codingState = 3;
        }
        break;

    case 3:                            /* [0xE448] first measure */
        if (Meas_LadderRatio() != 0) { /* [0xE661] */
            g_codingState = 8;
            Drive_Off();
        } else if (Det_Timer() >= 0x32) {
            Drive_Off();
            g_codingState = 5;
        } else if (g_ctl02B2 == 0) {
            g_codingState = 4;
        }
        break;

    case 4:                            /* [0xE47A] retry */
        if (g_ctl02B2 == 1) {
            Drive_Off();
            Delay_Loop(0xFA);
            Drive_PwmSetup((byte)(g_ctl02AF + 0x0A));   /* [0xE5A7] */
            Det_TimerReset();
            g_codingState = 1;
        } else if (Det_Timer() >= 0x32) {
            Drive_Off();
            g_codingState = 0;
        }
        break;

    case 5:                            /* [0xE4AB] timeout branch */
        if (g_ctl02B2 == 0) {
            g_codingState = 0;
            Drive_Off();
        } else {
            if (g_ctl02B3 == 1 && g_detEdge == 0) {
                g_codingState = 6;
            }
            if (g_ctl02B3 == 0) {
                g_detEdge = 0;
            }
        }
        break;

    case 6:                            /* [0xE4D1] full plausibility */
        Meas_LowSide();                /* [0xE6E4] */
        Meas_HighSide();               /* [0xE67F] */
        if (Meas_LadderRatio() != 0) { /* [0xE661] */
            Drive_Off();
            g_codingValid = 1;
            g_codingState = 8;
        } else {
            g_codingValid = 0;
            Drive_Off();
            g_codingState = 0;
        }
        g_detEdge = 1;
        break;

    case 7:                            /* [0xE4CF] unused slot */
        break;

    case 8:                            /* [0xE4FB] present */
        Drive_Off();
        g_codingValid = 1;
        break;

    default:
        break;
    }
}

/* ======================================================================
 * Detect_Task  [0xE337]   (called from Task_10Ticks, 0xC654)
 * If the coding input is disabled (state bit [0x019C] b0 = 0) the coding is
 * forced valid and nothing is measured; otherwise advance the detection
 * timer and run the state machine.
 * ====================================================================== */
void Detect_Task(void)
{
    if ((g_cfg019C & 0x01) == 0) {
        g_codingValid = 1;
        return;
    }
    Detect_Timer();                    /* [0xE348] */
    Detect_StateMachine();             /* [0xE35E] */
}
