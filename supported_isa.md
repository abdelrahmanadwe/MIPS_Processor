# MIPS Supported ISA Reference Manual

This document details all the instructions supported by our MIPS Processor implementation, including their formats, opcodes, funct codes, and behavior.

---

## 1. R-Type Instructions (Opcode = `000000`)

All R-type instructions have an opcode of `000000` and are distinguished by their **funct** code.

| Instruction | Funct (Bin) | Funct (Dec) | Format | Operation / Behavior |
| :--- | :--- | :--- | :--- | :--- |
| **`add`** | `100000` | `32` | `add rd, rs, rt` | Signed Addition: `rd = rs + rt` (overflow triggers alert) |
| **`addu`** | `100001` | `33` | `addu rd, rs, rt` | Unsigned Addition: `rd = rs + rt` (no overflow checks) |
| **`sub`** | `100010` | `34` | `sub rd, rs, rt` | Signed Subtraction: `rd = rs - rt` |
| **`subu`** | `100011` | `35` | `subu rd, rs, rt` | Unsigned Subtraction: `rd = rs - rt` |
| **`and`** | `100100` | `36` | `and rd, rs, rt` | Bitwise AND: `rd = rs & rt` |
| **`or`** | `100101` | `37` | `or rd, rs, rt` | Bitwise OR: `rd = rs \| rt` |
| **`slt`** | `101010` | `42` | `slt rd, rs, rt` | Signed Compare: `rd = (rs < rt) ? 1 : 0` |
| **`sltu`** | `101011` | `43` | `sltu rd, rs, rt` | Unsigned Compare: `rd = (rs < rt) ? 1 : 0` |
| **`xor`** | `100110` | `38` | `xor rd, rs, rt` | Bitwise XOR: `rd = rs ^ rt` |
| **`nor`** | `100111` | `39` | `nor rd, rs, rt` | Bitwise NOR: `rd = ~(rs \| rt)` |
| **`mul`** | `011100` | `28` | `mul rd, rs, rt` | Multiplication: `rd = rs * rt` (lower 32-bits) |
| **`sll`** | `000000` | `0` | `sll rd, rt, shamt` | Constant Shift Left: `rd = rt << shamt` |
| **`srl`** | `000010` | `2` | `srl rd, rt, shamt` | Constant Shift Right Logical: `rd = rt >> shamt` |
| **`sra`** | `000011` | `3` | `sra rd, rt, shamt` | Constant Shift Right Arithmetic: `rd = rt >>> shamt` |
| **`sllv`** | `000100` | `4` | `sllv rd, rt, rs` | Variable Shift Left: `rd = rt << rs` (uses entire `rs` register value) |
| **`srlv`** | `000110` | `6` | `srlv rd, rt, rs` | Variable Shift Right Logical: `rd = rt >> rs` |
| **`srav`** | `000111` | `7` | `srav rd, rt, rs` | Variable Shift Right Arithmetic: `rd = rt >>> rs` |
| **`jr`** | `001000` | `8` | `jr rs` | Jump Register: `PC = rs` |
| **`jalr`** | `001001` | `9` | `jalr rs` | Jump and Link Register: `$ra = PC + 4; PC = rs` |
| **`mfhi`** | `010000` | `16` | `mfhi rd` | Move From HI: `rd = HI` |
| **`mthi`** | `010001` | `17` | `mthi rs` | Move To HI: `HI = rs` |
| **`mflo`** | `010010` | `18` | `mflo rd` | Move From LO: `rd = LO` |
| **`mtlo`** | `010011` | `19` | `mtlo rs` | Move To LO: `LO = rs` |
| **`mult`** | `011000` | `24` | `mult rs, rt` | Signed Multiply: `{HI, LO} = rs * rt` |
| **`multu`** | `011001` | `25` | `multu rs, rt` | Unsigned Multiply: `{HI, LO} = rs * rt` |
| **`div`** | `011010` | `26` | `div rs, rt` | Signed Divide: `LO = rs / rt; HI = rs % rt` |
| **`divu`** | `011011` | `27` | `divu rs, rt` | Unsigned Divide: `LO = rs / rt; HI = rs % rt` |

---

## 2. I-Type Instructions

I-type instructions have unique opcodes. Arithmetic/comparison immediates are sign-extended, whereas logical immediates are zero-extended.

