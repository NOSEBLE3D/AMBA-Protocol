`timescale 1ns/1ps

module Master (PCLK,PRESET,PTX,STRB,WRITE,ADDR,WDATA,PSTRB,PREADY,PSEL,PENABLE,PADDR,PWDATA,PWRITE);

input PCLK,PRESET,PTX,WRITE,PREADY;
input [7:0] ADDR;
input [31:0] WDATA;
input [3:0] STRB;

output reg [3:0] PSTRB;
output reg PSEL,PENABLE,PWRITE;
output reg [31:0] PWDATA;
output reg [7:0] PADDR;

parameter IDEAL = 2'b00, SETUP = 2'b01, ACCESS = 2'b10;

reg [1:0] pr_state, nxt_state;

always@(posedge PCLK or negedge PRESET)begin
    if(!PRESET) begin
        pr_state <= IDEAL;
	PSTRB = 4'h0;
    end
    else
        pr_state <= nxt_state;
end

always@(pr_state,PREADY,PTX)begin
    case(pr_state)
        IDEAL:begin
            PSEL = 0;
            PENABLE = 0;
            PADDR = 0;
            PWDATA = 0;
            PWRITE = 0;
                if(PTX)
                    nxt_state = SETUP;
                else
                    nxt_state = IDEAL;
        end
        
        SETUP:begin
            PSEL = 1;
            PENABLE = 0;
            PADDR = ADDR;
            PWDATA = WDATA;
            PWRITE = WRITE;
	    PSTRB = STRB;
            nxt_state = ACCESS;
        end
        
        ACCESS:begin
            PSEL = 1;
            PENABLE = 1;
                if(PTX) begin
                    if(PREADY)
                        nxt_state = SETUP;
                    else
                        nxt_state = IDEAL;

                end
                else if(!PTX)
                    nxt_state = ACCESS;
                else
                    nxt_state = IDEAL;
        end
        default: nxt_state = IDEAL; // access
    endcase  
end
endmodule

/*`timescale 1ns/1ps

module Master (PCLK,PRESET,PTX,WRITE,ADDR,WDATA,PREADY,PSEL,PENABLE,PADDR,PWDATA,PWRITE);

input PCLK,PRESET,PTX,WRITE,PREADY;
input [7:0] ADDR;
input [31:0] WDATA;

output reg PSEL,PENABLE,PWRITE;
output reg [31:0] PWDATA;
output reg [7:0] PADDR;

parameter IDEAL = 2'b00, SETUP = 2'b01, ACCESS = 2'b10;

reg [1:0] pr_state, nxt_state;

always@(posedge PCLK or negedge PRESET)begin
    if(!PRESET)
        pr_state <= IDEAL;
    else
        pr_state <= nxt_state;
end

always@(pr_state,PREADY,PTX)begin
    case(pr_state)
        IDEAL:begin
            PSEL = 0;
            PENABLE = 0;
            PADDR = 0;
            PWDATA = 0;
            PWRITE = 0;
                if(PTX)
                    nxt_state = SETUP;
                else
                    nxt_state = IDEAL;
        end
        
        SETUP:begin
            PSEL = 1;
            PENABLE = 0;
            PADDR = ADDR;
            PWDATA = WDATA;
            PWRITE = WRITE;
            nxt_state = ACCESS;
        end
        
        ACCESS:begin
            PSEL = 1;
            PENABLE = 1;
                if(PTX) begin
                    if(PREADY)
                        nxt_state = SETUP;
                    else
                        nxt_state = IDEAL;
                end
                else if(!PTX)
                    nxt_state = ACCESS;
                else
                    nxt_state = IDEAL;
        end
        default: nxt_state = IDEAL;
    endcase  
end
endmodule
