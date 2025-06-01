`timescale 1ns/1ps

module axi_slave (
    // Clock and Reset
    input wire clk,
    input wire reset,

    // Write Address Channel
    input wire [31:0] AWADDR,
    input wire [7:0]  AWLEN,
    input wire [2:0]  AWSIZE,
    input wire [1:0]  AWBURST,
    input wire        AWVALID,
    output reg        AWREADY,

    // Write Data Channel
    input wire [31:0] WDATA,
    input wire        WVALID,
    input wire        WLAST,
    output reg        WREADY,

    // Write Response Channel
    output reg        BRESP,
    output reg        BVALID,
    input wire        BREADY,

    // Read Address Channel
    input wire [31:0] ARADDR,
    input wire [7:0]  ARLEN,
    input wire [2:0]  ARSIZE,
    input wire [1:0]  ARBURST,
    input wire        ARVALID,
    output reg        ARREADY,

    // Read Data Channel
    output reg [31:0] RDATA,
    output reg        RRESP,
    output reg        RLAST,
    output reg        RVALID,
    input wire        RREADY
);

    // Memory and parameter declarations
    reg [31:0] memory [0:99];  // 100 words of memory
    
    // State parameters
    parameter [1:0] IDLE = 2'b00,
                    ACTIVE = 2'b01,
                    END = 2'b10;

    // State registers
    reg [1:0] aw_state, w_state, b_state, ar_state, r_state;
    
    // Address and control registers
    reg [31:0] wr_addr_reg;
    reg [31:0] rd_addr_reg;
    reg [7:0]  write_burst_counter;
    reg [7:0]  read_burst_counter;
    reg [2:0]  wr_size_reg;
    reg [2:0]  rd_size_reg;
    reg [1:0]  wr_burst_reg;
    reg [1:0]  rd_burst_reg;
    reg [7:0]  wr_len_reg;
    reg [7:0]  rd_len_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Write Address Channel Reset
            aw_state <= IDLE;
            AWREADY <= 0;
            wr_addr_reg <= 0;
            wr_size_reg <= 0;
            wr_burst_reg <= 0;
            wr_len_reg <= 0;
            write_burst_counter <= 0;

            // Write Data Channel Reset
            w_state <= IDLE;
            WREADY <= 0;

            // Write Response Channel Reset
            b_state <= IDLE;
            BVALID <= 0;
            BRESP <= 1'b0;
        end 
        else begin
            // Write Address Channel Logic
            case (aw_state)
                IDLE: begin
                    if (AWVALID) begin
                        aw_state <= ACTIVE;
                        AWREADY <= 1;
                        wr_addr_reg <= AWADDR;
                        wr_size_reg <= AWSIZE;
                        wr_burst_reg <= AWBURST;
                        wr_len_reg <= AWLEN;
                        write_burst_counter <= AWLEN + 1;
                    end else begin
                        AWREADY <= 0;
                    end
                end

                ACTIVE: begin
                    AWREADY <= 0;
                    aw_state <= IDLE;
                end

                default: aw_state <= IDLE;
            endcase

            // Write Data Channel Logic
            case (w_state)
                IDLE: begin
                    if (aw_state == ACTIVE) begin
                        w_state <= ACTIVE;
                        WREADY <= 1;
                    end else begin
                        WREADY <= 0;
                    end
                end

                ACTIVE: begin
                    if (WVALID && WREADY) begin
                        memory[wr_addr_reg] <= WDATA;
                        
                        if (write_burst_counter > 0) begin
                            write_burst_counter <= write_burst_counter - 1;
                            
                            case (wr_burst_reg)
                                2'b00: ; // FIXED - no address update
                                2'b01: wr_addr_reg <= Incr(wr_addr_reg, wr_size_reg);
                                2'b10: wr_addr_reg <= Wrap(wr_addr_reg, wr_size_reg, wr_len_reg);
                                default: ;
                            endcase
                        end

                        if (WLAST) begin
                            w_state <= END;
                            WREADY <= 0;
                        end
                    end
                end

                END: begin
                    w_state <= IDLE;
                end

                default: w_state <= IDLE;
            endcase

            // Write Response Channel Logic
            case (b_state)
                IDLE: begin
                    if (w_state == END) begin
                        b_state <= ACTIVE;
                        BVALID <= 1;
                        BRESP <= 1'b0;
                    end else begin
                        BVALID <= 0;
                        BRESP <= 1'b0;
                    end
                end

                ACTIVE: begin
                    if (BREADY) begin
                        b_state <= END;
                        BVALID <= 1;
                        BRESP <= 1'b1;
                    end
                end

                END: begin
                    b_state <= IDLE;
                    BVALID <= 0;
                    BRESP <= 1'b0;
                end

                default: begin
                    b_state <= IDLE;
                    BVALID <= 0;
                    BRESP <= 1'b0;
                end
            endcase
        end
    end

    // Combined Read Channel Operations (AR, R channels)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Read Address Channel Reset
            ar_state <= IDLE;
            ARREADY <= 0;
            rd_addr_reg <= 0;
            rd_size_reg <= 0;
            rd_burst_reg <= 0;
            rd_len_reg <= 0;
            read_burst_counter <= 0;

            // Read Data Channel Reset
            r_state <= IDLE;
            RVALID <= 0;
            RLAST <= 0;
            RRESP <= 1'b0;
            RDATA <= 0;
        end 
        else begin
            // Read Address Channel Logic
            case (ar_state)
                IDLE: begin
                    if (ARVALID) begin
                        ar_state <= ACTIVE;
                        ARREADY <= 1;
                        rd_addr_reg <= ARADDR;
                        rd_size_reg <= ARSIZE;
                        rd_burst_reg <= ARBURST;
                        rd_len_reg <= ARLEN;
                        read_burst_counter <= ARLEN + 1;
                    end else begin
                        ARREADY <= 0;
                    end
                end

                ACTIVE: begin
                    ARREADY <= 0;
                    ar_state <= IDLE;
                end

                default: ar_state <= IDLE;
            endcase

            // Read Data Channel Logic
            case (r_state)
                IDLE: begin
                    if (ar_state == ACTIVE) begin
                        r_state <= ACTIVE;
                        RVALID <= 1;
                        RDATA <= memory[rd_addr_reg];
                        RRESP <= 1'b0;
                        RLAST <= (read_burst_counter == 1);
                    end else begin
                        RVALID <= 0;
                        RLAST <= 0;
                        RRESP <= 1'b0;
                        RDATA <= RDATA;  // Hold value
                    end
                end

                ACTIVE: begin
                    if (RVALID && RREADY) begin
                        if (read_burst_counter <= 0) begin
                            r_state <= END;
                            RLAST <= 1;
                            RVALID <= 1;
                            RRESP <= 1'b1;
                        end else begin
                            read_burst_counter <= read_burst_counter - 1; 
                            
                            case (rd_burst_reg)
                                2'b00: ; // FIXED
                                2'b01: rd_addr_reg <= Incr(rd_addr_reg, rd_size_reg);
                                2'b10: rd_addr_reg <= Wrap(rd_addr_reg, rd_size_reg, rd_len_reg);
                                default: ;
                            endcase
                            
                            RDATA <= memory[rd_addr_reg];
                            RLAST <= (read_burst_counter == 1);
                            RRESP <= (read_burst_counter == 1) ? 1'b1 : 1'b0;
                            RVALID <= 1;
                        end
                    end
                end

                END: begin
                    RVALID <= 0;
                    RLAST <= 0;
                    RRESP <= 1'b0;
                    r_state <= IDLE;
                end

                default: begin
                    r_state <= IDLE;
                    RVALID <= 0;
                    RLAST <= 0;
                    RRESP <= 2'b00;
                end
            endcase
        end
    end


    // Function for WRAP address calculation
    function [31:0] Wrap;
        input [31:0] curr_addr;
        input [2:0]  size;
        input [7:0]  len;
        reg   [31:0] num_bytes;
        reg   [31:0] burst_len;
        reg   [31:0] boundary;
        reg   [31:0] offset_mask;
        reg   [31:0] next_addr;
    begin
        num_bytes = (1 << size);
        burst_len = len + 1;
        boundary = (curr_addr / (num_bytes * burst_len)) * (num_bytes * burst_len);
        offset_mask = (num_bytes * burst_len) - 1;
        next_addr = curr_addr + num_bytes;
        if ((next_addr & offset_mask) == 0)
            Wrap = boundary;
        else
            Wrap = next_addr;
    end
    endfunction

    // Function for INCR address calculation
    function [31:0] Incr;
        input [31:0] curr_addr;
        input [2:0]  size;
        reg   [31:0] num_bytes;
    begin
        case(size)
            3'b000: num_bytes = 1;    // 8-bit
            3'b001: num_bytes = 2;    // 16-bit
            3'b010: num_bytes = 4;    // 32-bit
            3'b011: num_bytes = 8;    // 64-bit
            3'b100: num_bytes = 16;   // 128-bit
            default: num_bytes = 4;   // Default to 32-bit
        endcase
        Incr = curr_addr + num_bytes;
    end
    endfunction

endmodule