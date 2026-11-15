/*
 * app.h - Shared declarations for the MC9S08AW16 MFL steering-wheel module.
 *
 * Addresses in brackets are the absolute RAM/flash addresses of the
 * original firmware. Variables the fixed-address code reaches are pinned
 * with AT().
 */
#ifndef APP_H
#define APP_H

#include "mc9s08aw16.h"

#if defined(AW16_HOSTCHECK)
#  define AT(addr)
#elif defined(__SDCC)
#  define AT(addr) __at(addr)
#else
#  define AT(addr) @addr          /* CodeWarrior */
#endif

/* ---- scheduler / time base (main.c) ---------------------------------- */
extern volatile byte g_tickCount, g_tickFlag;
extern byte          g_slot10, g_tickSnapshot;
extern byte          g_scratch;   /* [0x00CE] zero-page scratch used by the scheduler */

/* ---- core prototypes -------------------------------------------------- */
void App_Startup(void);
void main(void);
void App_InitAll(void);
void COP_Feed(void);
void Clock_Init(void);
void SysOpt_Init(void);
INTERRUPT void Isr_Default(void);

void EnterCritical(void);   /* [0xF5E6] */
void ExitCritical(void);    /* [0xF5F3] */
byte u8_mod(byte value, byte divisor);  /* [0xFCFC] unsigned modulo helper */
byte Delay_Loop(word count);            /* [0xF497] */
extern byte g_criticalNesting;          /* [0x0109] */

/* Periodic tasks */
void Task_2Ticks(void);     /* [0xC644] */
void Task_10Ticks(void);    /* [0xC64A] */
void Task_25Ticks(void);    /* [0xC6B7] */

/* Hardware / module init (reconstructed in their own files; see PROGRESS.md) */
void Ports_Init(void);      /* [0xF28E] */
void Nvm_Init(void);        /* [0xC7DB] */
byte Nvm_Process(void);     /* [0xC8AF] */
void Flash_BurstProgram(void);/* [0xC400] */
void Flash_ErasePage(void); /* [0xC464] */
word Nvm_Checksum(const word *p, word count);
void Tpm1_Init(void);       /* [0xC792] */
void Tpm2_Init(void);       /* [0xC7B6] */

/* lin.c */
void Sci_Init(void);        /* [0xCF10] */
INTERRUPT void Lin_AutobaudIsr(void);/* [0xCFA2] TPM2 CH1 capture autobaud */
void Sci_SendByte(byte data);/* [0xCF36] */
INTERRUPT void Isr_Sci1(void);/* [0xCF46] */
INTERRUPT void Isr_Tpm2Ch0(void);/* [0xC743] */
extern word g_tpm2NextCompare;

/* sensor.c */
void Sensor_Init(void);     /* [0xE229] */
byte Adc_Read(byte channel);/* [0xE246] */

/* inputs.c - steering-wheel coding / variant detection + acquisition */
void Inputs_Init(void);     /* [0xF690] */
void Coding_Reset(void);    /* [0xE271] */
void Coding_Normalize(void);/* [0xE27D] */
void Coding_Probe(void);    /* [0xE2FB] */
void Coding_Calibrate(void);/* [0xF73F] */
void Coding_Sample(void);   /* [0xF80A] */
byte Filter_Avg(byte acc, byte sample, byte weight);  /* [0xF4AB] */

/* wheel_io.c - excitation drive + coding/ladder measurement + detection SM */
INTERRUPT void Scan_Isr(void);   /* [0xE537] 1 ms excitation PWM            */
void Detect_Init(void);          /* [0xE517] */
void Detect_Task(void);          /* [0xE337] from Task_10Ticks              */
void Detect_StateMachine(void);  /* [0xE35E] */
void Drive_Off(void);            /* [0xE649] */
void Drive_Stop(void);           /* [0xE631] */
void Drive_PwmSetup(byte compare);  /* [0xE5A7] */
void Drive_PwmSetup2(byte compare); /* [0xE5EC] */
void Meas_ClearStatus(void);     /* [0xE65C] */
byte Meas_LadderRatio(void);     /* [0xE661] */
byte Meas_LowSide(void);         /* [0xE6E4] */
byte Meas_HighSide(void);        /* [0xE67F] */
void Meas_Ladder2(void);         /* [0xE729] */

