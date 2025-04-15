`timescale 1ns/1ps

module APB_TB();

reg PCLK,PRESET,WRITE,PTX;
reg [7:0] ADDR;
reg [31:0] WDATA;

wire [31:0] PRDATA;

APB uut(
    .PCLK(PCLK),
    .PRESET(PRESET),
    .WRITE(WRITE),
    .PTX(PTX),
    .ADDR(ADDR),
    .WDATA(WDATA),
    .PRDATA(PRDATA)
);

always #5 PCLK = ~PCLK;

initial begin

PCLK = 0;
PRESET = 0;
WRITE = 0;
PTX = 0;
ADDR = 8'h00;
WDATA = 31'h00000000;

#10 PRESET = 1;

#10 PTX = 1;
WRITE = 1;
ADDR = 8'hA5;
WDATA = 32'hABCDABCD;

#20 PTX = 0;
//WRITE = 0;

ADDR = 8'h00;
WDATA = 32'h00000000;
WRITE = 0;
#10 PTX = 1;
WRITE = 0;
ADDR = 8'hA5;

#20 PTX = 0;
ADDR = 8'h00;

#50;
$finish;

end
endmodule