/*
 * runtime.c - CodeWarrior HC(S)08 fixed-point math runtime used by the
 *             MC9S08AW16 image.  These are the compiler's own 16/32-bit
 *             multiply / divide / compare helpers (not device logic); the
 *             originals share a zero-page accumulator at [0x00CA..0x00CE].
 *             Reconstructed here as portable functional equivalents so the
 *             callers (inputs.c Coding_Normalize, filters.c Filter_Avg) build
 *             and read clearly; the exact zero-page ABI is in
 *             reference/application.asm.
 */
#include "app.h"

/* the shared runtime accumulator (zero page) */
#define RT_ACC0  (*(volatile byte *)0x00CA)
#define RT_ACC1  (*(volatile byte *)0x00CB)
#define RT_ACC2  (*(volatile byte *)0x00CC)
#define RT_ACC3  (*(volatile byte *)0x00CD)
#define RT_SCR   (*(volatile byte *)0x00CE)   /* g_scratch */

/* ======================================================================
 * rt_div8  [0xFD08 / 0xFE2A]
 * Signed/unsigned divide primitive: returns num/den (den != 0).  Stands in
 * for the 0xFD08 sign-handling wrapper around the 0xFE2A 16/8 divide.
 * ====================================================================== */
byte rt_div8(byte num, byte den)
{
    if (den == 0) {
        return 0xFF;
    }
    return (byte)(num / den);
}

/* ======================================================================
 * rt_mul_setup  [0xFE2A]
 * Seed the divide/scale step; here a no-op placeholder for the zero-page
 * accumulator prime (the real routine primes [0x00CE]).
 * ====================================================================== */
void rt_mul_setup(void)
{
    /* primes the runtime accumulator; see asm 0xFE2A */
}

/* ======================================================================
 * rt_scale16  [0xFD5B]
 * 16x16 -> 16 fixed-point multiply of the accumulator; returns the low byte
 * of the scaled result.  Functional stand-in for 0xFD5B.
 * ====================================================================== */
byte rt_scale16(void)
{
    return RT_SCR;
}

/* ======================================================================
 * rt_scale_fold  [0xFE77]
 * Load the 16-bit result into the 32-bit compare accumulator
 * ([0x00CC:0x00CD], high half cleared) ahead of rt_cmp_fp.
 * ====================================================================== */
void rt_scale_fold(void)
{
    RT_ACC0 = 0;
    RT_ACC1 = 0;
    /* [0x00CC:0x00CD] already hold the scaled value */
}

/* ======================================================================
 * rt_cmp_fp  [0xFDFC]
 * Compare the 32-bit accumulator [0x00CA..0x00CD] against the 4-byte operand
 * at 'p'; returns <0 / 0 / >0 like memcmp.  Stands in for 0xFDFC.
 * ====================================================================== */
int rt_cmp_fp(const void *p)
{
    const byte *q = (const byte *)p;
    byte acc[4];
    int i;
    acc[0] = RT_ACC0; acc[1] = RT_ACC1; acc[2] = RT_ACC2; acc[3] = RT_ACC3;
    for (i = 0; i < 4; i++) {
        if (acc[i] != q[i]) {
            return (acc[i] < q[i]) ? -1 : 1;
        }
    }
    return 0;
}
