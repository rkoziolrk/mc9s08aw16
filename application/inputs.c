/*
 * inputs.c - Steering-wheel coding / variant detection and the coding-channel
 *            acquisition chain for the MC9S08AW16 MFL module.
 *
 * This is the AW16 counterpart of the AW32 `adc.c` (Adc_DetectVariant /
 * Variant_ReadStraps).  The coding of which steering-wheel is fitted is read
 * two ways, exactly as on the AW32 part but with this image's own addresses:
 *
 *   1. an analogue "coding divider" on ADC channel 0x0A, sampled and low-pass
 *      filtered every 2 ticks (Coding_Sample, 0xF80A) into the filtered coding
 *      value g_codingAdc [0x0267], and
 *   2. a set of GPIO "strap" bits, read through the {portPtr,mask} triplet
 *      tables in flash at 0xFF71 and 0xFF74, packed into the coding bytes
 *      g_codingStrap[] [0x02BD,0x02BE] by Coding_Calibrate (0xF73F).
 *
 * NOTE (verified against THIS image, not copied from the AW32 sibling): the
 * AW16 does *not* contain the AW32's nine discrete ADC "variant bands".  It
 * uses a single validity window [0x6F,0xD1) on the coding channel (see
 * Coding_Probe / the detect state machine in wheel_io.c); a reading inside the
 * window with a plausible resistor measurement marks the wheel "present"
 * (g_codingValid [0x029E]); the finer equipment selection comes from the
 * strap bytes and the configuration block.  See DEVICE.md for the window in
 * volts at Vref = 5 V.
 *
 * Addresses in brackets are the absolute flash/RAM addresses of the original.
 */
#include "app.h"

/* ---- coding / variant state (RAM) ------------------------------------ */
byte g_codingAdc     AT(0x0267);   /* filtered coding-channel (ch 0x0A) value */
byte g_codingValid   AT(0x029E);   /* 1 = coding plausible / wheel present    */
byte g_codingState   AT(0x0233);   /* detect state machine state (wheel_io.c) */
byte g_codingNormLo  AT(0x026C);   /* normalised coding value, low byte       */
byte g_codingNormHi  AT(0x026D);   /* normalised coding value, high byte      */
byte g_codingNormOk  AT(0x0265);   /* 1 = g_codingNorm* valid                 */
byte g_codingRaw2    AT(0x026E);   /* secondary raw coding sample             */
byte g_codingBusy    AT(0x0266);   /* acquisition-in-progress guard           */
byte g_codingCalBusy AT(0x02B4);   /* 1 = calibration pending (F73F needed)   */
byte g_codingDelay   AT(0x02BA);   /* per-sample settling delay [0x02BA]      */
byte g_codingDelay2  AT(0x02BB);   /* strap settling delay [0x02BB]           */
byte g_codingStrap0  AT(0x02BD);   /* packed strap coding byte 0              */
byte g_codingStrap1  AT(0x02BE);   /* packed strap coding byte 1              */

/* configuration inputs read during calibration (loaded from NVM/LIN) */
extern byte g_cfg0198 AT(0x0198);
extern byte g_cfg0199 AT(0x0199);
extern byte g_cfg019A AT(0x019A);
extern byte g_cfg019C AT(0x019C);

/* running-average filter helper [0xF4AB]: folds 'sample' into 'acc' with the
 * given weight and returns the new accumulator value. */
byte Filter_Avg(byte acc, byte sample, byte weight);   /* [0xF4AB] */
/* per-sample strap interpolation/accumulate [0xF8A7] */
void Strap_Accumulate(byte index);                     /* [0xF8A7] */

/* CodeWarrior fixed-point runtime helpers used by the normaliser. These are
 * the compiler's own math library routines; we call them by address and treat
 * them as opaque scaling/÷ primitives (see reference/application.asm). */
