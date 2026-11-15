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
- [x] Tasks -> tasks.c: Task_2Ticks 0xC644 (Coding_Sample+COP_Feed),
      Task_10Ticks 0xC64A (round-robin 10 slots; table 0xC665 extracted),
      Task_25Ticks 0xC6B7. Slot callees still as externs: NvmTask_Run 0xC6F6,
      Timers_Tick 0xEC3A, Lin_Housekeep 0xCD0A, Signals_Build 0xCC7E,
      Wheel_Step 0xE796, Supply_Task 0xFAD4, Port_Refresh 0xF33B,
      Diag_Slot 0xC5A1, Signals_Extra 0xCCFC, Status_Task 0xCCD3.
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
- [x] Buttons -> buttons.c: Buttons_Init 0xE7CF, Buttons_Scan 0xE7F8
      (from Task_10Ticks), Button_Debounce 0xE814/0xE889, Button_ReadWindow
      0xE90E, Buttons_StateInit 0xEA88, Buttons_Calibrate 0xEABE. 4 GPIO
      buttons on port C (table 0xFF25) + 12 ADC-ladder buttons on ch 0/1/8/9
      (table 0xFF35), handlers 0xE929..0xEA6C via 0xFCD8 trampoline.
- [x] Heating -> heating.c: Heating_OutputInit 0xF607, Heating_Task 0xF628.
      NTC on ADC ch 0x03, open/short window [0x15,0xF8), filter + curve table
      0x0164 -> output g_heatOut 0x02A0. Gated by state bits [0x019C]&0x06.
- [x] Backlight PWM -> backlight.c: Backlight_Isr 0xF3B7 (TPM1 overflow),
      Backlight_Init 0xF3F1, Backlight_Task 0xF3F8, Backlight_Restart 0xF428,
      Backlight_PwmOff 0xF464, Backlight_IsOn 0xF41A. TPM1 CH2 PWM (MOD 0xC8),
      duty = 0xC8 - level, level = normalised ADC ch 0x0A (dimming input).
      NOTE: ch 0x0A = backlight dimming level, NOT variant coding (straps are);
      earlier inputs.c "coding" naming to be reconciled in the final pass.
- [x] LIN application layer -> lin_app.c: LinApp_Init 0xCC56, LinApp_Decode-
      Command 0xCC7E (unpacks subscribed frame bytes 0x01BD/0x01BE/0x01C7/
      0x01C8 -> control vars 0x02AE..0x02B3, dim level 0x02AA), Supervise_Task
      0xCCD3 (bus-timeout), Supervise_Tick 0xCCFC, Lin_Housekeep 0xCD0A.
      tasks.c now calls these by name.
- [x] Button/scroll signal handlers -> signals.c: the 0xE929..0xEA87 event
      handlers (4 GPIO + 6 ladder windows + 2 combos + ch8/ch9 scroll + getter)
      that publish button states [0x0271..0x0282], scroll event [0x0240] and
      combo event [0x02A6]. This region was a linear-sweep gap in the base
      listing; disassembled (HCS08) and spliced into reference/application.asm.
- [x] Self-test / reset log -> selftest.c: ResetLog_Init 0xFA6B (SRS reset-
      cause counters 0x0193..0x0196), SelfTest_Task 0xFAD4, FlashCrc_Step
      0xFAE9 (0xC400 XOR walk vs stored 0x019D/0x019E -> fault g_linFlags b4),
      RamTest_Step 0xFB9E (0xAA/0x55 march -> fault 0x0112 b1).
- [x] Scheduler glue + power: NvmTask_Run 0xC6F6 + Flash_WriteEnter/Exit
      0xF375/0xF37D (nvm.c); Port_Refresh 0xF33B + Ports_SleepIo/Dir
      0xF385/0xF39B (ports.c); Backlight_Control 0xE796 + Backlight_SetGate
      0xE7CB (backlight.c); Timers_Tick 0xEC3A (buttons.c); power.c:
      Sleep_Enter 0xC6BD, Power_Task 0xC5A1, Sci_Disable 0xCD10, Tick_Advance
      0xC5DE, Wake_SetRequest 0xC5CA. tasks.c now fully named (no sub_ left).
- [x] LIN transport bodies (point 4): LinErr_Report 0xDCCB, LinDiag_Response
      0xDBB7 and LinTp_Timer 0xDD6C fleshed out in lin_transport.c (ISO-TP
      N_As/N_Cr timers $B1/$01D6/$01D7, wake timer $C2-$C4, diag state
      $B8/$B9/$01D9/$01E2). Autobaud reconstructed as Lin_AutobaudIsr 0xCFA2
      in lin.c (TPM2 CH1 capture, 5-phase sync measurement, 0x2CC3 threshold,
      divisor -> SCI1BDH/BDL). Lin_GotoSleep2 0xDAD7 done.
- [x] Shared helpers -> filters.c: Filter_Avg 0xF4AB (slew-rate limiter),
      Table_Interp 0xF535 (piecewise-linear NTC->level curve), Btn_Dispatch
      0xFCD8 (indirect handler trampoline).
- [x] LIN transport core -> lin_core.c: critical section (Lin_CritEnter/Exit
      0xD136/0xD14E), scheduled-response timer (LinSched_Reset/Tick/Arm/Busy/
      Abort 0xD17B/0xD191/0xD1C6/0xD1FB/0xD61D), frame plumbing (LinFrame_*
      0xE02C/0xE037/0xE083/0xE0AE/0xE0EC/0xE114/0xE11E), node state
      (LinNode_InitState/Reset/SetMode/SchedTick/Rearm/Wake/InitFrames* 0xD65A/
      0xD67F/0xD6D2/0xD722/0xDAB6/0xDAC5/0xDA3D/0xDA78), ISO-TP rx/tx
      (LinTp_RxFrame/TxFrame/TxStep 0xD20D/0xD44C/0xD5C7), management responses
      (LinApp_SendError 0xCA54, Lin_SleepArm/Check 0xCA6B/0xCA75,
      LinDiag_AutoConfig 0xCA87, Lin_SendWakeup 0xDE08), Lin_ResetState 0xCD1B,
      and the buffer helpers (Buf_Copy 0xE188 / Fill 0xE13A / Clear 0xE15C /
      CopyIdx 0xE1C6).
- [x] Math runtime -> runtime.c: rt_div8/mul_setup/scale16/scale_fold/cmp_fp
      (0xFD08/0xFE2A/0xFD5B/0xFE77/0xFDFC) - CodeWarrior fixed-point helpers.
- [x] Strap_Accumulate 0xF8A7 (GPIO strap coding read/debounce) -> inputs.c;
      Nvm_RequestSave 0xC841 -> nvm.c.

**All application symbols are now defined - no sub_XXXX placeholders remain.**
Remaining as documented structural reconstructions (not bit-exact): the ISO-TP
rx/tx byte arithmetic, the fixed-point math runtime, and Nvm_Process's
erase/program state-machine body (the flash sequencing is in the asm).
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
