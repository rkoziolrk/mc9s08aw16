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