extern byte  rt_div8(byte a, byte b);          /* [0xFD08] */
extern void  rt_mul_setup(void);               /* [0xFE2A] */
extern byte  rt_scale16(void);                 /* [0xFD5B] */
extern void  rt_scale_fold(void);              /* [0xFE77] */
extern int   rt_cmp_fp(const void *p);         /* [0xFDFC] */

/* measurement helpers live in wheel_io.c (the detect/drive engine) */
void Drive_Off(void);        /* [0xE649] */
byte Meas_LowSide(void);     /* [0xE6E4] */
byte Meas_HighSide(void);    /* [0xE67F] */

/* ======================================================================
 * Coding_Reset  [0xE271]   (called from App_InitAll)
 * Clears the normalised coding value and marks it "valid/known" (=1 means
 * the normaliser will treat the next sample as the first).
 * ====================================================================== */
void Coding_Reset(void)
{
    g_codingNormLo = 0;
    g_codingNormHi = 0;
    g_codingNormOk = 1;
}

/* ======================================================================
 * Coding_Normalize  [0xE27D]   (called from the sampler, 0xF83E/0xF897)
 * Scales the filtered coding value g_codingAdc into the 16-bit normalised
 * value g_codingNorm{Lo,Hi} using the compiler fixed-point runtime.
 *
 *   - if the raw value is out of the hard range (>= 0xD1 with the secondary
 *     sample count >= 3) it is clamped (0x04 low / out-of-range),
 *   - when the mode byte g_cfg019A == 1 the value is passed through the
 *     fixed-point scale (×0x5A / ÷0xA6, offset 0x1A, compared against the
 *     flash constant at 0xFF21, clamped to 0xC8),
 *   - otherwise it is simply doubled (g_codingRaw2 << 1).
 * The exact fixed-point arithmetic is the CodeWarrior math runtime; this is a
 * faithful transcription of the control flow, not a bit-exact reimplementation.
 * ====================================================================== */
void Coding_Normalize(void)
{
    g_codingNormOk = 0;

    /* out-of-range guard: high reading together with >=3 secondary samples */
    if (g_codingAdc >= 0xD1 && g_codingRaw2 >= 3) {
        g_codingNormLo = 0x04;         /* out-of-range marker */
        g_codingNormHi = 0x00;
        g_codingNormOk = 1;
        return;
    }

    if (g_cfg019A == 1) {
        /* fixed-point scaled path [0xE296-0xE2DB] */
        word scaled;
        byte q = rt_div8((byte)(g_codingAdc * 0x5A), 0xA6);  /* ×0x5A ÷0xA6 */
        (void)q;
        rt_mul_setup();                /* [0xFE2A] seed 0x40 scale */
        scaled = rt_scale16();         /* [0xFD5B] scale g_codingRaw2 */
        rt_scale_fold();               /* [0xFE77] */
        if (rt_cmp_fp((const void *)0xFF21) < 0) {   /* [0xFDFC] vs const */
            g_codingNormLo = 0xC8;     /* saturate */
            g_codingNormHi = 0x00;
        } else {
            g_codingNormLo = (byte)(scaled & 0xFF);
            g_codingNormHi = (byte)(scaled >> 8);
        }
    } else {
        /* linear path [0xE2DD]: normalised = raw << 1 */
        word v = (word)g_codingRaw2 << 1;
        g_codingNormLo = (byte)(v & 0xFF);
        g_codingNormHi = (byte)(v >> 8);
    }
    g_codingNormOk = 1;
}

/* ======================================================================
 * Coding_Probe  [0xE2FB]   (called from App_InitAll, 0xC583)
 * One-shot start-up probe of the coding channel: read ch 0x0A, require it in
 * the validity window [0x6F,0xD1), then confirm the resistor is plausible by
 * driving the low-side (Meas_LowSide) and high-side (Meas_HighSide) and
 * re-reading.  On success it records the coding-present flags
 * g_codingState=0x08, g_codingValid=1; on any failure both are cleared.
 * ====================================================================== */
