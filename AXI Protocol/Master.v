`timescale 1ns/1ps

module axi_master (
    input wire clk,
    input wire reset,

    // Control Signals
    input wire        wr_tx,
    input wire        rd_tx,
    output reg        wr_done,
    output reg        rd_done,
    output reg        rd_data_valid,

    // Write Request Interface
    input wire [31:0] wr_addr,
    input wire [7:0]  wr_len,
    input wire [2:0]  wr_size,
    input wire [1:0]  wr_burst,
    input wire [31:0] wr_data,

    // Read Request Interface
    input wire [31:0] rd_addr,
    input wire [7:0]  rd_len,
    input wire [2:0]  rd_size,
    input wire [1:0]  rd_burst,
    output reg [31:0] rd_data,

    // Write Address Channel
    output reg [31:0] AWADDR,
    output reg [7:0]  AWLEN,
    output reg [2:0]  AWSIZE,
    output reg [1:0]  AWBURST,
    output reg        AWVALID,
    input wire        AWREADY,

    // Write Data Channel
    output reg [31:0] WDATA,
    output reg        WVALID,
    output reg        WLAST,
    input wire        WREADY,

    // Write Response Channel
    input wire        BRESP,
    input wire        BVALID,
    output reg        BREADY,

    // Read Address Channel
    output reg [31:0] ARADDR,
    output reg [7:0]  ARLEN,
    output reg [2:0]  ARSIZE,
    output reg [1:0]  ARBURST,
    output reg        ARVALID,
    input wire        ARREADY,

    // Read Data Channel
    input wire [31:0] RDATA,
    input wire        RRESP,
    input wire        RLAST,
    input wire        RVALID,
    output reg        RREADY
);

    // State parameters
    parameter [1:0] IDLE = 2'b00, ACTIVE = 2'b01, END = 2'b10;

    reg [1:0] aw_state, w_state, b_state;
    reg [1:0] ar_state, r_state;
    reg [7:0] write_burst_counter;
    reg [7:0] read_burst_counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Write Address Channel Reset
            aw_state <= IDLE;
            AWVALID <= 0;
            AWADDR <= 0;
            AWLEN <= 0;
            AWSIZE <= 0;
            AWBURST <= 0;
            write_burst_counter <= 0;

            // Write Data Channel Reset
            w_state <= IDLE;
            WVALID <= 0;
            //WLAST <= 0;
            WDATA <= 0;

            // Write Response Channel Reset
            b_state <= IDLE;
            BREADY <= 0;
            wr_done <= 0;
        end else begin
            // Write Address Channel Logic
            case (aw_state)
                IDLE: if (wr_tx) begin
                    aw_state <= ACTIVE;
                    AWVALID <= 1;
                    AWADDR <= wr_addr;
                    AWLEN <= wr_len;
                    AWSIZE <= wr_size;
                    AWBURST <= wr_burst;
                    write_burst_counter <= wr_len + 1;
                end
                ACTIVE: if (AWREADY && AWVALID) begin
                    AWVALID <= 0;
                    aw_state <= END;
                end
                END: aw_state <= IDLE;
                default: aw_state <= IDLE;
            endcase

            // Write Data Channel Logic
            case (w_state)
                IDLE: if (aw_state == ACTIVE) begin
                    w_state <= ACTIVE;
		    WDATA <= 32'b0;
                    WVALID <= 1;
                    write_burst_counter <= AWLEN + 1;
                end
                ACTIVE: if (WVALID && WREADY) begin
                    if (write_burst_counter == 1) begin
                        //WLAST <= 1;
                        w_state <= END;
                    end else begin
                        write_burst_counter <= write_burst_counter - 1;
                       // WLAST <= 0;
                    end
                end
                END: begin
                    WVALID <= 0;
		    WDATA <= 32'b0;
                    //WLAST <= 0;
		    //wr_data <= 0;
                    w_state <= IDLE;
                end
                default: w_state <= IDLE;
            endcase
            // Assign wr_data directly
            WDATA <= wr_data;

            // Write Response Channel Logic
            case (b_state)
                IDLE: if (w_state == END) begin
                    b_state <= ACTIVE;
                    BREADY <= 1;
                end
                ACTIVE: if (BVALID && BREADY) begin
                    BREADY <= 0;
                    wr_done <= 1;
                    b_state <= END;
                end
                END: begin
                    wr_done <= 0;
                    b_state <= IDLE;
                end
                default: b_state <= IDLE;
            endcase
        end
    end

    // Combined Read Channel Operations
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ar_state <= IDLE;
            ARVALID <= 0;
            ARADDR <= 0;
            ARLEN <= 0;
            ARSIZE <= 0;
            ARBURST <= 0;
	    rd_data <= 0;
            read_burst_counter <= 0;

            r_state <= IDLE;
            RREADY <= 0;
            rd_data <= 0;
            rd_data_valid <= 0;
            rd_done <= 0;
        end else begin
            case (ar_state)
                IDLE: if (rd_tx) begin
                    ar_state <= ACTIVE;
                    ARVALID <= 1;
                    ARADDR <= rd_addr;
                    ARLEN <= rd_len;
                    ARSIZE <= rd_size;
                    ARBURST <= rd_burst;
                    read_burst_counter <= rd_len + 1;
                end
                ACTIVE: if (ARREADY && ARVALID) begin
                    ARVALID <= 0;
                    ar_state <= END;
                end
                END: ar_state <= IDLE;
                default: ar_state <= IDLE;
            endcase

            case (r_state)
                IDLE: if (ar_state == ACTIVE) begin
                    r_state <= ACTIVE;
                    RREADY <= 1;
                    rd_data_valid <= 0;
                end
                ACTIVE: if (RVALID && RREADY) begin
                    rd_data <= RDATA;
                    rd_data_valid <= 1;
                    if (RLAST) begin
                        RREADY <= 0;
                        rd_done <= 1;
                        r_state <= END;
                    end else begin
                        read_burst_counter <= read_burst_counter - 1;
                    end
                end else begin
                    rd_data_valid <= 0;
                end
                END: begin
                    rd_data_valid <= 0;
                    rd_done <= 0;
                    r_state <= IDLE;
                end
                default: r_state <= IDLE;
            endcase
        end
    end
always@(*)begin
	if (WVALID && WREADY)
		assign WLAST = (write_burst_counter == 1);
	else
		assign WLAST = 0;
end

endmodule

/*`timescale 1ns/1ps

