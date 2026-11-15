/*
 * ports.c - GPIO configuration (Ports_Init, 0xF28E).
 *
 * Reflects the exact register writes of the firmware (port data-direction,
 * pull-up, slew-rate and drive-strength registers), programmed for the MFL
 * module's wiring. Some masks are applied read-modify-write on the raw
 * PTxDD page addresses 0x0001..0x000D, exactly as the original.
 */
#include "app.h"

#define R8(a)  (*(volatile byte *)(a))

/* ======================================================================
 * Ports_Init  [0xF28E]
 * Also enables the low-voltage detect (SPMSC1=0x1C, SPMSC2=0x01) and sets
 * the module-init flag at 0x0262.
 * ====================================================================== */
void Ports_Init(void)
{
    R8(0x0262) = 0x01;                 /* module init flag */
    SPMSC1 = 0x1C;                     /* LVD enable / LVW */
    SPMSC2 = 0x01;

    /* Port A: all inputs, pull-ups off */
    PTAD  = 0x00;  PTADD = 0xFF;
    PTASE = 0xFF;  PTADS = 0x00;

    /* Port B: all inputs */
    PTBD  = 0x00;  PTBDD = 0xFF;  PTBSE = 0xFF;  PTBDS = 0x00;

    /* Port C: PTC0 output; keep bits per mask 0xD1; pull-ups off */
    PTCDD = 0xFF;
    R8(0x0005) = (byte)(R8(0x0005) & 0xD1);
    R8(0x0005) = (byte)(R8(0x0005) | 0x01);
    PTCPE = 0x00;  PTCSE = 0x00;  PTCDS = 0x00;

    /* Port D: low nibble -> inputs */
    PTDD  = 0x00;  PTDDD = 0xFF;
    R8(0x0007) = (byte)(R8(0x0007) & 0xF0);
    PTDPE = 0x00;  PTDSE = 0x00;  PTDDS = 0x00;

    /* Port E: PTE0 + PTE7 outputs (TX + activity), PTEDD=0xFD */
    R8(0x0008) = (byte)(R8(0x0008) | 0x81);
    PTEDD = 0xFD;
    PTEPE = 0x00;  PTESE = 0x00;  PTEDS = 0x00;

    /* Port F: PTF5 input (DD=0xDF) */
    PTFD  = 0x00;  PTFDD = 0xDF;
    R8(0x000B) = (byte)(R8(0x000B) & 0xDF);
    PTFPE = 0x00;  PTFSE = 0x00;  PTFDS = 0x00;

    /* Port G: low nibble inputs (coding straps) */
    PTGD  = 0x00;  PTGDD = 0xFF;
    R8(0x000D) = (byte)(R8(0x000D) & 0xF0);
    PTGPE = 0x00;  PTGSE = 0x00;  PTGDS = 0x00;
}

/* ======================================================================
 * Port_Refresh  [0xF33B]   (called from Task_10Ticks slot 8)
 * Periodically re-assert the critical GPIO data-direction bits (defensive
 * against SEU / brown-out glitching of the PTxDD registers): PTADD b0 out,
 * PTBDD b2 in, PTCDD masked 0xD1 + b0 out, PTDDD low nibble in, PTEDD b7+b2
 * out, PTFDD b4+b0 out & b5 in, PTGDD low nibble in.
 * ====================================================================== */
void Port_Refresh(void)
{
    R8(0x0001) = (byte)(R8(0x0001) | 0x01);   /* PTADD */
    R8(0x0003) = (byte)(R8(0x0003) & 0xFB);   /* PTBDD */
    R8(0x0005) = (byte)(R8(0x0005) & 0xD1);   /* PTCDD */
    R8(0x0005) = (byte)(R8(0x0005) | 0x01);
    R8(0x0007) = (byte)(R8(0x0007) & 0xF0);   /* PTDDD */
    R8(0x0009) = (byte)(R8(0x0009) | 0x84);   /* PTEDD */
    R8(0x000B) = (byte)(R8(0x000B) | 0x11);   /* PTFDD */
    R8(0x000B) = (byte)(R8(0x000B) & 0xDF);
    R8(0x000D) = (byte)(R8(0x000D) & 0xF0);   /* PTGDD */
}

/* ======================================================================
 * Ports_SleepIo  [0xF385]   (called from Sleep_Enter)
 * Pre-sleep pin states: drop PTC0 and PTE0 (TX idle), make PTE0 an input.
 * ====================================================================== */
void Ports_SleepIo(void)
{
    R8(0x0004) = (byte)(R8(0x0004) & 0xFE);   /* PTCD  b0 = 0 */
    R8(0x0008) = (byte)(R8(0x0008) & 0xFE);   /* PTED  b0 = 0 */
    R8(0x0009) = (byte)(R8(0x0009) | 0x01);   /* PTEDD b0 = in */
}

/* ======================================================================
 * Ports_SleepDir  [0xF39B]   (called from Sleep_Enter)
 * Set the sleep data-direction map: only PTC0/PTC7 and PTE0 driven.
 * ====================================================================== */
void Ports_SleepDir(void)
{
    PTADD = 0x00;
    PTBDD = 0x00;
    PTCDD = 0x81;
    PTDDD = 0x00;
    PTEDD = 0x01;
    PTFDD = 0x00;
    PTGDD = 0x00;
}
