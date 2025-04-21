# AHB Protocol Documentation

---

## Table of Contents
1. Introduction to AHB Protocol
2. Differences Between APB, AHB, and AXI
3. Overview of the AHB Implementation
4. Two-Phase Pipelining in AHB
5. Incremental Bursts (INCR)
6. Wrapping Bursts (WRAP)
7. Handling Wait States
8. Testbench Overview

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
   - Generates addresses, control signals (`HTRANS`, `HWRITE`, etc.), and data (`HWDATA`).
   - Implements **two-phase pipelining** for efficient data transfers.

2. **AHB Slave**:
   - Receives and processes transactions from the master.
   - Simulates **wait states** using the `HREADY` signal.

3. **AHB Top Module**:
   - Integrates the master and slave components.
   - Facilitates communication between them.

4. **Testbench**:
   - Verifies the functionality of the design.
   - Tests burst transfers (increment and wrap) and single transfers.

---

## 4. Two-Phase Pipelining in AHB

### What is Two-Phase Pipelining?
AHB uses a **two-phase pipelining mechanism** to overlap the address and data phases of a transfer. This increases throughput by utilizing the bus more efficiently.

### How It Works in Your Code:
- **Master Module**:
  - `HADDR` (address) and `HWDATA` (write data) are handled separately.
  - A **data latch (`data_latch`)** delays the data until the next cycle to align with the address phase.
  - Example:
    ```verilog
    HWDATA <= data_latch; // Delayed data for pipelining
    data_latch <= WDATA;  // Store new data for the next cycle
    ```

- **Slave Module**:
  - The `HREADY` signal ensures the master waits until the slave is ready for the next transfer.

---

## 5. Incremental Bursts (INCR)

### What are Incremental Bursts?
Incremental bursts transfer a sequence of data words to/from sequential addresses. The address increments after each data transfer.

### Implementation in Your Code:
- **Master Module**:
  - The `increment_address_generator` function calculates the next address:
    ```verilog
    increment_address_generator = current_addr + num_bytes;
    ```
  - Used during the `SEQ` state to update `HADDR`.

- **Testbench**:
  - Example INCR4 burst:
    ```verilog
    burst_data[1] = 32'h1111_0001;
    burst_data[2] = 32'h2222_0002;
    burst_data[3] = 32'h3333_0003;
    burst_data[4] = 32'h4444_0004;
    ahb_write(32'h0000_0020, 1, 4, 3'b011, 3'b010);
    ```

---

## 6. Wrapping Bursts (WRAP)

### What are Wrapping Bursts?
Wrapping bursts are similar to incremental bursts but with an additional feature: the address wraps around to the start of a predefined boundary when it exceeds this boundary.

### Implementation in Your Code:
- **Master Module**:
  - The `wrap_address_generator` function calculates the wrapped address:
    ```verilog
    boundary = (curr_addr / (num_bytes * burst_len)) * (num_bytes * burst_len);
    next_addr = curr_addr + burst_len;
    if ((next_addr & offset_mask) == 0)
      wrap_address_generator = boundary;
    else
      wrap_address_generator = next_addr;
    ```

- **Testbench**:
  - Example WRAP4 burst:
    ```verilog
    burst_data[5] = 32'hAAAA_0001;
    burst_data[6] = 32'hBBBB_0002;
    burst_data[7] = 32'hCCCC_0003;
    burst_data[8] = 32'hDDDD_0004;
    ahb_write(32'h0000_0030, 5, 4, 3'b010, 3'b010);
    ```

---

## 7. Handling Wait States

### What are Wait States?
Wait states introduce delays in the slave's response, signaling that it is not ready to complete a transfer.

### Implementation in Your Code:
- **Slave Module**:
  - The `wait_state_counter` simulates wait states:
    ```verilog
    if (wait_state_counter > 0) begin
      HREADY <= 1'b0;
      wait_state_counter <= wait_state_counter - 1;
    end else begin
      HREADY <= 1'b1;
    end
    ```

- **Testbench**:
  - The master waits for `HREADY` before proceeding:
    ```verilog
    while (!DUT.master.HREADY) @(posedge HCLK);
    ```

---

## 8. Testbench Overview

### Key Features of Testbench:
1. **Write Task (`ahb_write`)**:
   - Executes single or burst writes.
   - Example:
     ```verilog
     ahb_write(32'h0000_0010, 0, 1, 3'b000, 3'b010);
     ```

2. **Read Task (`ahb_read`)**:
   - Executes single or burst reads.
   - Example:
     ```verilog
     ahb_read(32'h0000_0010, 3'b000, 3'b010);
     ```

3. **Burst Data Simulation**:
   - Tests both incremental and wrapping bursts.

4. **Wait State Handling**:
   - Ensures the master waits for `HREADY` before proceeding.

---

## Summary

### Key Takeaways:
1. **AHB Protocol**:
   - High-performance, pipelined, burst-based design.

2. **Features Implemented**:
   - Two-phase pipelining.
   - Incremental and wrapping bursts.
   - Wait state simulation.

3. **Comparison with APB and AXI**:
   - AHB balances simplicity and performance, making it ideal for on-chip memory and peripherals.

4. **Testbench Validation**:
   - Comprehensive testing ensures functionality and protocol compliance.