/* buttons.c - steering-wheel button scan + debounce */
void Buttons_Init(void);         /* [0xE7CF] */
void Buttons_Scan(void);         /* [0xE7F8] from Task_10Ticks */
void Buttons_StateInit(void);    /* [0xEA88] */
void Buttons_Calibrate(void);    /* [0xEABE] */
byte Button_ReadWindow(byte channel, byte lo, byte hi);  /* [0xE90E] */

/* heating.c - steering-wheel heating (NTC ch 0x03 -> output level) */
void Heating_OutputInit(void);   /* [0xF607] */
void Heating_Task(void);         /* [0xF628] from Task_10Ticks */

/* backlight.c - button backlight PWM (TPM1 channel 2) */
INTERRUPT void Backlight_Isr(void); /* [0xF3B7] TPM1 overflow */
void Backlight_Init(void);       /* [0xF3F1] */
void Backlight_Task(void);       /* [0xF3F8] from Task_10Ticks */
void Backlight_Restart(void);    /* [0xF428] */
void Backlight_PwmOff(void);     /* [0xF464] */
byte Backlight_IsOn(void);       /* [0xF41A] */

/* signals.c - button / scroll-wheel event handlers (publish side) */
byte Scroll_Get(void);           /* [0xEA84] */
extern byte g_scrollEvent;       /* [0x0240] roll-wheel event */
extern byte g_comboEvent;        /* [0x02A6] two-button combo event */

/* lin_app.c - LIN application layer (command decode + supervision) */
void LinApp_Init(void);          /* [0xCC56] */
void LinApp_DecodeCommand(void); /* [0xCC7E] decode subscribed command frame */
void Supervise_Task(void);       /* [0xCCD3] from Task_25Ticks */
void Supervise_Tick(void);       /* [0xCCFC] from Task_10Ticks */
void Lin_Housekeep(void);        /* [0xCD0A] from Task_10Ticks */

/* ports.c extras / power.c - port refresh + sleep */
void Port_Refresh(void);         /* [0xF33B] from Task_10Ticks */
void Ports_SleepIo(void);        /* [0xF385] */
void Ports_SleepDir(void);       /* [0xF39B] */
void Sleep_Enter(void);          /* [0xC6BD] */
void Power_Task(void);           /* [0xC5A1] from Task_10Ticks */
void Sci_Disable(void);          /* [0xCD10] */
void Tick_Advance(byte ticks);   /* [0xC5DE] */
void Wake_SetRequest(byte bits); /* [0xC5CA] */

/* nvm.c extras */
void NvmTask_Run(void);          /* [0xC6F6] from Task_10Ticks */
void Flash_WriteEnter(void);     /* [0xF375] */
void Flash_WriteExit(void);      /* [0xF37D] */

/* backlight.c extras */
void Backlight_Control(void);    /* [0xE796] from Task_10Ticks */
void Backlight_SetGate(byte on); /* [0xE7CB] */

/* buttons.c extras */
void Timers_Tick(void);          /* [0xEC3A] from Task_25Ticks */

/* selftest.c - reset-cause logging + background flash-CRC / RAM tests */
void ResetLog_Init(void);        /* [0xFA6B] */
void SelfTest_Task(void);        /* [0xFAD4] from Task_10Ticks */
void FlashCrc_Step(void);        /* [0xFAE9] */
void RamTest_Step(void);         /* [0xFB9E] */

/* Init-list targets not yet individually reconstructed (placeholder externs
 * so main.c links; each becomes a real module in a later pass). */
void sub_E78B(void);

#endif /* APP_H */
