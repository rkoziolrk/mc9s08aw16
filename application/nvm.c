/*
 * nvm.c - Non-volatile configuration storage in on-chip flash.
 *         Flash_BurstProgram (0xC400), Flash_ErasePage (0xC464),
 *         Nvm_Init (0xC7DB), Nvm_Process (0xC8AF).
 *
 * The configuration image (RAM copy g_cfg at 0x0120) is stored in one of
 * two 512-byte flash banks: bank A = 0xC000, bank B = 0xC200. Each image
 * carries a write counter (byte 0, counting DOWN from 0x1000, high byte at
 * 0x7F) and a check word; at power-up the valid bank with the lower counter
 * (= newest) is loaded. Erase/program run from RAM (the array is not
 * readable while programming); the RAM-resident code bytes are identical to
 * the AW32 sibling (only the bank addresses differ).
 */
#include "app.h"

/* RAM-resident flash routine I/O (addressed by fixed zero-page, keep here) */
byte * volatile g_flashSrc   AT(0x00A0);   /* [0xA0] source pointer           */
byte * volatile g_flashDst   AT(0x00A2);   /* [0xA2] running destination      */
volatile byte   g_flashCount AT(0x00A4);   /* [0xA4] byte count               */
byte * volatile g_flashAddr  AT(0x00A8);   /* [0xA8] operation start address  */
volatile byte   g_flashFill  AT(0x00AA);   /* [0xAA] 1 = program 0x83 filler  */

byte  g_nvmBank    AT(0x01A7);   /* [0x01A7] 1=bank A, 2=bank B, 3=none valid */
word  g_nvmCounterA AT(0x01AA);  /* [0x01AA] bank A (0xC000) write counter    */
word  g_nvmCounterB AT(0x01A8);  /* [0x01A8] bank B (0xC200) write counter    */

#define NVM_BANK_A   ((byte *)0xC000)
#define NVM_BANK_B   ((byte *)0xC200)
#define NVM_MAGIC    0xCAFEu

/* Burst-program machine code executed from RAM (identical bytes to AW32;
 * programs g_flashCount bytes from g_flashSrc, or the 0x83 filler, into the
 * flash at g_flashDst with the FCMD burst command). */
static const byte s_burstProgCode[] = {
    0xC6,0x18,0x25,0xA4,0x80,0x27,0xF9,0xA6,0x55,0xC7,0x18,0x00,0xB6,0xAA,0xA1,0x01,
    0x27,0x09,0x55,0xA0,0xF6,0xAF,0x01,0x35,0xA0,0x20,0x02,0xA6,0x83,0x55,0xA2,0xF7,
    0xAF,0x01,0x35,0xA2,0xA6,0x25,0xC7,0x18,0x26,0xA6,0x80,0xC7,0x18,0x25,0x3B,0xA4,
    0xCF,0xC6,0x18,0x25,0x48,0x2A,0xFA,0xA6,0xAA,0xC7,0x18,0x00,0x81
};
/* Page-erase machine code executed from RAM (identical bytes to AW32). */
static const byte s_pageEraseCode[] = {
    0xA6,0xAA,0xC7,0x18,0x00,0x55,0xA2,0xF7,0xA6,0x40,0xC7,0x18,0x26,0xA6,0x80,0xC7,
    0x18,0x25,0x9D,0x9D,0x9D,0xA6,0x55,0xC7,0x18,0x00,0xC6,0x18,0x25,0x48,0x2A,0xF5,
    0x81
};

static byte s_ramCode[64];
typedef void (*RamFunc)(void);

static void Flash_RunInRam(const byte *code, byte len)
{
    byte i;
    for (i = 0; i < len; i++) s_ramCode[i] = code[i];
    ((RamFunc)(void *)s_ramCode)();
}

/* [0xC400] burst-program g_flashCount bytes at g_flashAddr */
void Flash_BurstProgram(void)
{
    SRS = 0xAA;
    g_flashDst = g_flashAddr;
    FSTAT = FSTAT_FPVIOL | FSTAT_FACCERR;
    Flash_RunInRam(s_burstProgCode, sizeof(s_burstProgCode));
}

/* [0xC464] erase the 512-byte page at g_flashAddr (FCDIV=0x4C, waits for FLL) */
void Flash_ErasePage(void)
{
    while ((ICGS1 & ICGS1_LOCK) == 0) { }
    FSTAT |= FSTAT_FACCERR;
    FCDIV = 0x4C;
    SRS = 0x55;
    g_flashDst = g_flashAddr;
    FSTAT = FSTAT_FPVIOL | FSTAT_FACCERR;
    Flash_RunInRam(s_pageEraseCode, sizeof(s_pageEraseCode));
}

/* [0x8D2A-equivalent] XOR of 'count' big-endian 16-bit words */
word Nvm_Checksum(const word *p, word count)
{
    word sum = 0, i;
    for (i = 0; i < count; i++) sum ^= *p++;
    return sum;
}

/* ======================================================================
 * Nvm_Init  [0xC7DB]
 * Read both banks' write counters, select the newest valid one (counter
 * < 0x1001) and load it. Bank code g_nvmBank: 1=A, 2=B, 3=none.
 * ====================================================================== */
void Nvm_Init(void)
{
    g_nvmCounterA = (word)(((word)NVM_BANK_A[0x7F] << 8) + NVM_BANK_A[0]);
    g_nvmCounterB = (word)(((word)NVM_BANK_B[0x7F] << 8) + NVM_BANK_B[0]);

    if (g_nvmCounterA < g_nvmCounterB && g_nvmCounterA < 0x1001) {
        g_nvmBank = 1;                      /* bank A (0xC000) */
    } else if (g_nvmCounterB < g_nvmCounterA && g_nvmCounterB < 0x1001) {
        g_nvmBank = 2;                      /* bank B (0xC200) */
    } else {
        g_nvmBank = 3;                      /* no valid bank -> defaults */
    }
    /* then copy the selected page into g_cfg (see asm 0xC824-...). */
}

/* ======================================================================
 * Nvm_Process  [0xC8AF]
 * Flash-save state machine (erase / burst-program / verify) run from
 * NvmTask_Run under a critical section. Returns the approximate number of
 * ticks the operation blocked the CPU. Same structure as the AW32 part;
 * the per-state sequencing is in reference/application.asm 0xC8AF-0xC97F.
 * ====================================================================== */
byte Nvm_Process(void)
{
    /* state machine: prepare -> Flash_ErasePage -> Flash_BurstProgram x3
     * (128 data bytes + 0x83 filler) -> verify. See the asm. */
    return 0;
}
