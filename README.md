# MC9S08AW16 firmware — decompilation

Reverse-engineered **C reconstruction** of `firmware/69d37336-aw16.s19`, an
S19 image for an NXP/Freescale **MC9S08AW16** (8-bit HCS08).

The device is the **Audi A6 C7 multifunction steering-wheel (MFL) module** —
a **LIN slave** that scans the wheel buttons, the scroll/roll wheel, drives
the button backlighting and (on equipped variants) the steering-wheel
heating. See `DEVICE.md`.

It is the same firmware family as the A4 B8 panel in the companion repo
**`rkoziolrk/s909aw32`**, which is used as the structural reference. Unlike
the AW32 part, this 16 KB image is a **single application with no separate
LIN bootloader** (reset vector → 0xC4C0 directly).

> **Status.** Work in progress, reconstructed module-by-module (tracked in
> `PROGRESS.md`). The core (startup, scheduler, time base, clock, COP) is
> reconstructed C; the rest is being filled in. `reference/application.asm`
> is the full symbol-annotated disassembly and the byte-exact ground truth.
> `make check` compiles the C as well-formed C (host gcc).

## Layout
```
README.md / DEVICE.md / PROGRESS.md
Makefile                    `make check` = host syntax check of the C
firmware/69d37336-aw16.s19  the original image
common/mc9s08aw16.h         register map, bit masks, CPU helpers
application/*.c,.h           application modules
reference/application.asm   full annotated disassembly (ground truth)
reference/function_index.md every routine: address + name
```

## Memory map (MC9S08AW16)
| Range | Use |
|-------|-----|
| 0x0000–0x006F | direct-page peripheral registers |
| 0x0070–0x046F | RAM (1 KB) — globals, stack (top 0x046F) |
| 0x0120–0x019F | configuration image (RAM copy) |
| 0x1800–0x185F | high-page registers |
| 0xC000 / 0xC200 | config flash bank A / B (512 B each) |
| 0xC400+ | flash writer + application code |
| 0xFFC0–0xFFFF | CPU vector table |

## Build / verify
```bash
make check     # validates the application C as well-formed C (host gcc)
```
Real target: CodeWarrior for HC(S)08. Reconstructed sources reproduce the
logic/hardware access/tables; a rebuild is not guaranteed byte-identical —
for bit-exact reference use `firmware/*.s19` and `reference/application.asm`.
