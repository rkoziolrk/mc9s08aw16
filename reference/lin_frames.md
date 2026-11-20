# LIN frames — MC9S08AW16 MFL module (Audi A6 C7)

LIN 2.1 slave. **Unlike the AW32 panel, this node uses configurable frames
and a full LIN node-configuration service layer** (the master assigns a
protected ID to each message at runtime, then polls it). Derived from
`reference/application.asm`, the stack in `application/lin*.c` /
`signals.c` / `heating.c`, and the flash tables.

## Identity / node configuration

* **Node NAD = `0x0A`** (wildcard `0x7F` also accepted).
* **Supplier ID = `0x0042`** (Kostal), **Function ID = `0x000A`**,
  **Variant = `0x00`** — the Read-by-Identifier (id 0) response builds
  `42 00 0A 00 00` at `$BC..$C0` (0xD8E6-0xD8F2).
* Diagnostic frames: **master request ID `0x3C`** (PID 0x3C),
  **slave response ID `0x3D`** (PID 0x7D) (0xDADD/0xDAE5).

### Node-configuration services (dispatcher at 0xD840)

| SID | service | positive resp |
|:---:|---------|:-------------:|
| 0xB0 | Assign NAD | 0xF0 |
| 0xB1 | Assign frame ID (message → PID) | **0xF1** |
| 0xB2 | Read by Identifier (product id / supplier / function / variant) | 0xF2 |
| 0xB3 | Conditional change NAD | 0xF3 |
| 0xB4 | (data dump / save config) | 0xF4 |

The B1 handler validates supplier `0x42` (or wildcard `0x7F`), looks the
requested 16-bit message ID up in the flash table and stores the assigned PID.

### Configurable message table (flash `0xFED7`, big-endian, 4 entries)

| idx | message ID | role | assigned-PID slot |
|:---:|:----------:|------|:-----------------:|
| 0 | **0x5000** | MFL: buttons / rollers / paddles | 0x01E5[0] |
| 1 | **0x503B** | (unused on the tested wheel — the monitor unassigns it, PID 0xFF) | 0x01E5[1] |
| 2 | **0x503A** | heating + NTC (LRH) | 0x01E5[2] |
| 3 | **0x5001** | 4th message (purpose not identified) | 0x01E5[3] |

The master assigns each message a protected ID via service 0xB1, then polls
that ID; the slave publishes the message's content.

---

## Published message content

### MFL — message `0x5000` (8 bytes)
**Event-code model** (not a bitmap like the AW32 panel): the byte **B1** is a
single event code for the active control, with wheel steps / paddles in other
bytes.

**The B1 event codes exist as CONFIGURABLE data in the NVM config image**, not
hard-coded. A contiguous table at config offset **0x35** (NVM `0xC035` bank A /
`0xC235` bank B → RAM `0x0155`), right after an ASCII label at offset 0x28,
holds exactly the codes the monitor decodes:

```
cfg+0x28: "221 - MFL"                             <- ASCII variant/part label
cfg+0x35: 21 1B 19 07 01 03 02 06 12 28 20 ...    <- event-code table
```

Because it is NVM data it can differ per wheel. The values above are from the
decompiled image and **match the monitor script's decode map exactly** (10 of
the script's distinct codes appear here, contiguously):

| B1 code | control | in cfg table |
|:-------:|---------|:------------:|
| 0x01 | MODE | ✔ |
| 0x02 | PRAWO (right) | ✔ |
| 0x03 | LEWO / MODE | ✔ |
| 0x07 | left roller (press) | ✔ |
| 0x19 | voice (ROZP. MOWY) | ✔ |
| 0x1B | "i"/NAV | ✔ |
| 0x20 | right roller (press) | ✔ |
| 0x21 | programmable (*) button | ✔ |
| 0x06 (B3 = steps) | left roller rotation (signed) | ✔ |
| 0x12 (B3 = steps) | right roller rotation (signed) | ✔ |
| B6 = 0x21 / 0x22 | paddle − / paddle + (idle 0x20) | 0x21 in table |

(The table also holds 0x28, a slot not named by the monitor — an unused /
not-fitted control on the tested wheel.) So the **B1 code set is firmware data
that matches the script**. What is *not* firmware-traced: the packer that
selects a control's code and places it (and the wheel steps / paddle) into the
frame bytes — it is reached indirectly (switch-jump trampoline) and lives in a
linear-sweep gap, so **which byte is B1/B3/B6 rests on the script's tested
layout**. (Caution: the config also holds an unrelated table at offset 0x61
`05 06 07 … 14` that feeds the *illumination* controller, not the button map —
do not confuse the two.)

### Heating / NTC — message `0x503A` (2 bytes, "LRH")
* **B0 = NTC temperature**, offset by 50 → `°C = B0 − 50` (the 0x32 offset is
  applied in the builder, 0xD5F9). Error codes: **`0xFF` = NTC open**,
  **`0xFD` = NTC short** (see `heating.c`, `g_heatOut` encoding).
* **B1 bit0 = heating button** pressed.
* Heating is an **optional feature** (equipment bit in state byte 0x019C); on a
  wheel without heating this message is not meaningful.

### Identification
Exposed through the Read-by-Identifier service (above): supplier `0x0042`,
function `0x000A`, variant `0x00`.

---

## Comparison with the monitor script (`mfl_lin_monitor.py`)

Everything the script relies on is **confirmed in the firmware**:

* config sequence — assign frame IDs via **0xB1** / supplier **0x0042** / NAD
  **0x0A**, response **0xF1**; ✔
* message IDs **0x5000 / 0x503A / 0x503B** are real node messages (plus
  0x5001); unassigning 0x503B (PID 0xFF) is valid; ✔
* diagnostic request/response IDs **0x3C / 0x3D**; ✔
* heating decode: NTC `B0 − 50`, `0xFF`/`0xFD` error codes, button in B1.b0. ✔

* MFL B1 event codes — **confirmed**: the code values the script decodes are
  the configurable table in the NVM image at cfg+0x35 (see above). ✔

**Still script-derived (not firmware-proven):** only the exact B2/B3/B6 field
*positions* inside the 8-byte 0x5000 frame — the packing routine is in a
linear-sweep gap in the disassembly. The B1 code set itself is firmware data.

## Contrast with the AW32 panel

| | AW32 (A4 B8 panel) | AW16 (A6 C7 module) |
|--|--------------------|---------------------|
| frames | fixed PID table (0xC1AB) | **configurable** (master assigns PIDs) |
| node config | none (transport only) | **full** 0xB0/B1/B2/B3/B4 services |
| button report | **8-bit bitmap** in status frame 0x30 | **event code** in MFL msg 0x5000 |
| supplier id | (computed product id) | 0x0042 Kostal, function 0x000A |
| NAD | 0x0A | 0x0A |
