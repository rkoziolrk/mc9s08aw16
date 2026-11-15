/*
 * selftest.c - Reset-cause logging and background self-tests for the
 *              MC9S08AW16 MFL module (the AW16 counterpart of the AW32
 *              selftest.c).
 *
 * Three cooperating pieces:
 *   ResetLog_Init   (0xFA6B) - at start-up, classify the System Reset Status
 *                   (SRS) and bump a saturating per-cause counter.
 *   SelfTest_Task   (0xFAD4) - from the periodic tasks, advance the flash-CRC
 *                   and RAM march tests one step and fold their fault flags
 *                   into the node fault indicator [0x02A8].
 *   FlashCrc_Step   (0xFAE9) - walk the flash image in 0x20-byte chunks from
 *                   0xC400, accumulating a running XOR into [0x0110:0x0111];
 *                   on completion compare against the stored checksum
 *                   [0x019D:0x019E] and set the CRC-fault flag (g_linFlags b4)
 *                   on mismatch.
 *   RamTest_Step    (0xFB9E) - march one RAM cell with 0xAA then 0x55 and
 *                   verify; a miscompare sets the RAM-fault flag [0x0112] b1.
 *
 * The pointer-walk arithmetic of the two background tests is transcribed
 * structurally (with the exact base addresses / chunk sizes / fault flags);
 * it is a faithful reconstruction of the control flow, not a bit-exact copy.
 *
 * Addresses in brackets are the absolute flash/RAM addresses of the original.
 */
#include "app.h"

extern byte g_linFlags AT(0x026B);   /* b4 = flash-CRC fault */
byte g_faultFlag AT(0x02A8);         /* node fault indicator */
byte g_resetEvent AT(0x026A);        /* set when a logged reset cause is seen */

/* CRC walk state */
#define CRC_PAGE_LO  (*(volatile byte *)0x010D)
#define CRC_PAGE_HI  (*(volatile byte *)0x010E)
#define CRC_ACC_LO   (*(volatile byte *)0x0110)
#define CRC_ACC_HI   (*(volatile byte *)0x0111)
#define CRC_DONE     (*(volatile byte *)0x010F)
/* RAM march state */
#define RAM_STATE    (*(volatile byte *)0x0112)
#define RAM_IDX_LO   (*(volatile byte *)0x0113)
#define RAM_IDX_HI   (*(volatile byte *)0x0114)

/* reset-cause counters [0x0193..0x0196] */
#define RST_POR   (*(volatile byte *)0x0193)   /* external / power-on */
#define RST_COP   (*(volatile byte *)0x0194)   /* COP watchdog        */
#define RST_ILOP  (*(volatile byte *)0x0195)   /* illegal opcode      */
#define RST_LVD   (*(volatile byte *)0x0196)   /* low-voltage         */

/* saturating-increment helper for the logged counters */
static void log_cause(volatile byte *ctr)
{
    if (*ctr < 0xFE) {
        (*ctr)++;
        g_resetEvent = 1;
    }
}

/* ======================================================================
 * ResetLog_Init  [0xFA6B]   (called from App_InitAll, 0xC56B)
 * Read SRS once, latch it in [0x010C] and bump the matching reset-cause
 * counter.  A power-on reset (SRS bit 0x80) is not logged (it clears the
 * record); the external (0x40), COP (0x20), illegal-opcode (0x10) and
 * low-voltage (0x04) causes each bump their own saturating counter.
 * ====================================================================== */
void ResetLog_Init(void)
{
    byte srs = SRS;
    *(volatile byte *)0x010C = srs;

    if (srs & 0x80) {
        return;                         /* power-on: nothing logged */
    }
    if (srs & 0x40) {
        log_cause(&RST_POR);
    }
    if ((srs & 0x60) == 0x20) {
        log_cause(&RST_COP);
    }
    if (srs & 0x10) {
        log_cause(&RST_ILOP);
    }
    if (srs & 0x04) {
        log_cause(&RST_LVD);
    }
}

