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
void Tpm1_Init(void);       /* [0xC792] */
void Tpm2_Init(void);       /* [0xC7B6] */

/* lin.c */
void Sci_Init(void);        /* [0xCF10] */
void Sci_SendByte(byte data);/* [0xCF36] */
INTERRUPT void Isr_Sci1(void);/* [0xCF46] */
INTERRUPT void Isr_Tpm2Ch0(void);/* [0xC743] */
extern word g_tpm2NextCompare;

/* sensor.c */
void Sensor_Init(void);     /* [0xE229] */
byte Adc_Read(byte channel);/* [0xE246] */

/* Init-list targets not yet individually reconstructed (placeholder externs
 * so main.c links; each becomes a real module in a later pass). */
void sub_F690(void); void sub_FA6B(void); void sub_E78B(void); void sub_E271(void);
void sub_F3F1(void); void sub_EA88(void); void sub_E7CF(void); void sub_E229(void);
void sub_F73F(void); void sub_E2FB(void); void sub_E517(void); void sub_F607(void);
void sub_CC56(void); void sub_EABE(void);

#endif /* APP_H */
