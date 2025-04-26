`timescale 1ns/1ps

module ahb_top_tb;

  reg         HCLK = 0;
  reg         HRESETn = 0;
  reg         transfer_start;
  reg  [31:0] ADDR;
  reg  [31:0] WDATA;
  reg         WRITE;
  reg  [2:0]  BURST;
  reg  [2:0]  SIZE;

  // Monitor signals
  wire [31:0] HADDR;
  wire [31:0] HWDATA;
  wire [31:0] HRDATA;
  wire        HWRITE;
  wire        HREADY;
  wire [2:0]  HBURST;
  wire [2:0]  HSIZE;
  wire [1:0]  HTRANS;

  // Clock generation
  always #5 HCLK = ~HCLK;

  // DUT Instance
  ahb_top DUT (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .ADDR(ADDR),
    .WDATA(WDATA),
    .WRITE(WRITE),
    .BURST(BURST),
    .SIZE(SIZE),
    .transfer_start(transfer_start),
    .HRDATA(HRDATA)
  );

  // Write Task for Pipelined Transfers
  task ahb_write;
    input [31:0] addr;
    input [31:0] data;
    input [2:0]  burst;
    input [2:0]  size;
    reg   [31:0] current_data;
    integer beats;
    integer i;
    begin
      ADDR           = addr;
      current_data   = data;
      BURST          = burst;
      SIZE           = size;
      WRITE          = 1;
      transfer_start = 1;

      // Determine number of beats
      case (burst)
        3'b000: beats = 1;  // SINGLE
        3'b011: beats = 4;  // INCR4
        3'b010: beats = 4;  // WRAP4
        3'b100: beats = 8;  // WRAP8
        default: beats = 1;
      endcase

      // Address Phase
      @(posedge HCLK);
      
      // Data Phase with pipelining
      for(i = 0; i < beats; i = i + 1) begin
        WDATA = current_data;
        current_data = {current_data[30:0], current_data[31]};  // Rotate data
        @(posedge HCLK);
        while(!HREADY) @(posedge HCLK);
      end

      transfer_start = 0;
      repeat(2) @(posedge HCLK);
    end
  endtask

  // Read Task for Pipelined Transfers
  task ahb_read;
    input [31:0] addr;
    input [2:0]  burst;
    input [2:0]  size;
    integer beats;
    integer i;
    begin
      ADDR           = addr;
      BURST          = burst;
      SIZE           = size;
      WRITE          = 0;
      transfer_start = 1;

      case (burst)
        3'b000: beats = 1;  // SINGLE
        3'b011: beats = 4;  // INCR4
        3'b010: beats = 4;  // WRAP4
        3'b100: beats = 8;  // WRAP8
        default: beats = 1;
      endcase

      // Address Phase
      @(posedge HCLK);
      
      // Data Phase
      for(i = 0; i < beats; i = i + 1) begin
        @(posedge HCLK);
        while(!HREADY) @(posedge HCLK);
        //$display("[2025-04-24 14:33:12] [NOSEBLE3D] Read Data[%0d]: %h", i, HRDATA);
      end

      transfer_start = 0;
      repeat(2) @(posedge HCLK);
    end
  endtask

  // Monitor Task
  task monitor_transfer;
    begin
      $display("HTRANS=%b HADDR=%h HWDATA=%h HRDATA=%h HWRITE=%b HREADY=%b",
               HTRANS, HADDR, HWDATA, HRDATA, HWRITE, HREADY);
    end
  endtask

  // Stimulus
  initial begin
    $dumpfile("ahb_top_tb.vcd");
    $dumpvars(0, ahb_top_tb);

    // Initialize
    transfer_start = 0;
    ADDR = 0; WDATA = 0; BURST = 0; SIZE = 3'b010; WRITE = 0;

    // Reset
    repeat (2) @(posedge HCLK);
    HRESETn = 1;
    @(posedge HCLK);

    // Test 1: Single Burst Write
   // $display("\n[2025-04-24 14:33:12] [NOSEBLE3D] === Single Burst Write Test ===");
    ahb_write(32'h0000_0010, 32'hA1B2_C3D4, 3'b000, 3'b010);

    // Test 2: Single Burst Read
  //  $display("\n[2025-04-24 14:33:12] [NOSEBLE3D] === Single Burst Read Test ===");
    ahb_read(32'h0000_0010, 3'b000, 3'b010);

    // Test 3: INCR4 Write
  //  $display("\n[2025-04-24 14:33:12] [NOSEBLE3D] === INCR4 Burst Write Test ===");
    ahb_write(32'h0000_0020, 32'h1111_2222, 3'b011, 3'b010);

    // Test 4: INCR4 Read
   // $display("\n[2025-04-24 14:33:12] [NOSEBLE3D] === INCR4 Burst Read Test ===");
    ahb_read(32'h0000_0020, 3'b011, 3'b010);

    // Test 5: WRAP4 Write
   // $display("\n[2025-04-24 14:33:12] [NOSEBLE3D] === WRAP4 Burst Write Test ===");
    ahb_write(32'h0000_0030, 32'h3333_4444, 3'b010, 3'b010);

    // Test 6: WRAP4 Read
   // $display("\n[2025-04-24 14:33:12] [NOSEBLE3D] === WRAP4 Burst Read Test ===");
    ahb_read(32'h0000_0030, 3'b010, 3'b010);

    // Test 7: WRAP8 Write
   // $display("\n[2025-04-24 14:33:12] [NOSEBLE3D] === WRAP8 Burst Write Test ===");
    ahb_write(32'h0000_0040, 32'hAAAA_BBBB, 3'b100, 3'b011);

    // Test 8: WRAP8 Read
   // $display("\n[2025-04-24 14:33:12] [NOSEBLE3D] === WRAP8 Burst Read Test ===");
    ahb_read(32'h0000_0040, 3'b100, 3'b011);

    repeat (10) @(posedge HCLK);
    $finish;
  end

  // Continuous monitoring
  initial begin
    forever begin
      @(posedge HCLK);
      if(transfer_start) monitor_transfer();
    end
  end

endmodule