void Coding_Probe(void)
{
    byte v = Adc_Read(0x0A);           /* read the coding divider */
    byte ok = 0;

    if (v >= 0x6F && v < 0xD1) {       /* inside the validity window */
        if (Meas_LowSide() != 0) {     /* [0xE6E4] low-side plausible */
            if (Meas_HighSide() != 0) {/* [0xE67F] high-side plausible */
                /* re-check the channel is still in-window */
                if (v >= 0x6F && v < 0xD1) {
                    g_codingState = 0x08;
                    ok = 1;
                }
            } else {
                g_codingState = 0x00;  /* high-side failed */
            }
        } else {
            g_codingState = 0x08;      /* low-side open -> coding present */
            ok = 1;
        }
        g_codingValid = ok;
    } else {
        g_codingState = 0x00;          /* out of window */
        g_codingValid = 0x00;
    }

    Drive_Off();                       /* [0xE649] release the drive pins */
}

/* ----------------------------------------------------------------------
 * GPIO strap-coding tables in flash (0xFF71 / 0xFF74): three bytes per
 * entry {portPtrHi, portPtrLo, mask}.  Decoded from the image:
 *   0xFF71: {0x000C=PTGD, 0x08}, {0x0006=PTDD, 0x08}, ...
 * The calibration routine walks these to build the packed strap bytes.
 * -------------------------------------------------------------------- */

/* ======================================================================
 * Coding_Calibrate  [0xF73F]   (called from App_InitAll 0xC580 and 0xF877)
 * Prepares the coding acquisition: drives PTAD bit0 high (excitation), picks
 * the settling delays g_codingDelay/g_codingDelay2 from the config bytes
 * g_cfg0199/g_cfg0198 (clamped to 0x19 / 0x23), then reads the two GPIO strap
 * groups through the flash triplet tables at 0xFF71 and 0xFF74, ANDing the
 * selected input bits into the packed coding bytes g_codingStrap0/1
 * [0x02BD/0x02BE].  Finally it clears the excitation and the calibration-busy
 * flag.
 * ====================================================================== */
void Coding_Calibrate(void)
{
    byte i;

    g_codingCalBusy = 1;
    PTAD |= 0x01;                      /* excitation on [0xF746] */

    /* settling delay from g_cfg0199 (0 or >=0x40 -> default 0x19) */
    if (g_cfg0199 == 0 || g_cfg0199 >= 0x40) {
        g_codingDelay = 0x19;
    } else {
        g_codingDelay = g_cfg0199;
    }

    /* strap settling delay from g_cfg0198 (window [0x47,0xC8) -> -0x23) */
    if (g_cfg0198 >= 0x47 && g_cfg0198 < 0xC8) {
        g_codingDelay2 = (byte)(g_cfg0198 - 0x23);
    } else {
        g_codingDelay2 = 0x23;
    }
    Delay_Loop((word)(g_codingDelay2 + 0x41));   /* [0xF776] */

    /* two strap groups, tables at 0xFF71 (->strap0) and 0xFF74 (->strap1) */
    for (i = 0; i < 2; i++) {
        /* read-and-AND the strap bits of this group through its triplet
         * table; the packed result lands in g_codingStrap0/1 [0x02BD,0x02BE]
         * (see 0xF78E-0xF7E8 for the exact {port,mask} walk). */
        volatile byte *grpA = (i == 0) ? &g_codingStrap0 : &g_codingStrap1;
        *grpA = 0;                     /* cleared then OR/AND-built from straps */
        /* g_ctl02B6[i] = 2  (per-group state) */
        *(volatile byte *)(0x02B6 + i) = 2;
    }

    PTAD &= (byte)~0x01;               /* excitation off [0xF7FF] */
    g_codingCalBusy = 0;               /* [0xF803] clears 0x02B5 busy latch */
}

