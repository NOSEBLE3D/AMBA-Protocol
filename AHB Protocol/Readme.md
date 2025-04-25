# AHB Protocol Documentation
Last Updated: 2025-04-25
Author: NOSEBLE3D

---

## Table of Contents
1. Introduction to AHB Protocol
2. Differences Between APB, AHB, and AXI
3. Overview of the AHB Implementation
4. Two-Phase Pipelining in AHB
5. Incremental Bursts (INCR)
6. Wrapping Bursts (WRAP)
7. System Operation

---

## 1. Introduction to AHB Protocol

### What is AHB Protocol?
The **AHB (Advanced High-performance Bus)** is part of the **AMBA (Advanced Microcontroller Bus Architecture)** specification by ARM. It is designed to enable high-performance and high-clock-frequency communication between system modules.

### Key Features of AHB:
- **Single Clock Edge Operation**: Synchronizes all transfers to a single clock edge.
- **Pipelined Operation**: Enables two-phase pipelined data transfers for efficiency.
- **Burst Transfers**: Supports incremental and wrapping bursts for sequential data access.
- **Multiple Masters and Slaves**: Allows a system to handle multiple bus masters and slaves.

---

## 2. Differences Between APB, AHB, and AXI

| Feature            | APB (Advanced Peripheral Bus) | AHB (Advanced High-performance Bus) | AXI (Advanced eXtensible Interface) |
|--------------------|--------------------------------|-------------------------------------|-------------------------------------|
| **Purpose**        | Low-power peripherals         | High-performance on-chip memory     | Scalability and high-performance    |
| **Pipelining**     | None                          | Two-phase pipelining                | Fully pipelined                     |
| **Burst Transfers**| None                          | Supported                           | Advanced burst control              |
| **Data Width**     | Fixed (32-bit)                | Flexible (8, 16, 32, etc.)          | Flexible (32, 64, 128, etc.)        |
| **Latency**        | High                          | Medium                              | Low                                 |
| **Address Phase**  | Single-phase                  | Separate address and data phases    | Separate address and data phases    |

---

## 3. Overview of the AHB Implementation

### Key Components:
1. **AHB Master**:
   - Generates addresses and control signals (`HTRANS`, `HWRITE`, etc.)
   - Implements **two-phase pipelining** for efficient data transfers
   - Manages burst transfers and address generation

2. **AHB Slave**:
   - Receives and processes transactions from the master
   - Implements memory operations
   - Manages data phase timing

3. **AHB Top Module**:
   - Integrates the master and slave components
   - Handles signal routing and interconnection

---

## 4. Two-Phase Pipelining in AHB

### What is Two-Phase Pipelining?
AHB uses a **two-phase pipelining mechanism** where the address and data phases of consecutive transfers overlap, improving bus utilization and throughput.

### Implementation Details:
- **Address Phase**:
  - Master presents address and control signals
  - These signals are registered by the slave

- **Data Phase**:
  - Occurs one cycle after the address phase
  - Write data is presented by the master
  - Read data is returned by the slave

---

## 5. Incremental Bursts (INCR)

### Implementation:
- Supports INCR4 bursts (4-beat transfers)
- Address increments based on transfer size
- Sequential data transfers

### Address Generation:
```verilog
case (burst)
  3'b011: // INCR4
    next_addr = current_addr + (1 << SIZE);
endcase
```

---

## 6. Wrapping Bursts (WRAP)

### Implementation:
- Supports WRAP4 and WRAP8 bursts
- Address wraps at boundaries based on burst size
- Maintains fixed-size address windows

### Address Calculation:
```verilog
boundary = (curr_addr / (num_bytes * burst_len)) * (num_bytes * burst_len);
next_addr = curr_addr + burst_len;
wrap_addr = (next_addr > boundary_end) ? boundary : next_addr;
```

---

## 7. System Operation

### Transfer Types:
1. **Single Transfer**:
   - One address phase followed by one data phase
   - No burst operation

2. **Burst Transfer**:
   - One address phase followed by multiple data phases
   - Supports both INCR and WRAP types

### Control Signals:
- **HTRANS[1:0]**:
  - IDLE   (2'b00)
  - BUSY   (2'b01)
  - NONSEQ (2'b10)
  - SEQ    (2'b11)

- **HREADY**:
  - Indicates slave readiness
  - Controls transfer progression

### Memory Operations:
- **Write Operation**:
  ```verilog
  if (valid_transfer && addr_phase_write)
    mem[addr_phase_addr] <= HWDATA;
  ```

- **Read Operation**:
  ```verilog
  if (valid_transfer && !addr_phase_write)
    HRDATA <= mem[addr_phase_addr];
  ```
