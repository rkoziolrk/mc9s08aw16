/*
 * signals.c - Button / scroll-wheel event handlers (the "publish" side of the
 *             LIN signals) for the MC9S08AW16 MFL module.
 *
 * Each button scanned in buttons.c dispatches its debounced press/release
 * edge (via the 0xFCD8 trampoline) to one of the handlers below with the
 * level in A (1 = pressed, 0 = released).  The handlers write the published
 * button-state bytes [0x0271..0x0282], the scroll/roll event [0x0240] and the
 * combo event [0x02A6]; the LIN transport later packs these into the slave's
 * response frame.
 *
 * Published signal bytes (verified from the handler disassembly at
 * 0xE929..0xEA87 - this region is a linear-sweep gap in application.asm):
 *   [0x0271] button on ADC ch 8        [0x0272] button on ADC ch 9
 *   [0x0274]/[0x0276]/[0x0278]/[0x027A] the 4 port-C GPIO buttons
 *   [0x027C]/[0x027E] the two ch-1 ladder buttons  (exclusion latch [0x023E])
 *   [0x0280]/[0x0282] the two ch-0 ladder buttons  (exclusion latch [0x023F])
 *   [0x027B]/[0x027D] ch-1 combo markers (bit7)     combo-active [0x023D] b1
 *   [0x027F]/[0x0281] ch-0 combo markers (bit7)     combo-active [0x023D] b0
 *   [0x0240] scroll/roll event   [0x02A4]/[0x02A5] roll up/down latches
 *   [0x02A6] two-button combo event      [0x0197] scroll-enable gate
 *
 * Addresses in brackets are the absolute flash/RAM addresses of the original.
 */
#include "app.h"

/* signal bytes (direct absolute access keeps the addresses exact) */
#define SIG(a)  (*(volatile byte *)(a))

byte g_scrollEvent AT(0x0240);   /* roll-wheel increment event    */
byte g_comboEvent  AT(0x02A6);   /* two-button combo event        */
extern byte g_cfg0197 AT(0x0197);/* scroll-enable gate            */

/* ======================================================================
 * The 4 port-C GPIO buttons [0xE939/0xE9B6/0xE9BA/0xE9BE]
 * Each simply publishes its pressed state to its signal byte.
 * ====================================================================== */
void Sig_GpioA0(byte pressed) { SIG(0x0274) = pressed; }   /* [0xE939] */
void Sig_GpioA1(byte pressed) { SIG(0x0276) = pressed; }   /* [0xE9B6] */
void Sig_GpioA2(byte pressed) { SIG(0x0278) = pressed; }   /* [0xE9BA] */
void Sig_GpioA3(byte pressed) { SIG(0x027A) = pressed; }   /* [0xE9BE] */

/* ======================================================================
 * ch-8 / ch-9 single buttons [0xEA68/0xEA4C]
 * ====================================================================== */
void Sig_Ch8Btn(byte pressed) { SIG(0x0271) = pressed; }   /* [0xEA68] */
void Sig_Ch9Btn(byte pressed) { SIG(0x0272) = pressed; }   /* [0xEA4C] */

/* ======================================================================
 * ch-1 ladder buttons [0xE929/0xE93D] and their combined window [0xE94D].
 * The hi/mid windows publish only while the combined-window latch [0x023E]
 * is clear; the combined window sets both and the latch when pressed.
 * ====================================================================== */
void Sig_Ch1Hi(byte pressed)   { if (SIG(0x023E) == 0) SIG(0x027C) = pressed; }   /* [0xE929] */
void Sig_Ch1Mid(byte pressed)  { if (SIG(0x023E) == 0) SIG(0x027E) = pressed; }   /* [0xE93D] */
void Sig_Ch1Both(byte pressed)                                                    /* [0xE94D] */
{
    if (pressed == 1) {
        SIG(0x027E) = 1;
        SIG(0x027C) = 1;
    }
    SIG(0x023E) = pressed;
}

/* ======================================================================
 * ch-0 ladder buttons [0xE9C2/0xE9D2] and their combined window [0xE9E2].
 * ====================================================================== */
