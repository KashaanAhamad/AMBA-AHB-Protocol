# AMBA AHB (Advanced High-performance Bus) Protocol Implementation

This repository contains a SystemVerilog implementation of the AMBA AHB protocol, a widely used bus architecture for high-performance system-on-chip (SoC) designs. The implementation includes a master, a slave, and an arbiter module, demonstrating the core functionality of the AHB protocol.

## 📁 Directory Structure

```
amba-ahb/
├── address_loader_s1.sv        # AHB Interface Signals & Assignments (180nm)
├── address_loader_s3.sv        # AHB Interface Signals & Assignments (250nm)
├── ahb_interface.sv           # AHB Interface Signals Definition
├── ahb_arbiter.sv             # AHB Arbiter Module (Priority Based)
├── ahb_master.sv              # AHB Master Module (Monolithic)
├── ahb_slave.sv               # AHB Slave Module (Dual Port)
├── ahb_testbench.sv           # AHB Testbench
└── README.md                  # Project Overview
```

## 🚀 Modules

### 1. `ahb_interface.sv`
Defines the comprehensive set of signals required for the AMBA AHB interface, including address/data buses, control signals, and transfer status signals.

### 2. `ahb_arbiter.sv`
**Arbiter Type:** Priority-Based

Manages access to the shared bus for multiple masters. It prioritizes masters based on a fixed priority scheme. When a master requests the bus, the arbiter grants it if the bus is idle. If multiple masters request simultaneously, the highest priority master wins.

### 3. `ahb_master.sv`
**Architecture:** Monolithic (Single-Port)

Implements a bus master that can perform both write and read operations. The master generates address, control, and write data, and receives read data from the slave. This version uses a single port for both operations.

### 4. `ahb_slave.sv`
**Architecture:** Dual-Port (2-Word Buffered)

A sophisticated slave interface with two internal ports, allowing it to handle two words per transfer cycle. It supports multiple address ranges with different access permissions (Read-Only, Write-Only, Read/Write).

#### Supported Address Ranges:
| Start Address | End Address | Size   | Access | Description          |
|---------------|-------------|--------|--------|----------------------|
| `32'h00000000` | `32'h000001FF` | 512B   | R/W    | General Purpose Memory |
| `32'h80000000` | `32'h8000007F` | 128B   | R      | Read-Only Status     |
| `32'hFFFF0000` | `32'hFFFFFFFF` | 64KB   | W      | Write-Only Control   |

#### Key Features:
- **Dual Port:** Can receive read data for the previous cycle while the current cycle is in progress.
- **Buffering:** Internal FIFOs/buffers to handle the 2-word transfer capability.

## 🧪 Testbench (`ahb_testbench.sv`)

The testbench verifies the AHB protocol by instantiating the arbiter, master, and slave components. It orchestrates bus operations to ensure proper functionality.

## 🛠️ Usage

To simulate this design, you can use any SystemVerilog-compatible simulator such as Cadence Xcelium, Synopsys VCS, or Mentor QuestaSim.

**Basic Simulation Command (Conceptual):**
```bash
# Compile the Verilog files
xrun -sv *.sv

# Run the simulation
xrun ahb_testbench
```

## 📐 Technology Nodes

The repository includes two versions of the address loader, likely corresponding to different process nodes:
- `address_loader_s1.sv`: 180nm Technology
- `address_loader_s3.sv`: 250nm Technology

These modules handle the mapping of AHB addresses to specific internal logic based on technology node requirements.
