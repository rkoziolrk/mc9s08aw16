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
- [x] Flash config store -> nvm.c (Flash_BurstProgram 0xC400, Flash_ErasePage 0xC464, Nvm_Init 0xC7DB banks 0xC000/0xC200, Nvm_Checksum; Nvm_Process 0xC8AF structural). NvmTask_Run 0xC6F6 named.
- [x] Ports_Init 0xF28E -> ports.c; EnterCritical/ExitCritical 0xF5E6/0xF5F3 + Delay_Loop 0xF497 -> util.c
- [x] Tpm1_Init 0xC792, Tpm2_Init 0xC7B6, Isr_Tpm2Ch0 0xC743 -> timebase.c
- [x] LIN byte engines -> lin.c (Lin_RxByte 0xDEA6, Lin_TxByteOrErr 0xDFB6, full state machines) + driver core. transport helpers in lin_transport.c (LinCrc_Fold, LinSci_RxOn/Off, LinErr_Set, LinSched_OnHeader). TODO: autobaud, LinErr_Report/LinDiag_Response/LinTp_Timer detail, signals
      autobaud, RX/TX byte engines, transport, signals
- [x] ADC front-end: Sensor_Init 0xE229, Adc_Read 0xE246 -> sensor.c
- [x] Variant/coding detection + acquisition -> inputs.c
      (Inputs_Init 0xF690, Coding_Reset 0xE271, Coding_Normalize 0xE27D,
       Coding_Probe 0xE2FB, Coding_Calibrate 0xF73F, Coding_Sample 0xF80A).
      Coding = ADC ch 0x0A window [0x6F,0xD1) + GPIO straps (tables 0xFF71/
      0xFF74). NOT the AW32 9-band table — single validity window. DEVICE.md
      updated with the verified windows/volts.
- [x] Detect/scan engine -> wheel_io.c: Scan_Isr 0xE537 (1 ms excitation PWM),
      Detect_Init 0xE517, Detect_Task 0xE337/Detect_Timer 0xE348,
      Detect_StateMachine 0xE35E (switch on 0x0233, states 0..8; jump table at
      0xE36C extracted from the image), drive helpers (Drive_Off E649,
      Drive_Stop E631, Drive_PwmSetup E5A7, Drive_PwmSetup2 E5EC), measure
      helpers (Meas_ClearStatus E65C, Meas_LadderRatio E661, Meas_LowSide E6E4,
      Meas_HighSide E67F, Meas_Ladder2 E729). Drives PTE2/PTF4, ADC ch 0x0A
      (coding) + ch 0x02 (ladder).
- [ ] Buttons / backlight / scroll output stage, supply, heating, diag, selftest
- [ ] Remaining App_InitAll targets: FA6B E78B F3F1 EA88 E7CF E229
      F607 CC56 EABE  (+ helper bodies Filter_Avg 0xF4AB, Strap_Accumulate 0xF8A7)

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
