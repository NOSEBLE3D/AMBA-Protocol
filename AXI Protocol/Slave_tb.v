`timescale 1ns/1ps

module axi_slave_tb();
    // Clock and Reset
    reg clk;
    reg reset;

    // Write Channel Signals
    reg [31:0] AWADDR;
    reg [7:0]  AWLEN;
    reg [2:0]  AWSIZE;
    reg [1:0]  AWBURST;
    reg        AWVALID;
    wire       AWREADY;
    reg [31:0] WDATA;
    reg        WVALID;
    reg        WLAST;
    wire       WREADY;
    wire [1:0] BRESP;
    wire       BVALID;
    reg        BREADY;

    // Read Channel Signals
    reg [31:0] ARADDR;
    reg [7:0]  ARLEN;
    reg [2:0]  ARSIZE;
    reg [1:0]  ARBURST;
    reg        ARVALID;
    wire       ARREADY;
    wire [31:0] RDATA;
    wire [1:0]  RRESP;
    wire        RLAST;
    wire        RVALID;
    reg         RREADY;

    // Test bench signals
    reg [31:0] test_data [0:15];
    integer write_index;
    integer read_index;
    integer error_count;
    reg [31:0] read_data [0:15];

    // DUT Instance
    axi_slave dut (
        .clk(clk),
        .reset(reset),
        .AWADDR(AWADDR),
        .AWLEN(AWLEN),
        .AWSIZE(AWSIZE),
        .AWBURST(AWBURST),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        .WDATA(WDATA),
        .WVALID(WVALID),
        .WLAST(WLAST),
        .WREADY(WREADY),
        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),
        .ARADDR(ARADDR),
        .ARLEN(ARLEN),
        .ARSIZE(ARSIZE),
        .ARBURST(ARBURST),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
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

    // Write burst task
    task write_burst;
        input [31:0] start_addr;
        input [7:0]  burst_len;
        input [1:0]  burst_type;
        input integer data_start_idx;
        begin
            $display("\nStarting Write Burst: Address=%h, Length=%d, Type=%d", 
                     start_addr, burst_len, burst_type);
            
            // Write Address Phase
            @(posedge clk);
            AWADDR = start_addr;
            AWLEN = burst_len;
            AWSIZE = 3'b010;  // 4 bytes
            AWBURST = burst_type;
            AWVALID = 1;
            
            wait(AWREADY);
            @(posedge clk);
            AWVALID = 0;

            // Write Data Phase
            write_index = data_start_idx;
            while (write_index <= data_start_idx + burst_len) begin
                @(posedge clk);
                WDATA = test_data[write_index];
                WVALID = 1;
                WLAST = (write_index == data_start_idx + burst_len);
                
                wait(WREADY);
                $display("Write Data[%0d]: %h", write_index - data_start_idx, WDATA);
                write_index = write_index + 1;
            end
            
            @(posedge clk);
            WVALID = 0;
            WLAST = 0;

            // Write Response Phase
            BREADY = 1;
            wait(BVALID);
            @(posedge clk);
            if (BRESP != 2'b00) begin
                $display("Error: Write response error BRESP=%b", BRESP);
                error_count = error_count + 1;
            end
            BREADY = 0;
            
            repeat(2) @(posedge clk);
            $display("Write Burst Complete\n");
        end
    endtask

    // Read burst task
    task read_burst;
        input [31:0] start_addr;
        input [7:0]  burst_len;
        input [1:0]  burst_type;
        input integer exp_data_idx;
        begin
            $display("\nStarting Read Burst: Address=%h, Length=%d, Type=%d", 
                     start_addr, burst_len, burst_type);
            
            // Read Address Phase
            @(posedge clk);
            ARADDR = start_addr;
            ARLEN = burst_len;
            ARSIZE = 3'b010;  // 4 bytes
            ARBURST = burst_type;
            ARVALID = 1;
            
            wait(ARREADY);
            @(posedge clk);
            ARVALID = 0;

            // Read Data Phase
            RREADY = 1;
            read_index = 0;
            
            while (read_index <= burst_len) begin
                @(posedge clk);
                if (RVALID) begin
                    read_data[read_index] = RDATA;
                    $display("Read Data[%0d]: %h (Expected: %h)", 
                            read_index, RDATA, test_data[exp_data_idx + read_index]);
                    
                    // Verify data
                    if (RDATA !== test_data[exp_data_idx + read_index]) begin
                        $display("Error: Data mismatch at index %0d", read_index);
                        error_count = error_count + 1;
                    end
                    
                    read_index = read_index + 1;
                end
            end
            
            @(posedge clk);
            RREADY = 0;
            
            repeat(2) @(posedge clk);
            $display("Read Burst Complete\n");
        end
    endtask

    // Main test sequence
    initial begin
        // Initialize signals
        reset = 1;
        error_count = 0;
        AWVALID = 0;
        WVALID = 0;
        WLAST = 0;
        BREADY = 0;
        ARVALID = 0;
        RREADY = 0;
        
        // Initialize test data
        // FIXED burst data (0x100-0x103)
        test_data[0] = 32'h100;
        test_data[1] = 32'h101;
        test_data[2] = 32'h102;
        test_data[3] = 32'h103;
        
        // INCR burst data (0x200-0x207)
        test_data[4] = 32'h200;
        test_data[5] = 32'h201;
        test_data[6] = 32'h202;
        test_data[7] = 32'h203;
        test_data[8] = 32'h204;
        test_data[9] = 32'h205;
        test_data[10] = 32'h206;
        test_data[11] = 32'h207;
        
        // WRAP burst data (0x300-0x303)
        test_data[12] = 32'h300;
        test_data[13] = 32'h301;
        test_data[14] = 32'h302;
        test_data[15] = 32'h303;

        // Reset sequence
        #100 reset = 0;
        #100;

        // Test 1: FIXED burst
        $display("\n=== Testing FIXED Burst ===");
        write_burst(32'h00000000, 8'h03, 2'b00, 0);
        read_burst(32'h00000000, 8'h03, 2'b00, 0);
        
        // Test 2: INCR burst
        $display("\n=== Testing INCR Burst ===");
        write_burst(32'h00000020, 8'h07, 2'b01, 4);
        read_burst(32'h00000020, 8'h07, 2'b01, 4);
        
        // Test 3: WRAP burst
        $display("\n=== Testing WRAP Burst ===");
        write_burst(32'h00000040, 8'h03, 2'b10, 12);
        read_burst(32'h00000040, 8'h03, 2'b10, 12);

        // Test completion and report
        repeat(10) @(posedge clk);
        
        if (error_count == 0)
            $display("\nTest Completed Successfully!");
        else
            $display("\nTest Failed with %d errors!", error_count);
            
        $finish;
    end

    // Monitor for protocol violations
    always @(posedge clk) begin
        if (!reset) begin
            // Write channel monitoring
            if (WVALID && !WREADY)
                $display("Warning: Write data stall at time %t", $time);
            
            if (BVALID && !BREADY)
                $display("Warning: Write response stall at time %t", $time);
            
            // Read channel monitoring
            if (RVALID && !RREADY)
                $display("Warning: Read data stall at time %t", $time);
        end
    end

endmodule