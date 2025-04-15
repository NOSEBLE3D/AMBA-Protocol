`timescale 1ns/1ps

module Slave(PCLK,PRESET,PSEL,PENABLE,PADDR,PWDATA,PWRITE,PREADY,PRDATA);

input PCLK,PRESET,PSEL,PENABLE,PWRITE;
input [7:0] PADDR;
input [31:0] PWDATA;

output reg PREADY;
output reg [31:0] PRDATA;

reg [31:0] mem [0:255];

always@(posedge PCLK or negedge PRESET)begin
    if(!PRESET)begin
        PREADY <= 0;
        PRDATA <=0;
    end
    else begin
        if(PSEL && PENABLE)begin
            PREADY <= 1;
                if(PWRITE)begin
                    mem[PADDR] <= PWDATA;
                end
                else begin
                    PRDATA <= mem[PADDR];
                end   
        end
        else begin
            PREADY <= 0;
        end 
    end
end

endmodule