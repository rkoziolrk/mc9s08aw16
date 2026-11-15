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

> **Status.** The whole application is reconstructed to commented C, module by
> module (tracked in `PROGRESS.md`): start-up and the full `App_InitAll`,
> the cooperative scheduler and its periodic tasks, the ADC coding/dimming
> acquisition, the detection/excitation engine, the button scan + debounce
> and the published button/scroll signals, the backlight PWM, heating, the
> reset log + background self-tests, the LIN application layer (command decode
> + supervision) and the LIN transport timers/diagnostics/autobaud. A handful
> of LIN transport-core leaf helpers remain as documented externs (see
> `PROGRESS.md`). `reference/application.asm` is the full symbol-annotated
> disassembly and the byte-exact ground truth; `make check` compiles every
> source as well-formed C (host gcc).

## Module coverage

| File | What it reconstructs |
|------|----------------------|
| `main.c` | reset/start-up, `App_InitAll`, clock/COP/SOPT, scheduler, default ISR |
| `tasks.c` | the 2/10/25-tick periodic tasks + the 10-slot round robin |
| `timebase.c` | TPM1/TPM2 init, the 1 ms time-base ISR |
| `ports.c` | GPIO init, periodic port refresh, sleep pin states |
| `sensor.c` | ADC front-end + single-conversion read |
| `inputs.c` | steering-wheel coding/variant detection + ADC acquisition |
| `wheel_io.c` | excitation drive ISR + coding/ladder measurement + detect SM |
| `buttons.c` | button scan + nibble debounce + soft timers |
| `signals.c` | button/scroll event handlers → published signal bytes |
| `backlight.c` | button-backlight PWM (TPM1 ch2) + on/off control |
| `heating.c` | steering-wheel heating (NTC ch 3 → output level) |
| `selftest.c` | reset-cause log + background flash-CRC / RAM tests |
| `nvm.c` | flash config store (dual bank) + background write task |
| `power.c` | STOP sleep entry + power/bus-timeout task |
| `lin.c` | SCI/LIN byte engines + TPM2-capture autobaud |
| `lin_app.c` | LIN command decode + node supervision |
| `lin_transport.c` | LIN schedule/diagnostics + ISO-TP timers |
| `filters.c` | slew-rate filter, table interpolation, dispatch trampoline |
| `util.c` | critical sections, delay, modulo helper |

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
