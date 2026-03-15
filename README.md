# MIPS CPU Datapath in Verilog

A hardware implementation of a **MIPS-style CPU datapath written in Verilog**, developed as part of a computer architecture course project. The design models the core datapath components of a processor and demonstrates how instructions move through hardware modules such as the **register file, ALU, memory interfaces, and control logic**.

The project was developed and synthesized using **Xilinx Vivado**, with the goal of understanding how modern processors are implemented at the **register-transfer level (RTL)**.

---

## Project Overview

This project implements a simplified **MIPS processor datapath** in Verilog. The design focuses on the hardware components responsible for executing instructions, including arithmetic operations, memory access, and register manipulation.

In a processor, the **datapath** is the part of the CPU that performs arithmetic and logical operations and moves data between registers, memory, and functional units. This implementation models those components in a modular hardware design.

---

## Features

- Written entirely in **Verilog HDL**
- Modular hardware architecture
- Implements a pipelined **MIPS datapath**
- Handles basic mips instructions along with Jumps and Hazard detection
- Designed and synthesized using **Vivado**
- Demonstrates key processor components including:
  - Program Counter (PC)
  - Register File
  - Arithmetic Logic Unit (ALU)
  - Instruction Memory
  - Data Memory
  - Multiplexers and control signals
- Structured so individual modules can be tested independently

---

## Architecture

The CPU datapath is composed of multiple hardware modules that together execute instructions.

Typical datapath flow:

1. **Instruction Fetch**
   - Program Counter (PC) selects the next instruction address.
   - Instruction memory returns the instruction.

2. **Instruction Decode**
   - The instruction fields are decoded.
   - Register operands are read from the register file.

3. **Execute**
   - The ALU performs arithmetic or logical operations.

4. **Memory Access**
   - Data memory is accessed for load/store instructions.

5. **Write Back**
   - Results are written back into the register file.

These components mirror the structure of many educational implementations of the **MIPS architecture**, which is commonly used in computer architecture courses to teach CPU design concepts.

---

## Repository Structure

Example structure (may vary depending on modules implemented):

```
MIPS-CPU-Verilog-Datapath/
│
├── ALU.v                # Arithmetic Logic Unit
├── register_file.v     # CPU register bank
├── program_counter.v   # Program counter logic
├── instruction_mem.v   # Instruction memory
├── data_mem.v          # Data memory
├── control_unit.v      # Control signal generation
├── mux.v               # Multiplexer modules
├── datapath.v          # Top-level datapath integration
└── testbench.v         # Simulation testbench
```

Each module represents a specific hardware block within the processor datapath.

---

## Tools Used

- **Language:** Verilog HDL  
- **Design Tool:** Xilinx Vivado  
- **Hardware Target:** FPGA-based simulation/synthesis environment  
- **Verification:** Simulation using testbenches in Vivado

---

## Learning Objectives

This project was developed to gain hands-on experience with:

- CPU architecture and instruction execution
- Hardware description languages (Verilog)
- Register-transfer level (RTL) design
- FPGA development workflows
- Simulation and debugging of digital hardware

---

## How to Run / Simulate

1. Clone the repository

```bash
git clone https://github.com/mfrayne/MIPS-CPU-Verilog-Datapath.git
```
3. Unzip the **Final_Project_EXTRA_CREDIT (3).zip** file
   
2. Ensure **Vivado** in installed (Installation Guide can be found here: [https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html](url))

3. Run the **.xpr** file

5. Run:
   - **Behavioral Simulation** to test functionality
   - **Synthesis** to verify hardware implementation

---

## Example Instruction Flow

A typical instruction executes through the datapath as follows:

```
Instruction → Decode → Register Read → ALU Operation → Memory Access → Register Writeback
```

This flow demonstrates how instructions are translated into hardware control signals and data movement within the processor.

---

## Skills Demonstrated

This project demonstrates experience with:

- FPGA development
- Verilog RTL design
- Computer architecture
- Hardware modular design
- Debugging and simulation in Vivado
- Processor datapath implementation

