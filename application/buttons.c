/*
 * buttons.c - Steering-wheel button scan + debounce for the MC9S08AW16 MFL
 *             module (the AW16 counterpart of the AW32 buttons.c).
 *
 * The wheel's buttons are read two ways, both scanned from Task_10Ticks:
 *
 *   Group A - 4 GPIO buttons on port C (PTCD, 0x0004), read as direct
 *             digital inputs.  Config table at flash 0xFF25, 4 bytes/entry:
 *                 { portReg, mask, handlerHi, handlerLo }
 *   Group B - 12 resistor-ladder buttons read as ADC windows on channels
 *             0, 1, 8 and 9.  Config table at flash 0xFF35, 5 bytes/entry:
 *                 { channel, loThresh, hiThresh, handlerHi, handlerLo }
 *             a reading in [lo,hi] counts as "pressed".
 *
 * Each button has a per-button nibble debounce counter in g_btnState[]
 * [0x0241..0x0250]; the low nibble counts up/down with the sampled level and
 * the press/release edge is dispatched to the button's handler (the 0xE9xx /
 * 0xEA6C entries, which set the published LIN signal bits) through the
 * indirect-call trampoline at 0xFCD8 when the counter saturates at 0x0 or 0xF.
 *
 * Addresses in brackets are the absolute flash/RAM addresses of the original.
 */
#include "app.h"

/* ---- button debounce state (RAM) ------------------------------------- */
/* g_btnState[i] [0x0241+i]: bit4 = confirmed-pressed latch, bits3..0 = the
 * debounce counter (0 = released, 0x0F = pressed). */
static volatile byte *const g_btnState = (volatile byte *)0x0241;
byte g_btnCalDone AT(0x023D);   /* set once the init warm-up scan has run */
byte g_btnEvent   AT(0x0257);   /* any-button-changed flag (EABE/E7F8)    */

/* ---- group-A GPIO button table (flash 0xFF25) ------------------------ */
typedef struct { byte reg; byte mask; byte hHi; byte hLo; } BtnGpio;
static const BtnGpio s_btnGpio[4] = {
    { 0x04, 0x08, 0xE9, 0x39 },   /* PTCD.3  -> handler 0xE939 */
    { 0x04, 0x20, 0xE9, 0xB6 },   /* PTCD.5  -> handler 0xE9B6 */
    { 0x04, 0x02, 0xE9, 0xBA },   /* PTCD.1  -> handler 0xE9BA */
    { 0x04, 0x04, 0xE9, 0xBE },   /* PTCD.2  -> handler 0xE9BE */
};

/* ---- group-B ADC-ladder button table (flash 0xFF35) ------------------ */
typedef struct { byte ch; byte lo; byte hi; byte hHi; byte hLo; } BtnLadder;
static const BtnLadder s_btnLadder[12] = {
    { 0x00, 0x64, 0x9E, 0xE9, 0xC2 },   /* ch0 window -> 0xE9C2 */
    { 0x00, 0x4D, 0x64, 0xE9, 0xD2 },   /* ch0 window -> 0xE9D2 */
    { 0x00, 0x2B, 0x4D, 0xE9, 0xE2 },   /* ch0 window -> 0xE9E2 */
    { 0x01, 0x64, 0x9E, 0xE9, 0x29 },   /* ch1 window -> 0xE929 */
    { 0x01, 0x4D, 0x64, 0xE9, 0x3D },   /* ch1 window -> 0xE93D */
    { 0x01, 0x2B, 0x4D, 0xE9, 0x4D },   /* ch1 window -> 0xE94D */
    { 0x09, 0x38, 0x89, 0xEA, 0x4C },   /* ch9 window -> 0xEA4C */
    { 0x08, 0x38, 0x89, 0xEA, 0x68 },   /* ch8 window -> 0xEA68 */
    { 0x00, 0x2B, 0xE2, 0xE9, 0xF3 },   /* ch0 wide   -> 0xE9F3 */
    { 0x01, 0x2B, 0xE2, 0xE9, 0x5E },   /* ch1 wide   -> 0xE95E */
    { 0x09, 0x38, 0xD8, 0xEA, 0x50 },   /* ch9 wide   -> 0xEA50 */
    { 0x08, 0x38, 0xD8, 0xEA, 0x6C },   /* ch8 wide   -> 0xEA6C */
};

/* indirect handler dispatch via the 0xFCD8 trampoline; 'pressed' is passed in
 * A to the handler (0 = release edge, 1 = press edge). */
extern void Btn_Dispatch(byte hHi, byte hLo, byte pressed);   /* [0xFCD8] */

/* ======================================================================
 * Buttons_Init  [0xE7CF]   (called from App_InitAll, 0xC57A)
 * Clears the per-button debounce array (g_btnState[0..15]) and the
 * calibration-done flag [0x023D].  (The first 4 entries are cleared, then all
 * 16, matching the original's two loops.)
 * ====================================================================== */
void Buttons_Init(void)
{
    byte i;
    for (i = 0; i < 0x10; i++) {
        g_btnState[i] = 0;
    }
    g_btnCalDone = 0;
}

