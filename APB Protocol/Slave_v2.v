`timescale 1ns/1ps

module Slave(
    input PCLK,
    input PRESET,
    input [3:0] PSTRB,
    input PSEL,
    input PENABLE,
    input [7:0] PADDR,
    input [31:0] PWDATA,
    input PWRITE,
    output reg PSLVERR,
    output reg PREADY,
    output reg [31:0] PRDATA
);

reg [31:0] mem [0:255];
integer i;

always@(posedge PCLK or negedge PRESET)begin
    if(!PRESET)begin
        PREADY <= 0;
        PRDATA <= 0;
	    for(i=0; i<256; i=i+1)
		mem[i] <= 0;
    end
    else begin
        if(PSEL && PENABLE)begin
            PREADY <= 1;
            if(PWRITE)begin
                // Byte-wise update using PSTRB
                if (PSTRB[0]) mem[PADDR][7:0]   <= PWDATA[7:0];
                if (PSTRB[1]) mem[PADDR][15:8]  <= PWDATA[15:8];
                if (PSTRB[2]) mem[PADDR][23:16] <= PWDATA[23:16];
                if (PSTRB[3]) mem[PADDR][31:24] <= PWDATA[31:24];
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

always@(*)begin
	if((PADDR > 8'hFF) || (PADDR === 8'bXX))
		PSLVERR = 1'b1;
	else
		PSLVERR = 1'b0;
end

endmodule

/*`timescale 1ns/1ps

module Slave(
    input PCLK,
    input PRESET,
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [7:0] PADDR,
    input [31:0] PWDATA,
    output reg PREADY,
    output reg [31:0] PRDATA
);

    // localparam for state encoding
    localparam IDLE  = 2'b00,
               SETUP = 2'b01,
               ACCESS = 2'b10;

    reg [1:0] pr_state, nxt_state;
    reg [31:0] mem [0:255];

    // State register
    always @(posedge PCLK or negedge PRESET) begin
        if (!PRESET)
            pr_state <= IDLE;
        else
            pr_state <= nxt_state;
    end

    // Next state logic
    always @(*) begin
        case (pr_state)
            IDLE: begin
                if (PSEL && !PENABLE)
                    nxt_state = SETUP;
                else
                    nxt_state = IDLE;
            end
            SETUP: begin
                if (PSEL && PENABLE)
                    nxt_state = ACCESS;
                else
                    nxt_state = SETUP;
            end
            ACCESS: begin
                if (!PSEL)
                    nxt_state = IDLE;
                else
                    nxt_state = ACCESS;
            end
            default: nxt_state = IDLE;
        endcase
    end

    // Output and memory operation logic
    always @(posedge PCLK or negedge PRESET) begin
        if (!PRESET) begin
            PREADY <= 0;
            PRDATA <= 0;
        end else begin
            case (pr_state)
                IDLE: begin
                    PREADY <= 0;
                    PRDATA <= 0;
                end
                SETUP: begin
                    PREADY <= 0;
                    // No data transfer yet
                end
                ACCESS: begin
                    PREADY <= 1;
                    if (PWRITE)
                        mem[PADDR] <= PWDATA;
                    else
                        PRDATA <= mem[PADDR];
                end
                default: begin
                    PREADY <= 0;
                    PRDATA <= 0;
                end
            endcase
        end
    end

endmodule
