# ECE564-QuantumComputingEmulator

This repository contains the implementation and documentation of a Quantum Computing Emulator designed as part of the ECE 564 course at North Carolina State University.

## Project Overview

This project emulates a quantum computer capable of simulating quantum matrix operations using hardware design principles. It supports real and complex double-precision floating point computations, storing intermediate and final results in SRAM. The main computation involves repeated matrix multiplications of quantum gates and state vectors, modeling how quantum circuits evolve.

- **Course**: ECE 564: ASIC & FPGA Design
- **Student**: Padmanabha Nikhil Bhimavarapu
- **Project Type**: Individual
- **Technology**: Verilog, DesignWare FPUs, FSM, MAC units, SRAM
- **Target**: Emulation of quantum behavior on ASIC (1–4 Qubits)

## Concept

Quantum systems can be represented as state vectors modified by operator matrices. Each operator (or "gate") modifies the state of the system, and a sequence of such gates simulates quantum computation. This design focuses on implementing this sequence as a matrix multiplication engine in hardware.

- Supports **1 to 4 qubits**
- Handles **complex double-precision floating-point** values (IEEE754)
- Uses 4 SRAMs:
  - `q_state_input_sram`: Initial state vectors
  - `q_gates_sram`: Operator matrices
  - `scratchpad_sram`: Intermediate results
  - `q_state_output_sram`: Final state vector

## Architecture & Implementation

- **Data Flow**: Comprises 12 multiplexers and 8 DesignWare Multiply-Accumulate (MAC) blocks.
- **Control FSM**: Controls all stages from reading/writing SRAMs to sequencing MAC operations.
- **Floating Point Units**: Custom integration of DW FP MAC units for precision.
- **Clock Period**: 100 ns
- **Area**: 143,940.58 µm²
- **Performance Metric (1 / delay·area)**: `4.84 × 10⁻¹⁰ ns⁻¹·µm⁻²`

## Verification

- 6 test cases with varying `q` (qubit count) and `m` (number of gates)
- Outputs matched golden reference values
- Synthesis ensured timing slack was met

## Notes

- This project uses Synopsys DesignWare IPs for FPUs.
- `scratchpad_sram` use is encouraged for area optimization.

## References

- [Quantum Computing for Computer Scientists – Yanofsky & Mannucci](https://catalog.lib.ncsu.edu/catalog/NCSU5575047)
- [Qiskit Tutorials](https://qiskit.org/learn)

## Author

**Padmanabha Nikhil Bhimavarapu**  
ECE Graduate Student, North Carolina State University  
Unity ID: `pbhimav`

---