| Instruction | Opcode (Bin) | Opcode (Dec) | Format | Immediate Extension | Operation / Behavior |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`lw`** | `100011` | `35` | `lw rt, offset(rs)` | Sign-extended | Load Word: `rt = RAM[rs + offset]` |
| **`sw`** | `101011` | `43` | `sw rt, offset(rs)` | Sign-extended | Store Word: `RAM[rs + offset] = rt` |
| **`lb`** | `100000` | `32` | `lb rt, offset(rs)` | Sign-extended | Load Byte: `rt = SignExtend(RAM[rs + offset][7:0])` |
| **`lbu`** | `100100` | `36` | `lbu rt, offset(rs)` | Sign-extended | Load Byte Unsigned: `rt = {24'b0, RAM[rs + offset][7:0]}` |
| **`lh`** | `100001` | `33` | `lh rt, offset(rs)` | Sign-extended | Load Halfword: `rt = SignExtend(RAM[rs + offset][15:0])` |
| **`lhu`** | `100101` | `37` | `lhu rt, offset(rs)` | Sign-extended | Load Halfword Unsigned: `rt = {16'b0, RAM[rs + offset][15:0]}` |
| **`sb`** | `101000` | `40` | `sb rt, offset(rs)` | Sign-extended | Store Byte: `RAM[rs + offset][7:0] = rt[7:0]` |
| **`sh`** | `101001` | `41` | `sh rt, offset(rs)` | Sign-extended | Store Halfword: `RAM[rs + offset][15:0] = rt[15:0]` |
| **`beq`** | `000100` | `4` | `beq rs, rt, offset` | Sign-extended | Branch Equal: `if (rs == rt) PC = PC + 4 + (offset << 2)` |
| **`bne`** | `000101` | `5` | `bne rs, rt, offset` | Sign-extended | Branch Not Equal: `if (rs != rt) PC = PC + 4 + (offset << 2)` |
| **`blez`** | `000110` | `6` | `blez rs, offset` | Sign-extended | Branch Less Than or Equal to Zero: `if (rs <= 0) PC = PC + 4 + (offset << 2)` |
| **`bgtz`** | `000111` | `7` | `bgtz rs, offset` | Sign-extended | Branch Greater Than Zero: `if (rs > 0) PC = PC + 4 + (offset << 2)` |
| **`bltz`** | `000001` | `1` | `bltz rs, offset` | Sign-extended | Branch Less Than Zero: `if (rs < 0) PC = PC + 4 + (offset << 2)` (rt = `00000`) |
| **`bgez`** | `000001` | `1` | `bgez rs, offset` | Sign-extended | Branch Greater Than or Equal to Zero: `if (rs >= 0) PC = PC + 4 + (offset << 2)` (rt = `00001`) |
| **`addi`** | `001000` | `8` | `addi rt, rs, imm` | Sign-extended | Add Immediate: `rt = rs + SignExtend(imm)` |
| **`addiu`** | `001001` | `9` | `addiu rt, rs, imm` | Sign-extended | Add Immediate Unsigned: `rt = rs + SignExtend(imm)` |
| **`slti`** | `001010` | `10` | `slti rt, rs, imm` | Sign-extended | Set Less Than Immediate: `rt = (rs < SignExtend(imm)) ? 1 : 0` |
| **`sltiu`** | `001011` | `11` | `sltiu rt, rs, imm` | Sign-extended | Set Less Than Immediate Unsigned: `rt = (rs < SignExtend(imm)) ? 1 : 0` |
| **`andi`** | `001100` | `12` | `andi rt, rs, imm` | Zero-extended | AND Immediate: `rt = rs & {16'b0, imm}` |
| **`ori`** | `001101` | `13` | `ori rt, rs, imm` | Zero-extended | OR Immediate: `rt = rs \| {16'b0, imm}` |
| **`xori`** | `001110` | `14` | `xori rt, rs, imm` | Zero-extended | XOR Immediate: `rt = rs ^ {16'b0, imm}` |
| **`lui`** | `001111` | `15` | `lui rt, imm` | Upper 16-bits | Load Upper Immediate: `rt = {imm, 16'b0}` |

---

## 3. J-Type Instructions

J-type instructions use target offsets shift-lefted by 2 to jump to a large range.

| Instruction | Opcode (Bin) | Opcode (Dec) | Format | Operation / Behavior |
| :--- | :--- | :--- | :--- | :--- |
| **`j`** | `000010` | `2` | `j target` | Jump: `PC = {PCPlus4[31:28], target << 2}` |
| **`jal`** | `000011` | `3` | `jal target` | Jump and Link: `$ra = PC + 4; PC = {PCPlus4[31:28], target << 2}` |

---

## 4. Hardware Protections & Special Registers

- **Register `$0` (`$zero`)**: Hardwired directly to `32'b0`. All reads return `0`, and all write requests to `$0` are safely ignored by the hardware inside the Register File.
- **Register `$31` (`$ra`)**: Return address register. Written to automatically by `jal` and `jalr` instructions, but can also be read/written by general-purpose software (e.g. for context saving/restoring).
- **Registers `HI` and `LO`**: 32-bit special-purpose registers holding results of multiplication and division. Updated automatically by `mult`, `multu`, `div`, and `divu`, or explicitly using `mthi` and `mtlo` instructions. Can be read using `mfhi` and `mflo` instructions.

---

## 5. Architectural Design Notes

### Centralized ALU Integration for Multiplier & Divider
In our implementation, the physical `multiplier` and `divider` hardware blocks are instantiated directly inside the **ALU** (`ALU_32_bits`) instead of being separate top-level processor components. This architecture has several key advantages:
1. **Resource Reuse**: The shared 32-bit standard `mul` instruction (which writes its lower 32-bit result to the general register file) and the 64-bit R-type multiplication instructions (`mult`/`multu`) both share the exact same internal hardware multiplier resources, reducing redundant silicon area.
2. **Simplified Control**: Centralizing all mathematical execution units within the ALU simplifies the instruction decoding, as the Main Decoder and ALU Decoder handle execution unit selection in a single execution stage.


