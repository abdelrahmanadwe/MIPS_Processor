# MIPS Processor with Parameterized Memory Map & MMIO Preparation

A synthesizable, 32-bit MIPS Processor implemented in Verilog. This CPU features an optimized, parameterized memory architecture designed to support dynamic test loading and prepare the design for Memory-Mapped I/O (MMIO). Currently, it features a single-cycle implementation, with plans to expand to a pipelined architecture.

---

## 1. Architecture Overview
The initial stage of this processor is designed as a single-cycle architecture (executing one instruction per clock cycle) and contains the following core hardware blocks:
- **Program Counter (PC)**: Holds the current instruction address, initialized to `32'h0` upon reset.
- **Instruction Memory (ROM)**: A synthesizable byte-addressable ROM containing the instruction program.
- **Register File**: Contains 32 general-purpose 32-bit registers (register `$0` is hardwired to `0`). Also contains special-purpose `HI` and `LO` registers for multiply/divide operations.
- **Arithmetic Logic Unit (ALU)**: Performs 32-bit operations (arithmetic, logic, shifts, and comparisons).
- **Data Memory (RAM)**: A byte-addressable RAM holding global and dynamic program data.

---

## 2. Memory Organization & Mapping
The microprocessor implements a custom, parameterized memory mapping to enforce software limits and prepare for MMIO device integration:

- **Instruction Memory (ROM)**:
  - **Size**: 4KB (1024 words).
  - **Address Range**: `32'h0000_0000` to `32'h0000_0FFF` (valid PC up to `32'h0000_0FFC`).
- **Data Memory (RAM)**:
  - **Size**: 28KB (28,672 bytes).
  - **Address Range**: `32'h0000_1000` to `32'h0000_7FFF`.
  - **Address Translation**: Data accesses are validated to verify they are within `[0x1000, 0x7FFF]`. If valid, the hardware subtracts `0x1000` (`Address - 32'h1000`) to access the underlying memory array starting at physical index `0`. Invalid accesses are ignored.
- **Reserved / MMIO Space**:
  - Addresses `< 0x1000` and `>= 0x8000` are reserved for MMIO peripherals and exception handling.

---

## 3. Directory Layout
All source code and tests are organized systematically:
```
├── README.md               # Main project documentation
├── supported_isa.md        # Reference manual of supported MIPS instructions
├── run.do                  # ModelSim macro automation simulation script
├── run_test.sh             # Linux shell wrapper script to run tests
├── rtl/                    # Hardware RTL Source Code (Verilog & SystemVerilog)
│   ├── ALU_32.v            # 32-bit Arithmetic Logic Unit
│   ├── ALU_Decoder.v       # ALU function code decoder
│   ├── Adder_32.v          # 32-bit binary adder
│   ├── Control_Unit.v      # CPU control unit (Main + ALU decoders)
│   ├── Data_Memory.v       # Parameterized Data Memory (RAM)
│   ├── Instruction_Memory.v# Synthesizable byte-addressable ROM
│   ├── Main_Decoder.v      # Control signal decoder
│   ├── ProgramCounter.v    # 32-bit PC register
│   ├── Register_File.v     # 32x32 Register File + HI/LO registers
│   ├── multiplier.v        # Modular multiplication unit
│   ├── divider.v           # Modular division unit
│   └── Single_Cycle_MIPS_Microprocessor.v # Top-level CPU wrapper
├── tb/                     # Verification testbenches
│   └── Single_Cycle_MIPS_Microprocessor_tb.v # Dynamic loading testbench
└── Tests/                  # Organized MIPS Test Suite
    ├── test1/              # Basic ALU operations test
    ├── test2/              # Subroutine calling & stack pointer test
    ├── test3/              # Branch (blez, bgtz, bltz, bgez) & Logic (xor, nor) test
    ├── test4/              # Control flow and logical test
    ├── test5/              # Shift operations (sll, srl, sra, sllv, srlv, srav) test
    ├── ...
    └── instructions1/      # Basic loop & factorial test
```

---

## 4. Verification & Testing

The testbench dynamically loads byte-by-byte memory files (`.mem`) using simulation plusargs (`+MEM_FILE`), avoiding the need to modify Verilog files or recompile between tests. 

### How to Run Tests (ModelSim / Questasim)
You can run any test directly from your terminal using the `./run_test.sh` script by providing the test name in lowercase:

```bash
# Run Test 1 (ALU operations)
./run_test.sh test1

# Run Test 2 (Subroutine stack test)
./run_test.sh test2

# Run Test 3 (Branches & Logic test)
./run_test.sh test3

# Run Test 4 (Logical test)
./run_test.sh test4

# Run Test 5 (Shift operations test)
./run_test.sh test5

# Run the instructions1 loop test
./run_test.sh instructions1
```

### Simulation Results Check
Each test automatically runs for `30,000ns` and displays its results based on the return state of register `$s0` (`register[16]`):
- **TEST PASSED**: Register `$s0` lower 16 bits contain `16'hD08E`.
- **TEST FAILED**: Register `$s0` lower 16 bits contain `16'hDEAD`.
