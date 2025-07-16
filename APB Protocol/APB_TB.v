`timescale 1ns/1ps

module APB_TB();

reg PCLK,PRESET,WRITE,PTX;
reg [7:0] ADDR;
reg [31:0] WDATA;
reg[3:0] STRB;

wire [31:0] PRDATA;

APB uut(
    .PCLK(PCLK),
    .PRESET(PRESET),
    .STRB(STRB),
    .WRITE(WRITE),
    .PTX(PTX),
    .ADDR(ADDR),
    .WDATA(WDATA),
    .PRDATA(PRDATA)
);

always #5 PCLK = ~PCLK;

initial begin

PCLK = 0;
STRB = 0;
PRESET = 0;
WRITE = 0;
PTX = 0;
ADDR = 8'h00;
WDATA = 32'h00000000;

#10 PRESET = 1;

// Original test case 1: Write to 05
#10 PTX = 1;
WRITE = 1;
ADDR = 8'h05;
WDATA = 32'h0000ABCD;
STRB = 4'b111;

#20 PTX = 0;
ADDR = 8'h00;
WDATA = 32'h00000000;
WRITE = 0;
STRB = 4'b000;

// Original test case 2: Read from 05
#10 PTX = 1;
WRITE = 0;
ADDR = 8'h05;
STRB = 4'b00;

#20 PTX = 0;
ADDR = 8'h00;

// Additional test case 3: Modify Address 05
#10 PTX = 1;
WRITE = 1;
ADDR = 8'h05;
WDATA = 32'h55050055;
STRB = 4'b0011;
#20 PTX = 0;

// Additional test case 4: Read from 55
#10 PTX = 1;
WRITE = 0;
ADDR = 8'h05;
STRB = 4'b00;

#20 PTX = 0;

// Additional test case 5: Write to address 0A
#10 PTX = 1;
WRITE = 1;
ADDR = 8'h0A;
WDATA = 32'h000AAAAA;
STRB = 4'b1111;

#20 PTX = 0;

// Additional test case 6: Read from 0A
#10 PTX = 1;
WRITE = 0;
ADDR = 8'h0A;
//STRB = 3'b1111;

#20 PTX = 0;

// Additional test case 7: Modify Address 0A
#10 PTX = 1;
WRITE = 1;
ADDR = 8'h0A;
WDATA = 32'h33003300;
STRB = 4'b1010;

#20 PTX = 0;

// Additional test case 8: Read from 0A
#10 PTX = 1;
WRITE = 0;
ADDR = 8'h0A;
STRB = 4'b00;

#20 PTX = 0;

// Additional test case 9: Write to address 0F
#10 PTX = 1;
WRITE = 1;
ADDR = 8'h0F;
WDATA = 32'h00FF00FF;
STRB = 4'b1111;

#20 PTX = 0;

// Additional test case 10: Read from 0F
#10 PTX = 1;
WRITE = 0;
ADDR = 8'h0F;
STRB = 4'b00;

#20 PTX = 0;

// Additional test case 11: Modify Address 0F
#10 PTX = 1;
WRITE = 1;
ADDR = 8'h0F;
WDATA = 32'h7B7B7B7B;
STRB = 4'b1100;
#20 PTX = 0;

// Additional test case 12: Read from 7B
#10 PTX = 1;
WRITE = 0;
ADDR = 8'h0F;
STRB = 4'b00;

#10;
WRITE = 1;
ADDR = 9'h1ff;
WDATA = 32'h00FF00FF;
STRB = 4'b1111;

#10;
WRITE = 1;
ADDR = 8'hXX;
WDATA = 32'hFF00FF00;
STRB = 4'b1111;

#20 PTX = 0;

#50;
$finish;

end
endmodule

/*`timescale 1ns/1ps

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
