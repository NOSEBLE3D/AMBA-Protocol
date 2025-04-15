`timescale 1ns/1ps

module APB (PCLK,PRESET,WRITE,PTX,ADDR,WDATA,PRDATA);

input PCLK,PRESET,WRITE,PTX;
input [7:0] ADDR;
input [31:0] WDATA;

//output reg PREADY;
output wire [31:0]PRDATA;

wire PSEL,PENABLE,PWRITE,PREADY;
wire [7:0] PADDR;
wire [31:0] PWDATA;

Master m(
    .PCLK(PCLK),
    .PRESET(PRESET),
    .WRITE(WRITE),
    .ADDR(ADDR),
    .WDATA(WDATA),
    .PTX(PTX),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PREADY(PREADY)
);

Slave s(
    .PCLK(PCLK),
    .PRESET(PRESET),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PREADY(PREADY),
    .PRDATA(PRDATA)
);

endmodule