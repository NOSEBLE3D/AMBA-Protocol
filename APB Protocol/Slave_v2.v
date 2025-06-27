`timescale 1ns/1ps

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
