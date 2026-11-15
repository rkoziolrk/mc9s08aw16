/*
 * main.c - Application entry point, CPU/clock init, the time base and the
 *          cooperative scheduler for the MC9S08AW16 MFL module.
 *
 * Decompiled from the single application image (there is NO separate LIN
 * bootloader on this part, unlike the AW32 sibling: the CPU reset vector
 * 0xFFFE points straight at App_Startup = 0xC4C0). Addresses in brackets
 * are the absolute flash/RAM addresses of the original.
 *
 * Device: Audi A6 C7 multifunction steering-wheel (MFL) module, a LIN
 * slave (the image carries the ident string "...105E221 - MFL..."). See
 * DEVICE.md. The firmware is the same family as the A4 B8 panel in the
 * companion repo `s909aw32`, so the module structure is nearly identical.
 */
#include "app.h"

/* ---- scheduler / time base ------------------------------------------- */
volatile byte g_tickCount    AT(0x01A0);  /* 0..99, incremented by the TPM2CH0 ISR */
volatile byte g_tickFlag     AT(0x01A1);  /* set by the ISR, cleared by main()     */
byte          g_slot10       AT(0x01A2);  /* 1..10 sub-slot of the 10-tick task     */
byte          g_tickSnapshot AT(0x01A3);  /* copy of g_tickCount used by scheduler  */

static void Scheduler_Run(void);          /* [0xC5FA] */

/* ======================================================================
 * App_Startup  [0xC4C0]  (reset entry, = CPU reset vector)
 * Sets the stack (0x046F = top of the 1 KB RAM), runs the CodeWarrior
 * startup-data copy (ROM table at 0xFE80: copy initialised data, zero-fill
 * records), zeros the BSS (0x01A0..0x02C1) and calls main().
 * ====================================================================== */
void App_Startup(void)
{
    /* crt0: SP=0x046F; copy .data from the 0xFE80 table; zero 0x01A0..0x02C1.
     * The exact record walk is the compiler's startup; see
     * reference/application.asm 0xC4C0-0xC527. */
    word a;
    for (a = 0x01A0; a < 0x02C2; a++) {
        *(volatile byte *)a = 0;
    }
    main();
    for (;;) { }
}

/* ======================================================================
 * main  [0xC52D]
 * ====================================================================== */
void main(void)
{
    App_InitAll();                     /* [0xC54D] */
    g_tickCount    = 0;
    g_tickSnapshot = 0;
    g_slot10       = 0;
    g_tickFlag     = 0;
    SRTISC         = 0x00;

    for (;;) {
        while (g_tickFlag != 1) {
            /* wait for the next time-base tick */
        }
        Scheduler_Run();               /* [0xC5FA] */
        g_tickFlag = 0;
    }
}

/* ======================================================================
 * App_InitAll  [0xC54D]
 * Full hardware + software init, run once at startup (and after wake).
 * The confirmed early steps are named; the later module inits are listed
 * by their flash address and reconstructed in their own files (tracked in
 * PROGRESS.md). Order and addresses from reference/application.asm.
 * ====================================================================== */
void App_InitAll(void)
{
    EnterCritical();        /* [0xF5E6] */
    Clock_Init();           /* [0xC6D0] ICG FEI, bus clock, NV trim        */
    SysOpt_Init();          /* [0xC6EF] SOPT=0xEF (COP+STOP), then COP_Feed */
    COP_Feed();             /* [0xC739] */
    Ports_Init();           /* [0xF28E] GPIO directions / pull-ups         */
    Nvm_Init();             /* [0xC7DB] load configuration from flash       */
    Inputs_Init();          /* [0xF690] coding/ladder input state init       */
    Tpm2_Init();            /* [0xC7B6] time base + LIN capture             */
    COP_Feed();             /* [0xC739] */
    Tpm1_Init();            /* [0xC792] PWM (backlight)                     */
    sub_FA6B();             /* [0xFA6B] */
    sub_E78B();             /* [0xE78B] */
    Coding_Reset();         /* [0xE271] reset normalised coding value       */
    Backlight_Init();       /* [0xF3F1] park backlight PWM                  */
    Buttons_StateInit();    /* [0xEA88] button output/event state init       */
    Buttons_Init();         /* [0xE7CF] button debounce array init           */
    Sensor_Init();          /* [0xE229] ADC analogue front-end init          */
    Coding_Calibrate();     /* [0xF73F] build strap coding + delays          */
    Coding_Probe();         /* [0xE2FB] coding validity + plausibility probe */
    Detect_Init();          /* [0xE517] detect/scan engine init             */
    Heating_OutputInit();   /* [0xF607] heating output default state         */
    sub_CC56();             /* [0xCC56] */
    Buttons_Calibrate();    /* [0xEABE] ladder reference calibration         */
    ExitCritical();         /* [0xF5F3] (jmp tail) */
}

/* ======================================================================
 * Isr_Default  [0xC595]
 * Handler for every unused vector (and most peripheral vectors here):
 * saves one zero-page byte, restarts the application, restores, returns.
 * ====================================================================== */
INTERRUPT void Isr_Default(void)
{
    App_Startup();
}

/* ======================================================================
 * Scheduler_Run  [0xC5FA]  (once per time-base tick)
 *   every 2 ticks  -> Task_2Ticks   [0xC644]
 *   every 10 ticks -> Task_10Ticks  [0xC64A]
 *   every 25 ticks -> Task_25Ticks  [0xC6B7]
 * wraps g_tickCount at 100.
 * ====================================================================== */
static void Scheduler_Run(void)
{
    g_tickSnapshot = g_tickCount;

    if ((g_tickSnapshot & 0x01) == 0) {
        Task_2Ticks();                 /* [0xC644] */
    }
    if (u8_mod(g_tickSnapshot, 0x0A) == 0 && g_scratch == 0) {
        Task_10Ticks();                /* [0xC64A] */
    }
    if (u8_mod(g_tickSnapshot, 0x19) == 0 && g_scratch == 0) {
        Task_25Ticks();                /* [0xC6B7] */
    }
    if (g_tickSnapshot >= 100) {
        EnterCritical();
        g_tickCount    = 0;
        g_tickSnapshot = 0;
        ExitCritical();
    }
}

/* ======================================================================
 * Clock_Init  [0xC6D0]  ICG in FEI mode (ICGC1=0x2A, ICGC2=0x70), wait for
 * FLL lock + DCO stable, load the factory trim from NVICGTRM (0xFFBE).
 * ====================================================================== */
void Clock_Init(void)
{
    ICGC1 = 0x2A;
    ICGC2 = 0x70;
    while ((ICGS1 & ICGS1_LOCK) == 0) { }
    while ((ICGS2 & ICGS2_DCOS) == 0) { }
    ICGTRM = NVICGTRM;
}

/* [0xC6EF] SOPT = 0xEF (COP + STOP enabled), then service the COP */
void SysOpt_Init(void)
{
    SOPT = 0xEF;
    COP_Feed();
}

/* [0xC739] Service the COP watchdog: write 0x55 then 0xAA (0x55<<1) to SRS */
void COP_Feed(void)
{
    SRS = 0x55;
    SRS = 0xAA;
}