void Sig_Ch0Hi(byte pressed)   { if (SIG(0x023F) == 0) SIG(0x0280) = pressed; }   /* [0xE9C2] */
void Sig_Ch0Mid(byte pressed)  { if (SIG(0x023F) == 0) SIG(0x0282) = pressed; }   /* [0xE9D2] */
void Sig_Ch0Both(byte pressed)                                                    /* [0xE9E2] */
{
    if (pressed == 1) {
        SIG(0x0280) = 1;
        SIG(0x0282) = 1;
    }
    SIG(0x023F) = pressed;
}

/* ----------------------------------------------------------------------
 * Combo detector helper: the ch-0 / ch-1 "wide" windows (0x2B..0xE2) fire
 * when any button on that ladder is held.  When both of a channel's buttons
 * are held, a combo event is raised ([0x02A6]=1), the two markers get bit7
 * set and the button states are reset; on release it is cleared again.
 *   activeBit : the [0x023D] combo-active bit for this channel
 *   mk0,mk1   : the two combo-marker bytes
 *   b0,b1     : the two button-state bytes to clear
 * This mirrors 0xE95E (ch1) and 0xE9F3 (ch0).
 * -------------------------------------------------------------------- */
static void Combo_Update(byte pressed, byte activeBit,
                         word mk0, word mk1, word b0, word b1)
{
    if (pressed == 1) {
        /* release/settle path [0xE960/0xE9F5] */
        if ((SIG(mk1) & 0x80) || (SIG(mk0) & 0x80)) {
            if (SIG(0x023D) & activeBit) {
                SIG(0x023D) &= (byte)~activeBit;
                SIG(mk1) = 0x0F;
                SIG(mk0) = 0x0F;
                SIG(b1)  = 0;
                SIG(b0)  = 0;
                g_comboEvent = 0;
            }
        }
    } else {
        /* press path [0xE98D/0xEA22] */
        if ((SIG(0x023D) & activeBit) == 0) {
            SIG(0x023D) |= activeBit;
            Buttons_StateInit();          /* [0xEA88] */
            SIG(mk1) |= 0x80;
            SIG(mk0) |= 0x80;
            SIG(b1)   = 0;                /* clr 3,x (HX=mk0) [0xE9AC] */
            SIG(b0)   = 0;                /* clr 1,x (HX=mk0) [0xE9AE] */
            g_comboEvent = 1;
        }
    }
}

void Sig_Ch1Combo(byte pressed)   /* [0xE95E] */
{
    Combo_Update(pressed, 0x02, 0x027B, 0x027D, 0x027C, 0x027E);
}

void Sig_Ch0Combo(byte pressed)   /* [0xE9F3] */
{
    Combo_Update(pressed, 0x01, 0x027F, 0x0281, 0x0280, 0x0282);
}

/* ======================================================================
 * Scroll / roll-wheel [0xEA50 (ch9) / 0xEA6C (ch8)]
 * The roll wheel is read as two ADC windows (ch 8 and ch 9).  A press on one
 * side, while scrolling is enabled ([0x0197]==1) and the opposite latch is
 * not already set, raises the scroll event [0x0240] and the side latch
 * ([0x02A4] or [0x02A5]); otherwise both are forced to 1 (step registered).
 * ====================================================================== */
void Sig_RollUp(byte pressed)     /* [0xEA50] ch9 */
{
    byte v;
    if (pressed == 1 && g_cfg0197 == 1) {
        if (SIG(0x02A4) != 1) {
            return;                       /* not yet latched -> no step */
        }
        v = 0;                            /* clear the registered step */
    } else {
        v = 1;                            /* register a step           */
    }
    g_scrollEvent = v;
    SIG(0x02A4)   = v;
}

void Sig_RollDown(byte pressed)   /* [0xEA6C] ch8 */
{
    byte v;
    if (pressed == 1 && g_cfg0197 == 1) {
        if (SIG(0x02A5) != 1) {
            return;
        }
        v = 0;
    } else {
        v = 1;
    }
    g_scrollEvent = v;
    SIG(0x02A5)   = v;
}

/* ======================================================================
 * Scroll_Get  [0xEA84]
 * Return the current roll-wheel event byte [0x0240].
 * ====================================================================== */
byte Scroll_Get(void)
{
    return g_scrollEvent;
}
