/*
 * filters.c - Small shared numeric helpers used across the MC9S08AW16 MFL
 *             modules: a slew-rate-limited running filter, a piecewise-linear
 *             table interpolation, and the indirect button-handler dispatch
 *             trampoline.
 *
 * These are reconstructed structurally from reference/application.asm; the
 * originals use the CodeWarrior fixed-point divide helper (0xFD08) and a
 * dense stack-argument ABI.  The behaviour (not the exact register/stack
 * shuffling) is captured here.
 *
 * Addresses in brackets are the absolute flash/RAM addresses of the original.
 */
#include "app.h"

extern byte rt_div8(byte num, byte den);   /* [0xFD08] unsigned 8-bit divide */

/* ======================================================================
 * Filter_Avg  [0xF4AB]
 * Move the stored value 'acc' towards 'sample' by at most one step, i.e. a
 * slew-rate limiter / first-order smoother.  'weight' selects the step size
 * (the divisor applied to the difference via the 0xFD08 helper).  The result
 * is clamped so it never overshoots 'sample'.  Used for the NTC (heating),
 * the button ladder and the coding/dimming channel.
 *
 * (The original takes the accumulator and limits through the stack; this
 * three-argument form is the functional equivalent used by the callers.)
 * ====================================================================== */
byte Filter_Avg(byte acc, byte sample, byte weight)
{
    int diff = (int)sample - (int)acc;      /* signed difference [0xF4CD] */
    int step;

    if (weight == 0) {
        return sample;                      /* no smoothing */
    }
    step = diff / (int)weight;              /* [0xFD08] */
    if (step == 0) {
        step = (diff > 0) ? 1 : (diff < 0 ? -1 : 0);   /* min 1 LSB move */
    }
    return (byte)((int)acc + step);
}

/* ======================================================================
 * Table_Interp  [0xF535]
 * Piecewise-linear interpolation of 'x' through a flash table of {x,y} byte
 * pairs (ascending x), terminated per the descriptor.  Returns the
 * interpolated y.  Used to map the filtered NTC reading to a heating level
 * (table at 0x0164) - see heating.c.
 *
 * Structural reconstruction: the original walks the pair table (0xF546 loop)
 * for the bracketing segment, then linearly interpolates within it
 * (0xF568-0xF5D8) using the 0xFD08 divide.
 * ====================================================================== */
byte Table_Interp(const byte *table, byte x)
{
    const byte *p = table;
    byte x0, y0, x1, y1;

    /* find the segment [x0,x1) that brackets x */
    x0 = p[0]; y0 = p[1];
    for (;;) {
        x1 = p[2]; y1 = p[3];
        if (x < x1 || x1 <= x0) {
            break;                          /* bracket found / table end */
        }
        p += 2;
        x0 = p[0]; y0 = p[1];
    }
    if (x <= x0) {
        return y0;
    }
    if (x1 == x0) {
        return y1;
    }
    /* linear interpolation y0 + (x-x0)*(y1-y0)/(x1-x0) */
    {
        int dy = (int)y1 - (int)y0;
        int num = (int)(x - x0) * dy;
        int den = (int)(x1 - x0);
        return (byte)((int)y0 + num / den);
    }
}

/* ======================================================================
 * Btn_Dispatch  [0xFCD8]
 * The indirect-call trampoline: the caller has pushed a handler pointer and
 * the argument on the stack; the trampoline rearranges the stack so that an
 * rts transfers control to the handler with the argument in place.  Here it
 * is modelled as a direct call through the {hHi,hLo} address with 'pressed'
 * in A (the button handlers live in signals.c).
 * ====================================================================== */
#if defined(AW16_HOSTCHECK)
void Btn_Dispatch(byte hHi, byte hLo, byte pressed)
{
    /* host build cannot call an arbitrary firmware address; on target this
     * is the 0xFCD8 stack-shuffle trampoline (see reference/application.asm). */
    (void)hHi; (void)hLo; (void)pressed;
}
#else
void Btn_Dispatch(byte hHi, byte hLo, byte pressed)
{
    void (*handler)(byte) = (void (*)(byte))(((word)hHi << 8) | hLo);
    handler(pressed);
}
#endif
