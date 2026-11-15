# Device identity — MC9S08AW16

**Audi A6 C7 multifunction steering-wheel (MFL) module**, a **LIN slave**
built on an NXP/Freescale **MC9S08AW16** (HCS08, 16 KB flash, 1 KB RAM).

Confirmed from the image itself: the identity block at flash 0xC000 contains
the ASCII string `... 105E221 - MFL ...` (MFL = *Multifunktionslenkrad*)
with a build date `01 09 2014`.

Functionally it is the same family as the A4 B8 panel decompiled in the
companion repo `mc9s08aw32`: it scans the steering-wheel buttons, the
scroll/roll wheel, drives the button backlighting (PWM) and — on equipped
variants — the steering-wheel heating, and exchanges button/scroll state and
the backlight dimming level with the steering-column module over LIN.

## Key differences vs the AW32 part
- **16 KB flash** at `0xC000-0xFFFF` (base offset 0xC000), **1 KB RAM**
  `0x0070-0x046F` (stack top 0x046F).
- **No separate LIN bootloader.** The CPU reset vector (0xFFFE) points
  straight at the application startup `0xC4C0`; the other vectors point at
  the application's own handlers (default `0xC595`). The AW32 had an all-to-
  one bootloader at 0xF400 — this part does not.
- Peripheral register map is identical (same HCS08 AW family), so
  `common/mc9s08aw16.h` is the AW32 header with the memory-map sizes fixed.

## Variant coding (verified against this image)

Reconstructed in `application/inputs.c`. **Important:** the AW16 coding is
*not* the AW32's table of nine discrete ADC "variant bands". Verified against
`reference/application.asm`, the A6 C7 part identifies the fitted
steering-wheel two ways — exactly the AW32 mechanism, but with a single ADC
validity window instead of a band table:

1. **Analogue coding divider on ADC channel 0x0A.** It is sampled and
   low-pass filtered every 2 ticks (`Coding_Sample`, 0xF80A) into the filtered
   coding value `g_codingAdc` [0x0267], and probed once at start-up
   (`Coding_Probe`, 0xE2FB). A reading is only accepted inside the validity
   window **[0x6F, 0xD1)**; the sampler also treats anything below **0x4E** as
   "channel low / absent". Presence is confirmed by driving the resistor
   low-side/high-side and re-reading (`Meas_LowSide`/`Meas_HighSide`), setting
   `g_codingValid` [0x029E] and `g_codingState` [0x0233] = 0x08.

2. **GPIO strap bits.** `Coding_Calibrate` (0xF73F) walks the `{portPtr,mask}`
   triplet tables in flash at **0xFF71** and **0xFF74** (e.g. `{PTGD,0x08}`,
   `{PTDD,0x08}`) and packs the selected input bits into the coding bytes
   `g_codingStrap0/1` [0x02BD/0x02BE]. This is the AW16 equivalent of the
   AW32 `Variant_ReadStraps`; the finer equipment selection comes from these
   straps plus the NVM/LIN configuration block, not from an ADC band table.

### ADC coding windows in volts (Vref = 5.0 V, 8-bit, U = code/255 × 5 V)

| Code | Voltage | Meaning |
|-----:|:-------:|:--------|
| < 0x4E (78) | < 1.53 V | channel low → coding absent (sampler ignores) |
| 0x6F (111) | 2.18 V | low edge of the **valid coding window** |
| 0xD1 (209) | 4.10 V | high edge (exclusive) of the valid coding window |

So a plausible coded steering-wheel presents **2.18–4.10 V** on channel 0x0A
and passes the resistor low/high-side plausibility check. The equipment
actually enabled (buttons / scroll+backlight / heating) is then selected from
the strap bytes and the configuration block; the feature-gating map is being
traced as the button/backlight/heating modules are reconstructed (see
PROGRESS.md). Heating uses the NTC on **ADC channel 0x03** (open/short window
[0x15, 0xF8), `0xF628`) and the button resistor ladder uses **ADC channel
0x02**.

## Naming note (ch 0x0A acquisition vs. variant coding)

For historical reasons the ADC channel-0x0A acquisition chain in `inputs.c`
carries `Coding_*` names (`Coding_Sample`/`Coding_Normalize`/… → `g_codingAdc`
[0x0267], `g_codingNorm*` [0x026C]). Verified against the image, that chain's
normalised output is actually the **backlight dimming level** that the TPM1
ch-2 PWM follows (`Backlight_Isr`, 0xF3B7), and the detection state machine in
`wheel_io.c` validates that same channel. The **variant/equipment coding** is
the separate GPIO-strap read (`Coding_Calibrate`, 0xF73F, tables 0xFF71/0xFF74
→ `g_codingStrap0/1` [0x02BD/0x02BE]). The two are distinct; the `Coding_*`
acquisition names should be read as "the dimming/level channel", not the
variant code. Symbols were left stable to keep the commit history and the
`[0xXXXX]` anchors legible; this note is the authoritative mapping.