/* ======================================================================
 * Coding_Sample  [0xF80A]   (called from Task_2Ticks, every 2 ticks)
 * The running coding-channel sampler.  Drives PTAD bit0 high, reads ch 0x0A;
 * if the reading is below 0x4E the channel is treated as "low" and the
 * calibration state is reset (g_codingCalBusy cleared).  Otherwise the raw
 * value is low-pass filtered (via the F4AB running-average helper) into
 * g_codingAdc, normalised (Coding_Normalize, 0xE27D), and - while calibration
 * is pending - the strap accumulators g_acc0284[] are updated from the
 * per-sample table g_tab02BC[].  Drops PTAD bit0 on exit.
 * ====================================================================== */
void Coding_Sample(void)
{
    byte raw;

    PTAD |= 0x01;                      /* excitation on [0xF80E] */
    raw = Adc_Read(0x0A);

    if (raw < 0x4E) {
        /* channel low: filter towards it, normalise, end calibration */
        g_codingAdc = Filter_Avg(g_codingAdc, raw, 2);  /* [0xF4AB] */
        Coding_Normalize();            /* [0xE27D] */
        g_codingCalBusy = 0;
    } else if (g_codingCalBusy == 1) {
        /* calibration in progress: filter, normalise, accumulate straps */
        byte n;
        g_codingAdc = Filter_Avg(g_codingAdc, raw, 2);  /* [0xF4AB] */
        Coding_Normalize();            /* [0xE27D] */
        Delay_Loop(g_codingDelay2);    /* [0xF845] */
        for (n = 2; n != 0; n--) {
            /* accumulate the interpolated strap contribution of sample (n-1)
             * into g_acc0284[] via the F8A7 table lookup (see 0xF84D-0xF871) */
            Strap_Accumulate(n - 1);
        }
    } else {
        /* steady state: just filter + normalise, re-arm calibration */
        g_codingAdc = Filter_Avg(g_codingAdc, raw, 2);  /* [0xF894] */
        Coding_Normalize();            /* [0xE27D] */
        Coding_Calibrate();            /* [0xF877] re-run calibration */
    }

    PTAD &= (byte)~0x01;               /* excitation off [0xF89E] */
}

/* ======================================================================
 * Inputs_Init  [0xF690]   (called from App_InitAll, 0xC55F)
 * Clears the whole input/coding control block [0x0297..0x02B3], seeds the
 * per-button ladder reference levels g_ladderRef[] (0x0273, default 0x0F) and
 * threshold levels g_ladderThr[] (0x0274) for the 8 buttons, sets the backlight
 * mode byte (0x0275) from the mode bits in the state byte [0x019C], loads the
 * ladder window defaults (0x0283..0x0286 = 0x0F/0x00 pairs), the filter
 * coefficient (0x028A = 0xF0) and resets all coding working variables.
 * ====================================================================== */
void Inputs_Init(void)
{
    byte i;

    /* zero the input/coding control block 0x0297..0x02B3 (0x1D bytes) */
    for (i = 0; i < 0x1D; i++) {
        *(volatile byte *)(0x0297 + i) = 0;
    }

    /* seed the 8 button ladder reference / threshold pairs */
    for (i = 0; i < 8; i++) {
        *(volatile byte *)(0x0273 + (word)(i << 1)) = 0x0F;  /* reference */
        *(volatile byte *)(0x0274 + (word)(i << 1)) = 0x00;  /* threshold */
    }

    /* backlight / mode select from the state bits in [0x019C] */
    if ((g_cfg019C & 0x06) == 0x02) {
        *(volatile byte *)0x0275 = 0x04;
    } else if (g_cfg019C & 0x04) {
        *(volatile byte *)0x0275 = 0x07;
    }

    /* ladder window + filter defaults */
    *(volatile byte *)0x0283 = 0x0F;
    *(volatile byte *)0x0284 = 0x00;
    *(volatile byte *)0x0285 = 0x0F;
    *(volatile byte *)0x0286 = 0x00;
    *(volatile byte *)0x028A = 0xF0;   /* running-average filter coefficient */

    /* reset coding working variables */
    g_codingRaw2  = 0;
    g_codingNormLo = 0;
    g_codingNormHi = 0;
    g_codingAdc   = 0;
    g_codingBusy  = 1;
    g_codingNormOk = 1;
}