/* ======================================================================
 * FlashCrc_Step  [0xFAE9]
 * Advance the background flash CRC by one 0x20-byte chunk.  The chunk base is
 * 0xC400 + (page << 5); each word is XORed into [0x0110:0x0111].  When the
 * page index reaches 0x01DD the walk is complete: the result is latched into
 * [0x0268:0x0269] and compared with the stored checksum [0x019D:0x019E]; a
 * mismatch raises the CRC-fault flag (g_linFlags b4) and the walk restarts.
 * ====================================================================== */
void FlashCrc_Step(void)
{
    word page = ((word)CRC_PAGE_HI << 8) | CRC_PAGE_LO;

    if (page < 0x01DD) {
        /* XOR one 0x20-byte chunk at 0xC400 + (page<<5) into the accumulator
         * [0x0110:0x0111] (see 0xFB0D-0xFB54 for the exact word walk). */
        word base = (word)(0xC400 + (page << 5));
        word i;
        for (i = 0; i < 0x20; i += 2) {
            CRC_ACC_HI ^= *(volatile byte *)(base + i);
            CRC_ACC_LO ^= *(volatile byte *)(base + i + 1);
        }
        page++;
        CRC_PAGE_HI = (byte)(page >> 8);
        CRC_PAGE_LO = (byte)(page & 0xFF);
        return;
    }

    /* walk complete */
    CRC_DONE = 1;
    *(volatile byte *)0x0268 = CRC_ACC_HI;
    *(volatile byte *)0x0269 = CRC_ACC_LO;
    if (*(volatile byte *)0x0269 != *(volatile byte *)0x019E ||
        *(volatile byte *)0x0268 != *(volatile byte *)0x019D) {
        g_linFlags |= 0x10;             /* flash-CRC fault */
    }
    /* restart the walk */
    CRC_DONE   = 0;
    CRC_ACC_LO = 0;
    CRC_ACC_HI = 0;
    CRC_PAGE_LO = 0;
    CRC_PAGE_HI = 0;
}

/* ======================================================================
 * RamTest_Step  [0xFB9E]
 * March one RAM cell at 0x0070 + (idx << 2): write 0xAA and read back, then
 * write 0x55 and read back.  A miscompare sets the RAM-fault flag ([0x0112]
 * b1).  (The destructive pattern is restored by the normal write-back of the
 * variable that lives in the cell on the next access.)
 * ====================================================================== */
void RamTest_Step(void)
{
    volatile byte *cell;

    if (RAM_STATE & 0x01) {
        return;                         /* test suspended/complete */
    }

    cell = (volatile byte *)(0x0070 + (((word)RAM_IDX_HI << 8 | RAM_IDX_LO) << 2));
    *cell = 0xAA;
    if (*cell == 0xAA) {
        *cell = 0x55;
        if (*cell != 0x55) {
            RAM_STATE |= 0x02;          /* RAM fault */
        }
    } else {
        RAM_STATE |= 0x02;              /* RAM fault */
    }

    {
        word idx = ((word)RAM_IDX_HI << 8 | RAM_IDX_LO) + 1;
        RAM_IDX_HI = (byte)(idx >> 8);
        RAM_IDX_LO = (byte)(idx & 0xFF);
    }
}

/* ======================================================================
 * SelfTest_Task  [0xFAD4]   (called from Task_10Ticks slots 1/9)
 * Advance both background self-tests, then raise the node fault indicator
 * [0x02A8] if a LIN comms (0x08) or flash-CRC (0x10) fault is latched.
 * ====================================================================== */
void SelfTest_Task(void)
{
    FlashCrc_Step();                    /* [0xFAE9] */
    RamTest_Step();                     /* [0xFB9E] */

    if (g_linFlags == 0x08 || g_linFlags == 0x10) {
        g_faultFlag = 1;
    }
}