module axi_master (
    // Global Signals
    input wire clk,
    input wire reset,
    
    // Control Signals from User Interface
    input wire        wr_tx,           // Write transaction start
    input wire        rd_tx,           // Read transaction start
    output reg        wr_done,         // Write transaction complete
    output reg        rd_done,         // Read transaction complete
    output reg        rd_data_valid,   // Read data valid
    
    // Write Request Interface
    input wire [31:0] wr_addr,         // Write address
    input wire [7:0]  wr_len,          // Burst length
    input wire [2:0]  wr_size,         // Size (bytes per transfer)
    input wire [1:0]  wr_burst,        // Burst type
    input wire [31:0] wr_data,         // Write data
    
    // Read Request Interface
    input wire [31:0] rd_addr,         // Read address
    input wire [7:0]  rd_len,          // Burst length
    input wire [2:0]  rd_size,         // Size (bytes per transfer)
    input wire [1:0]  rd_burst,        // Burst type
    output reg [31:0] rd_data,         // Read data output

    // Write Address Channel
    output reg [31:0] AWADDR,
    output reg [7:0]  AWLEN,
    output reg [2:0]  AWSIZE,
    output reg [1:0]  AWBURST,
    output reg        AWVALID,
    input wire        AWREADY,

    // Write Data Channel
    output reg [31:0] WDATA,
    output reg        WVALID,
    output reg        WLAST,
    input wire        WREADY,

    // Write Response Channel
    input wire        BRESP,
    input wire        BVALID,
    output reg        BREADY,

    // Read Address Channel
    output reg [31:0] ARADDR,
    output reg [7:0]  ARLEN,
    output reg [2:0]  ARSIZE,
    output reg [1:0]  ARBURST,
    output reg        ARVALID,
    input wire        ARREADY,

    // Read Data Channel
    input wire [31:0] RDATA,
    input wire        RRESP,
    input wire        RLAST,
    input wire        RVALID,
    output reg        RREADY
);

    // State parameters
    parameter [1:0] IDLE = 2'b00,
                    ACTIVE = 2'b01,
                    END = 2'b10;

    // State registers
    reg [1:0] aw_state, w_state, b_state;  // Write channel states
    reg [1:0] ar_state, r_state;           // Read channel states
    
    // Burst counters and control registers
    reg [7:0]  write_burst_counter;
    reg [7:0]  read_burst_counter;
    reg [31:0] write_data_buffer;
    reg [31:0] current_write_addr;
    reg [31:0] current_read_addr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Write Address Channel Reset
            aw_state <= IDLE;
            AWVALID <= 0;
            AWADDR <= 0;
            AWLEN <= 0;
            AWSIZE <= 0;
            AWBURST <= 0;
            current_write_addr <= 0;
            write_burst_counter <= 0;

            // Write Data Channel Reset
            w_state <= IDLE;
            WVALID <= 0;
            WLAST <= 0;
            WDATA <= 0;
            write_data_buffer <= 0;

            // Write Response Channel Reset
            b_state <= IDLE;
            BREADY <= 0;
            wr_done <= 0;
        end 
        else begin
            // Write Address Channel Logic
            case (aw_state)
                IDLE: begin
                    if (wr_tx) begin
                        aw_state <= ACTIVE;
                        AWVALID <= 1;
                        AWADDR <= wr_addr;
                        AWLEN <= wr_len;
                        AWSIZE <= wr_size;
                        AWBURST <= wr_burst;
                        current_write_addr <= wr_addr;
                        write_burst_counter <= wr_len + 1;
                    end
                end

                ACTIVE: begin
                    if (AWREADY && AWVALID) begin
                        AWVALID <= 0;
                        aw_state <= END;
                    end
                end

                END: begin
                    aw_state <= IDLE;
                end

                default: aw_state <= IDLE;
            endcase

            // Write Data Channel Logic
            case (w_state)
                IDLE: begin
                    if (aw_state == ACTIVE) begin
                        w_state <= ACTIVE;
                        WVALID <= 1;
                        WDATA <= wr_data;
                        write_data_buffer <= wr_data;
                    end
                end

                ACTIVE: begin
                    if (WVALID && WREADY) begin
                        if (write_burst_counter <= 1) begin
                            WLAST <= 1;
                            w_state <= END;
                        end else begin
                            write_burst_counter <= write_burst_counter - 1;
                            case (AWBURST)
                                2'b00: WDATA <= write_data_buffer;  // FIXED
                                2'b01: WDATA <= write_data_buffer + write_burst_counter;  // INCR
                                2'b10: begin  // WRAP
                                    WDATA <= write_data_buffer + 
                                            ((write_burst_counter - 1) % (AWLEN + 1));
                                end
                                default: WDATA <= write_data_buffer;
                            endcase
                        end
                    end
                end

                END: begin
                    WVALID <= 0;
                    WLAST <= 0;
                    w_state <= IDLE;
                end

                default: w_state <= IDLE;
            endcase

            // Write Response Channel Logic
            case (b_state)
                IDLE: begin
                    if (w_state == END) begin
                        b_state <= ACTIVE;
                        BREADY <= 1;
                    end
                end

                ACTIVE: begin
                    if (BVALID && BREADY) begin
                        BREADY <= 0;
                        wr_done <= 1;
                        b_state <= END;
                    end
                end

                END: begin
                    wr_done <= 0;
                    b_state <= IDLE;
                end

                default: b_state <= IDLE;
            endcase
        end
    end

    // Combined Read Channel Operations (AR, R channels)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Read Address Channel Reset
            ar_state <= IDLE;
            ARVALID <= 0;
            ARADDR <= 0;
            ARLEN <= 0;
            ARSIZE <= 0;
            ARBURST <= 0;
            current_read_addr <= 0;
            read_burst_counter <= 0;

            // Read Data Channel Reset
            r_state <= IDLE;
            RREADY <= 0;
            rd_data <= 0;
            rd_data_valid <= 0;
            rd_done <= 0;
        end 
        else begin
            // Read Address Channel Logic
            case (ar_state)
                IDLE: begin
                    if (rd_tx) begin
                        ar_state <= ACTIVE;
                        ARVALID <= 1;
                        ARADDR <= rd_addr;
                        ARLEN <= rd_len;
                        ARSIZE <= rd_size;
                        ARBURST <= rd_burst;
                        current_read_addr <= rd_addr;
                        read_burst_counter <= rd_len + 1;
                    end
                end

                ACTIVE: begin
                    if (ARREADY && ARVALID) begin
                        ARVALID <= 0;
                        ar_state <= END;
                    end
                end

                END: begin
                    ar_state <= IDLE;
                end

                default: ar_state <= IDLE;
            endcase

            // Read Data Channel Logic
            case (r_state)
                IDLE: begin
                    if (ar_state == ACTIVE) begin
                        r_state <= ACTIVE;
                        RREADY <= 1;
                        rd_data_valid <= 0;
                    end
                end

                ACTIVE: begin
                    if (RVALID && RREADY) begin
                        rd_data <= RDATA;
                        rd_data_valid <= 1;
                        
                        if (RLAST) begin
                            RREADY <= 0;
                            rd_done <= 1;
                            r_state <= END;
                        end else begin
                            read_burst_counter <= read_burst_counter - 1;
                        end
                    end else begin
                        rd_data_valid <= 0;
                    end
                end

                END: begin
                    rd_data_valid <= 0;
                    rd_done <= 0;
                    r_state <= IDLE;
                end

                default: r_state <= IDLE;
            endcase
        end
    end


endmodule
