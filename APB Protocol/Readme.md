This Verilog module provides a basic and minimalistic implementation of the APB (Advanced Peripheral Bus) protocol, strictly following the guidelines outlined in the official ARM AMBA APB specification. The design aims to reflect fundamental protocol understanding rather than full-scale feature coverage.

**Key Highlights**
Single Clock and Simple Control: As per APB protocol rules, the design operates with a single clock (PCLK) and a reset (PRESETn), managing all state transitions in a synchronous manner.

**FSM Structure:**

The module uses a clearly defined Finite State Machine (IDLE, SETUP, ACCESS) to control the APB transfer sequence.

Transitions are triggered based on PSEL, PWRITE, and PENABLE signals.

**Transfer Types Supported:**

Both read and write operations are supported through state-based control.

Write happens when PWRITE is high and PENABLE is asserted in the ACCESS state.

Read data is returned in a single cycle during ACCESS with PWRITE = 0.

**Signal Management:**

PSEL, PENABLE, PWRITE, PADDR, PWDATA, and PRDATA are actively used in the design.

The protocol maintains basic timing behavior—SETUP followed by ACCESS—as per standard APB flow.

**Features Not Implemented**
No support for PREADY or PSLVERR: These optional signals were omitted to keep the design simple and focused on core functionality.

No support for multiple peripherals or decoded PSELx: A single-slave model is used; thus, no decoding or address mapping is involved.

No low-power or extended wait handling: The module assumes zero wait states and always completes the transfer in ACCESS state.

No support for byte strobes or sideband signaling.
