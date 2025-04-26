`timescale 1ns/1ps

module ahb_top (
    input         HCLK,
    input         HRESETn,
    input         transfer_start,
    input  [31:0] ADDR,
    input  [31:0] WDATA,
    input         WRITE,
    input  [2:0]  BURST,
    input  [2:0]  SIZE,
    output [31:0] HRDATA    // Changed from reg to wire
);

    // Internal signals
    wire [31:0] HADDR, HWDATA;
    wire        HWRITE, HREADY, HSEL;
    wire [2:0]  HBURST, HSIZE;
    wire [1:0]  HTRANS;

    // Master Instance
    ahb_master master (
        .HCLK           (HCLK),
        .HRESETn        (HRESETn),
        .HREADY         (HREADY),
        .ADDR           (ADDR),
        .WDATA          (WDATA),
        .WRITE          (WRITE),
        .BURST          (BURST),
        .SIZE           (SIZE),
        .transfer_start (transfer_start),
        .HADDR          (HADDR),
        .HWDATA         (HWDATA),
        .HWRITE         (HWRITE),
        .HBURST         (HBURST),
        .HSIZE          (HSIZE),
        .HTRANS         (HTRANS),
        .HSEL           (HSEL)
    );

    // Slave Instance
    ahb_slave slave (
        .HCLK           (HCLK),
        .HRESETn        (HRESETn),
        .HSEL           (HSEL),
        .HWRITE         (HWRITE),
        .HTRANS         (HTRANS),
        .HBURST         (HBURST),
        .HSIZE          (HSIZE),
        .HADDR          (HADDR),
        .HWDATA         (HWDATA),
        .HRDATA         (HRDATA),
        .HREADY         (HREADY)
    );

endmodule