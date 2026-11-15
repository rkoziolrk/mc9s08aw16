# Decompilation progress — MC9S08AW16

Firmware: `firmware/69d37336-aw16.s19` — NXP/Freescale **MC9S08AW16** (HCS08),
Audi A6 C7 MFL steering-wheel module, LIN slave. Single application image
(no separate bootloader). Flash base 0xC000, 1 KB RAM, ~153 routines, ~5964
instructions.

Ground truth: `reference/application.asm` (full symbol-annotated disassembly)
and `reference/function_index.md`. switch_jump helper = 0xFD76. The device is
the same family as `rkoziolrk/s909aw32` (A4 B8), so most modules map over with
address differences — reconstruct by analogy but verify every address/constant
against this image's asm.

## Legend
- [x] reconstructed, commented C   - [~] partial (C + asm reference)   - [ ] reference only

## Modules
- [x] ADC front-end: Sensor_Init 0xE229, Adc_Read 0xE246 -> sensor.c
- [x] Startup / scheduler / time base / clock / COP / SOPT — `application/main.c`
      (App_Startup 0xC4C0, main 0xC52D, App_InitAll 0xC54D, Scheduler_Run 0xC5FA,
       Clock_Init 0xC6D0, SysOpt_Init 0xC6EF, COP_Feed 0xC739, Isr_Default 0xC595)
- [ ] Tasks: Task_2Ticks 0xC644, Task_10Ticks 0xC64A, Task_25Ticks 0xC6B7
- [~] NvmTask_Run 0xC6F6 (named), Nvm_Process 0xC8AF, flash writer 0xC400/0xC464 (named); Nvm_Init 0xC7DB TODO
- [x] Ports_Init 0xF28E -> ports.c; EnterCritical/ExitCritical 0xF5E6/0xF5F3 + Delay_Loop 0xF497 -> util.c
- [x] Tpm1_Init 0xC792, Tpm2_Init 0xC7B6, Isr_Tpm2Ch0 0xC743 -> timebase.c
- [~] LIN driver core -> lin.c (Sci_Init 0xCF10, Sci_SendByte 0xCF36, Isr_Sci1 0xCF46). TODO: autobaud, RX/TX engines (Lin_RxByte 0xDEA6, Lin_TxByteOrErr 0xDFB6), transport, signals
      autobaud, RX/TX byte engines, transport, signals
- [ ] ADC + variant/feature detection (Adc_Read 0xE251, Sensor_Init 0xE22B, init 0xF690)
- [ ] Buttons / backlight / scroll, supply, heating, diag, selftest
- [ ] Remaining App_InitAll targets: F690 FA6B E78B E271 F3F1 EA88 E7CF E229
      F73F E2FB E517 F607 CC56 EABE

## Vector handlers (0xFFC0-0xFFFF)
reset→0xC4C0, default→0xC595, and 0xCF46 / 0xCFA2 / 0xC743 / 0xF3B7 for the
peripheral interrupts (SCI1 / TPM2 / KBI — to classify during reconstruction).

## How to resume
Clone this repo; firmware is in `firmware/`. `reference/application.asm` has
every routine annotated (regenerate from the scratchpad tools with
`switch_jump=0xFD76`, image base 0xC000, Capstone HCS08 — remember it swaps
bset/bclr). Pick the next `[ ]`, read its range in the asm, write the C into
`application/<module>.c`, add prototypes to `app.h`, `make check`, update this
file, commit. Reuse `s909aw32` as the structural reference.
