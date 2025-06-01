`timescale 1ns/1ps

module axi_master_tb();
    // Clock and Reset
    reg clk;
    reg reset;
    
    // User Interface Control Signals
    reg         wr_tx;
    reg         rd_tx;
    wire        wr_done;
    wire        rd_done;
    wire        rd_data_valid;
    
    // Write Request Interface
    reg [31:0]  wr_addr;
    reg [7:0]   wr_len;
    reg [2:0]   wr_size;
    reg [1:0]   wr_burst;
    reg [31:0]  wr_data;
    
    // Read Request Interface
    reg [31:0]  rd_addr;
    reg [7:0]   rd_len;
    reg [2:0]   rd_size;
    reg [1:0]   rd_burst;
    wire [31:0] rd_data;
    
    // Write Address Channel
    wire [31:0] AWADDR;
    wire [7:0]  AWLEN;
    wire [2:0]  AWSIZE;
    wire [1:0]  AWBURST;
    wire        AWVALID;
    reg         AWREADY;
    
    // Write Data Channel
    wire [31:0] WDATA;
    wire        WVALID;
    wire        WLAST;
    reg         WREADY;
    
    // Write Response Channel
    reg [1:0]   BRESP;
    reg         BVALID;
    wire        BREADY;
    
    // Read Address Channel
    wire [31:0] ARADDR;
    wire [7:0]  ARLEN;
    wire [2:0]  ARSIZE;
    wire [1:0]  ARBURST;
    wire        ARVALID;
    reg         ARREADY;
    
    // Read Data Channel
    reg [31:0]  RDATA;
    reg [1:0]   RRESP;
    reg         RLAST;
    reg         RVALID;
    wire        RREADY;

    // Test bench signals
    reg [31:0] test_data [0:15];
    integer burst_count;
    integer data_count;
    integer error_count;
    integer i;
    reg [7:0] current_burst_len;

    // DUT Instance
    axi_master dut (
        .clk(clk),
        .reset(reset),
        
        // Control Interface
        .wr_tx(wr_tx),
        .rd_tx(rd_tx),
        .wr_done(wr_done),
        .rd_done(rd_done),
        .rd_data_valid(rd_data_valid),
        
        // Write Request Interface
        .wr_addr(wr_addr),
        .wr_len(wr_len),
        .wr_size(wr_size),
        .wr_burst(wr_burst),
        .wr_data(wr_data),
        
        // Read Request Interface
        .rd_addr(rd_addr),
        .rd_len(rd_len),
        .rd_size(rd_size),
        .rd_burst(rd_burst),
        .rd_data(rd_data),
        
        // AXI Write Address Channel
        .AWADDR(AWADDR),
        .AWLEN(AWLEN),
        .AWSIZE(AWSIZE),
        .AWBURST(AWBURST),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        
        // AXI Write Data Channel
        .WDATA(WDATA),
        .WVALID(WVALID),
        .WLAST(WLAST),
        .WREADY(WREADY),
        
        // AXI Write Response Channel
        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),
        
        // AXI Read Address Channel
        .ARADDR(ARADDR),
        .ARLEN(ARLEN),
        .ARSIZE(ARSIZE),
        .ARBURST(ARBURST),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
        
        // AXI Read Data Channel
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RLAST(RLAST),
        .RVALID(RVALID),
        .RREADY(RREADY)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Write transaction task
    task write_transaction;
        input [31:0] addr;
        input [7:0]  len;
        input [1:0]  burst;
        input [31:0] start_data;
        begin
            $display("\nStarting Write Transaction at time %0t:", $time);
            $display("Address: %h, Length: %d, Burst: %d", addr, len, burst);
            
            @(posedge clk);
            wr_tx = 1;
            wr_addr = addr;
            wr_len = len;
            wr_size = 3'b010;  // 4 bytes
            wr_burst = burst;
            wr_data = start_data;
            current_burst_len = len;
            
            @(posedge clk);
            wr_tx = 0;
            
            // Wait for write completion
            wait(wr_done);
            @(posedge clk);
            
            $display("Write Transaction Complete at time %0t", $time);
        end
    endtask

    // Read transaction task
    task read_transaction;
        input [31:0] addr;
        input [7:0]  len;
        input [1:0]  burst;
        input [31:0] exp_start_data;
        begin
            $display("\nStarting Read Transaction at time %0t:", $time);
            $display("Address: %h, Length: %d, Burst: %d", addr, len, burst);
            
            @(posedge clk);
            rd_tx = 1;
            rd_addr = addr;
            rd_len = len;
            rd_size = 3'b010;  // 4 bytes
            rd_burst = burst;
            current_burst_len = len;
            
            @(posedge clk);
            rd_tx = 0;
            
            // Monitor read data
            data_count = 0;
            while (data_count <= len) begin
                @(posedge clk);
                if (rd_data_valid) begin
                    case (burst)
                        2'b00: begin  // FIXED
                            if (rd_data !== exp_start_data) begin
                                $display("Error: FIXED burst data mismatch at time %0t", $time);
                                $display("Expected: %h, Got: %h", exp_start_data, rd_data);
                                error_count = error_count + 1;
                            end
                        end
                        2'b01: begin  // INCR
                            if (rd_data !== (exp_start_data + data_count)) begin
                                $display("Error: INCR burst data mismatch at time %0t", $time);
                                $display("Expected: %h, Got: %h", 
                                        exp_start_data + data_count, rd_data);
                                error_count = error_count + 1;
                            end
                        end
                        2'b10: begin  // WRAP
                            if (rd_data !== (exp_start_data + (data_count % (len + 1)))) begin
                                $display("Error: WRAP burst data mismatch at time %0t", $time);
                                $display("Expected: %h, Got: %h", 
                                        exp_start_data + (data_count % (len + 1)), rd_data);
                                error_count = error_count + 1;
                            end
                        end
                    endcase
                    $display("Read Data[%0d]: %h at time %0t", data_count, rd_data, $time);
                    data_count = data_count + 1;
                end
            end
            
            wait(rd_done);
            $display("Read Transaction Complete at time %0t", $time);
        end
    endtask

    // Slave response simulation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            AWREADY <= 0;
            WREADY <= 0;
            BVALID <= 0;
            BRESP <= 2'b00;
            ARREADY <= 0;
            RVALID <= 0;
            RDATA <= 0;
            RRESP <= 2'b00;
            RLAST <= 0;
            burst_count <= 0;
        end else begin
            // Write address channel
            if (AWVALID) begin
                AWREADY <= 1;
                burst_count <= 0;
            end else begin
                AWREADY <= 0;
            end
            
            // Write data channel
            if (WVALID) begin
                WREADY <= 1;
                if (WREADY) burst_count <= burst_count + 1;
            end else begin
                WREADY <= 0;
            end
            
            // Write response channel
            if (WLAST && WVALID && WREADY) begin
                BVALID <= 1;
                BRESP <= 2'b00;
            end else if (BVALID && BREADY) begin
                BVALID <= 0;
            end
            
            // Read address channel
            if (ARVALID) begin
                ARREADY <= 1;
                burst_count <= 0;
            end else begin
                ARREADY <= 0;
            end
            
            // Read data channel
            if (ARVALID && ARREADY) begin
                #2; // Small delay
                RVALID <= 1;
                burst_count <= 0;
                RDATA <= test_data[burst_count];
                RLAST <= 0;
            end else if (RVALID && RREADY) begin
                burst_count <= burst_count + 1;
                if (burst_count >= current_burst_len) begin
                    RVALID <= 0;
                    RLAST <= 1;
                end else begin
                    RDATA <= test_data[burst_count + 1];
                    RLAST <= (burst_count == current_burst_len - 1);
                end
            end
        end
    end

    // Main test sequence
    initial begin
        // Initialize signals
        reset = 1;
        wr_tx = 0;
        rd_tx = 0;
        error_count = 0;
        
        // Initialize test data
        for (i = 0; i < 16; i = i + 1) begin
            test_data[i] = 32'h100 + i;
        end
        
        // Start test sequence
        $display("\nStarting AXI Master Test at time %0t", $time);
        
        // Reset sequence
        #100 reset = 0;
        #100;

        // Test FIXED burst
        $display("\n=== Testing FIXED Burst ===");
        write_transaction(32'h1000, 8'h3, 2'b00, 32'h100);
        #20;
        read_transaction(32'h1000, 8'h3, 2'b00, 32'h100);
        
        #50;
        
        // Test INCR burst
        $display("\n=== Testing INCR Burst ===");
        write_transaction(32'h2000, 8'h7, 2'b01, 32'h200);
        #20;
        read_transaction(32'h2000, 8'h7, 2'b01, 32'h200);
        
        #50;
        
        // Test WRAP burst
        $display("\n=== Testing WRAP Burst ===");
        write_transaction(32'h3000, 8'h3, 2'b10, 32'h300);
        #20;
        read_transaction(32'h3000, 8'h3, 2'b10, 32'h300);

        // Wait for completion
        wait(!RVALID && !WVALID);
        #100;

        // Report results
        $display("\nTest Summary at time %0t:", $time);
        if (error_count == 0)
            $display("Test Completed Successfully!");
        else
            $display("Test Failed with %d errors!", error_count);
        
        $finish;
    end

    // Protocol violation monitoring
    always @(posedge clk) begin
        if (!reset) begin
            // Check for VALID without READY
            if (AWVALID && !AWREADY) 
                $display("Warning: Write address stall at time %0t", $time);
            if (WVALID && !WREADY)
                $display("Warning: Write data stall at time %0t", $time);
            if (ARVALID && !ARREADY)
                $display("Warning: Read address stall at time %0t", $time);
            if (RVALID && !RREADY)
                $display("Warning: Read data stall at time %0t", $time);
        end
    end

endmodule