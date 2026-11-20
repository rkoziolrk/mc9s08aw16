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
single event code for the active button, with wheel steps / paddles in other
bytes. The firmware builds a per-button event-code array (`sub_EABE`,
0x0273[]) and the event codes appear in the image (e.g. 0x07, 0x19, 0x20,
0x21). The **exact B1 code → control table and the B2/B3/B6 layout are the
monitor script's empirical mapping on a fully-equipped wheel** — the firmware
confirms the mechanism and several codes, but the full table could not be
enumerated from the disassembly (the packing routine falls in a linear-sweep
gap). Monitor-confirmed mapping:

| field | meaning |
|-------|---------|
| B1 = 0x01 | MODE |
| B1 = 0x02 | PRAWO (right) |
| B1 = 0x03 | LEWO / MODE |
| B1 = 0x07 | left roller (press) |
| B1 = 0x19 | voice (ROZP. MOWY) |
| B1 = 0x1B | "i"/NAV |
| B1 = 0x20 | right roller (press) |
| B1 = 0x21 | programmable (*) button |
| B1 = 0x06, B3 = steps | left roller rotation (signed) |
| B1 = 0x12, B3 = steps | right roller rotation (signed) |
| B6 = 0x21 / 0x22 | paddle − / paddle + (idle 0x20) |

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

**Not fully verifiable from the image:** the precise B1 event-code → button
table and the B2/B3/B6 field layout of the 0x5000 MFL frame (disassembly gap
in the packing routine). These rest on the script's tested behaviour on a
fully-equipped wheel and are consistent with the event codes found in the
firmware.

## Contrast with the AW32 panel

| | AW32 (A4 B8 panel) | AW16 (A6 C7 module) |
|--|--------------------|---------------------|
| frames | fixed PID table (0xC1AB) | **configurable** (master assigns PIDs) |
| node config | none (transport only) | **full** 0xB0/B1/B2/B3/B4 services |
| button report | **8-bit bitmap** in status frame 0x30 | **event code** in MFL msg 0x5000 |
| supplier id | (computed product id) | 0x0042 Kostal, function 0x000A |
| NAD | 0x0A | 0x0A |
