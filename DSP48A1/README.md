# DSP48A1 FPGA Slice — RTL Design & Verification

A complete Verilog RTL implementation and verification of the **DSP48A1 slice**, a dedicated DSP arithmetic block used in Xilinx Spartan-6 FPGAs.

The project focuses on implementing the DSP datapath, configurable pipeline stages, arithmetic operations, cascade paths, synchronous/asynchronous reset behavior, and comprehensive directed/self-checking verification.

## Key Features

* Full RTL implementation of the DSP48A1 architecture
* Configurable pipeline registers:

  * A0REG / A1REG
  * B0REG / B1REG
  * CREG
  * DREG
  * MREG
  * PREG
  * CARRYINREG / CARRYOUTREG
  * OPMODEREG
* Configurable `CARRYINSEL` and `B_INPUT` paths
* Support for synchronous/asynchronous reset through `RSTTYPE`
* Pre-adder/subtractor datapath
* 18 × 18-bit multiplication
* 48-bit post-adder/subtractor
* P and M registered/direct output paths
* BCIN/BCOUT cascade path
* PCIN/PCOUT cascade path
* Carry cascade and FPGA carry outputs
* Configurable OPMODE-controlled datapath
* Clock-enable support for individual pipeline stages

## Verification

The testbench uses **directed self-checking test patterns** to verify the major DSP datapaths.

The following paths are verified:

1. **DSP Path 1**

   * Pre-subtraction
   * Multiplication
   * Post-subtraction
   * Expected outputs are automatically checked

2. **DSP Path 2**

   * Pre-addition
   * Multiplication
   * Post-addition path

3. **DSP Path 3**

   * P feedback
   * Multiplication
   * Post-addition/accumulation path

4. **DSP Path 4**

   * D:A:B concatenated datapath
   * PCIN cascade
   * Post-subtraction
   * Carry propagation

The testbench also verifies reset behavior and checks that the outputs reach their expected values after the appropriate pipeline latency.

## Simulation

The project includes a **QuestaSim DO file** for automated compilation and simulation.

Simulation verification includes:

* Reset verification
* Directed stimulus
* Pipeline latency verification
* Expected-value comparisons
* Carry verification
* Cascade-path verification
* Waveform inspection

## FPGA Design Flow

The design was taken through the Vivado FPGA flow:

* Elaboration
* RTL/design checks
* Synthesis
* Implementation
* Timing analysis
* Utilization analysis
* Synthesized schematic inspection
* Device view inspection
* Message/error verification

A timing constraint is included for a **100 MHz clock**.

## Linting

The RTL was also analyzed using the Vivado linting flow with the default methodology and goals.

The final design was verified to have **no reported lint errors**.

## Project Structure

```text
DSP48A1/
├── RTL/
│   └── DSP48A1.v
├── Testbench/
│   └── DSP48A1_tb.v
├── Sim/
│   └── run.do
├── Constraints/
│   └── DSP48A1.xdc
├── Vivado/
│   └── ...
├── Lint
|
├── Pdfs
|
└── README.md
```

## Tools

* Verilog HDL
* QuestaSim
* Vivado
* Xilinx FPGA Design Flow
* RTL Simulation
* RTL Linting
* Synthesis
* Implementation
* Static Timing Analysis

## Verification Strategy

The verification environment combines **directed stimulus and self-checking assertions/comparisons**. Each major DSP datapath is exercised using carefully selected input values and OPMODE configurations, with expected outputs compared against the DUT.

This approach verifies both the arithmetic functionality and the effect of the configurable pipeline stages on output latency.
