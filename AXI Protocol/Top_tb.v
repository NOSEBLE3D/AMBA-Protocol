`timescale 1ns/1ps

module axi4_top_tb();
    // Clock and Reset
    reg clk;
    reg reset;
    
    // User Interface Control
    reg         wr_tx;
    reg         rd_tx;
    wire        wr_done;
    wire        rd_done;
    wire        rd_data_valid;
    
    // Write Interface
    reg [31:0]  wr_addr;
    reg [7:0]   wr_len;
    reg [2:0]   wr_size;
    reg [1:0]   wr_burst;
    reg [31:0]  wr_data;
    
    // Read Interface
    reg [31:0]  rd_addr;
    reg [7:0]   rd_len;
    reg [2:0]   rd_size;
    reg [1:0]   rd_burst;
    wire [31:0] rd_data;

    // Test bench signals
    reg [31:0] test_data [0:15];
    integer burst_count;
    integer data_count;
    integer error_count;
    integer i;
    reg [7:0] current_burst_len;
    
    // Expected data storage
    reg [31:0] expected_rdata;

    // DUT Instance
    axi4_top dut (
        .clk(clk),
        .reset(reset),
        .wr_tx(wr_tx),
        .rd_tx(rd_tx),
        .wr_done(wr_done),
        .rd_done(rd_done),
        .rd_data_valid(rd_data_valid),
        .wr_addr(wr_addr),
        .wr_len(wr_len),
        .wr_size(wr_size),
        .wr_burst(wr_burst),
        .wr_data(wr_data),
        .rd_addr(rd_addr),
        .rd_len(rd_len),
        .rd_size(rd_size),
        .rd_burst(rd_burst),
        .rd_data(rd_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Write transaction task
    task write_burst_transaction;
        input [31:0] addr;
        input [7:0]  len;
        input [1:0]  burst;
        input [31:0] start_data;
        begin
            $display("\nStarting Write Burst Transaction at time %0t:", $time);
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
            
            // Store test data for verification
            case (burst)
                2'b00: begin // FIXED
                    for(i = 0; i <= len; i = i + 1) begin
                        test_data[i] = start_data;
                    end
                end
                2'b01: begin // INCR
                    for(i = 0; i <= len; i = i + 1) begin
                        test_data[i] = start_data + i;
                    end
                end
                2'b10: begin // WRAP
                    for(i = 0; i <= len; i = i + 1) begin
                        test_data[i] = start_data + (i % (len + 1));
                    end
                end
            endcase
            
            $display("Write Burst Transaction Complete at time %0t", $time);
        end
    endtask

    // Read transaction task
    task read_burst_transaction;
        input [31:0] addr;
        input [7:0]  len;
        input [1:0]  burst;
        input [31:0] exp_start_data;
        begin
            $display("\nStarting Read Burst Transaction at time %0t:", $time);
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
                    // Calculate expected data based on burst type
                    case (burst)
                        2'b00: expected_rdata = exp_start_data;  // FIXED
                        2'b01: expected_rdata = exp_start_data + data_count;  // INCR
                        2'b10: expected_rdata = exp_start_data + (data_count % (len + 1));  // WRAP
                    endcase
                    
                    // Verify received data
                    if (rd_data !== expected_rdata) begin
                        $display("Error: Data mismatch at time %0t", $time);
                        $display("Expected: %h, Got: %h", expected_rdata, rd_data);
                        error_count = error_count + 1;
                    end
                    
                    $display("Read Data[%0d]: %h at time %0t", data_count, rd_data, $time);
                    data_count = data_count + 1;
                end
            end
            
            wait(rd_done);
            $display("Read Burst Transaction Complete at time %0t", $time);
        end
    endtask

    // Main test sequence
    initial begin
        // Initialize signals
        reset = 1;
        wr_tx = 0;
        rd_tx = 0;
        error_count = 0;
        
        // Reset sequence
        #100 reset = 0;
        #100;

        // Test FIXED burst
        $display("\n=== Testing FIXED Burst ===");
        write_burst_transaction(32'h0001, 8'h1, 2'b00, 32'h100);
        #20;
       // read_burst_transaction(32'h0001, 8'h3, 2'b00, 32'h100);
       // #50;
        
        // Test INCR burst
        $display("\n=== Testing INCR Burst ===");
        write_burst_transaction(32'h0002, 8'h5, 2'b01, 32'h200);
        #20;
       // read_burst_transaction(32'h0002, 8'h7, 2'b01, 32'h200);
       // #50;
        
        // Test WRAP burst
        $display("\n=== Testing WRAP Burst ===");
        write_burst_transaction(32'd48, 8'h7, 2'b10, 32'h300);
        #20;
        read_burst_transaction(32'h0001, 8'h1, 2'b00, 32'h100); // fixed
        #20;
        read_burst_transaction(32'h0002, 8'h5, 2'b01, 32'h200); // incr
        //#20;
        //read_burst_transaction(32'h0001, 8'h3, 2'b00, 32'h100);
        #20;
        read_burst_transaction(32'd48, 8'h7, 2'b10, 32'h300); // wrap
        #50;

        // Test mixed burst types
      /*  $display("\n=== Testing Mixed Burst Types ===");
        write_burst_transaction(32'h4000, 8'h3, 2'b01, 32'h400);
        #20;
        read_burst_transaction(32'h4000, 8'h3, 2'b00, 32'h400);
        #50;*/

        // Test completion
        #100;
        if (error_count == 0)
            $display("\nTest Completed Successfully!");
        else
            $display("\nTest Failed with %d errors!", error_count);
        
        $finish;
    end

    // Monitor for protocol violations
    always @(posedge clk) begin
        if (!reset) begin
            // Monitor write response
            if (wr_done)
                $display("Write transaction completed at time %0t", $time);
            
            // Monitor read response
            if (rd_done)
                $display("Read transaction completed at time %0t", $time);
            
            // Monitor data validity
            if (rd_data_valid)
                $display("Valid read data received: %h at time %0t", rd_data, $time);
        end
    end

endmodule