# Device identity — MC9S08AW16

**Audi A6 C7 multifunction steering-wheel (MFL) module**, a **LIN slave**
built on an NXP/Freescale **MC9S08AW16** (HCS08, 16 KB flash, 1 KB RAM).

Confirmed from the image itself: the identity block at flash 0xC000 contains
the ASCII string `... 105E221 - MFL ...` (MFL = *Multifunktionslenkrad*)
with a build date `01 09 2014`.

Functionally it is the same family as the A4 B8 panel decompiled in the
companion repo `s909aw32`: it scans the steering-wheel buttons, the
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

## Variant coding
The steering-wheel variant/feature coding (resistor on an ADC channel → the
feature bitmask) works the same way as on the AW32; the exact ADC windows
and the equipment table will be filled in once `Adc_DetectVariant` is
reconstructed (see PROGRESS.md). Vref assumed 5 V.