/* ----------------------------------------------------------------------
 * Button_Debounce - fold one new sample into a button's nibble counter and
 * fire the press/release edge.  'level' is the sampled state (1 = active).
 * Faithful transcription of the 0xE814 / 0xE889 nibble logic:
 *   - the counter is advanced while the input is active,
 *   - at 0x00 the release edge is dispatched and the latch cleared,
 *   - at 0x0F the press edge is dispatched and the latch (0x1F) set.
 * -------------------------------------------------------------------- */
static void Button_Debounce(byte idx, byte level, byte hHi, byte hLo)
{
    byte nib = (byte)((g_btnState[idx] << 1) & 0x1E);
    if (level) {
        nib++;
    }
    nib &= 0x0F;

    if (nib == 0) {
        g_btnState[idx] = 0x00;               /* confirmed release */
        Btn_Dispatch(hHi, hLo, 0);            /* [0xFCD8] */
    } else if (nib == 0x0F) {
        g_btnState[idx] = 0x1F;               /* confirmed press   */
        Btn_Dispatch(hHi, hLo, 1);            /* [0xFCD8] */
    } else {
        g_btnState[idx] = (byte)((g_btnState[idx] & 0xF0) | nib);
    }
}

/* ======================================================================
 * Button_ReadWindow  [0xE90E]
 * Read ADC 'channel' and return 1 if the result is within [lo,hi], else 0.
 * ====================================================================== */
byte Button_ReadWindow(byte channel, byte lo, byte hi)
{
    byte v = Adc_Read(channel);
    if (hi >= v && v >= lo) {
        return 1;
    }
    return 0;
}

/* ======================================================================
 * Buttons_ScanGpio  [0xE814]   (group A, 4 port-C buttons)
 * ====================================================================== */
static void Buttons_ScanGpio(byte i)
{
    const BtnGpio *b = &s_btnGpio[i];
    byte level = (*(volatile byte *)(word)b->reg & b->mask) ? 1 : 0;
    Button_Debounce(i, level, b->hHi, b->hLo);
}

/* ======================================================================
 * Buttons_ScanLadder  [0xE889]   (group B, 12 ADC-ladder buttons)
 * The ladder entries share the debounce array starting at index 4.
 * ====================================================================== */
static void Buttons_ScanLadder(byte i)
{
    const BtnLadder *b = &s_btnLadder[i];
    byte level = Button_ReadWindow(b->ch, b->lo, b->hi);   /* [0xE90E] */
    Button_Debounce((byte)(i + 4), level, b->hHi, b->hLo);
}

/* ======================================================================
 * Buttons_Scan  [0xE7F8]   (called from Task_10Ticks, 0xC657)
 * Scan the 4 GPIO buttons then the 12 ladder buttons.
 * ====================================================================== */
void Buttons_Scan(void)
{
    byte i;
    for (i = 0; i < 4; i++) {
        Buttons_ScanGpio(i);
    }
    for (i = 0; i < 0x0C; i++) {
        Buttons_ScanLadder(i);
    }
}

/* ======================================================================
 * Buttons_StateInit  [0xEA88]   (called from App_InitAll, 0xC577)
 * Clears the button-output / event-timer block [0x0251..0x0261] and arms the
 * ladder-calibration flag [0x0295].
 * ====================================================================== */
void Buttons_StateInit(void)
{
    byte a;
    for (a = 0x51; a <= 0x61; a++) {
        *(volatile byte *)(0x0200 + a) = 0;     /* 0x0251..0x0261 */
    }
    *(volatile byte *)0x0295 = 1;
}

/* ======================================================================
 * Buttons_Calibrate  [0xEABE]   (called from App_InitAll, 0xC58F)
 * Runs the button scan 5 times as a warm-up, then calibrates the per-button
 * ladder reference levels g_ladderRef[] [0x0273+i*2] from the measured
 * thresholds g_ladderThr[] [0x0274+i*2]:
 *     thr 0x07 -> ref 0x09,  thr 0x04 -> ref 0x06,  else ref 0x03.
 * Finally latches the button-event flag [0x0257] if either sticky input
 * [0x0271]/[0x0272] is set.
 * ====================================================================== */
void Buttons_Calibrate(void)
{
    byte i;

    g_btnEvent = 0;
    for (i = 0; i < 5; i++) {
        Buttons_Scan();                         /* [0xEAC5] warm-up */
    }

    for (i = 0; i < 8; i++) {
        byte thr = *(volatile byte *)(0x0274 + (word)(i << 1));
        if (thr == 1) {                         /* dbnza: act only when thr==1 */
            byte ref;
            byte cur = *(volatile byte *)(0x0273 + (word)(i << 1));
            if (cur == 0x07)      ref = 0x09;
            else if (cur == 0x04) ref = 0x06;
            else                  ref = 0x03;
            *(volatile byte *)(0x0273 + (word)(i << 1)) = ref;
        }
    }

    if (*(volatile byte *)0x0271 == 1) g_btnEvent = 1;
    if (*(volatile byte *)0x0272 == 1) g_btnEvent = 1;
}
