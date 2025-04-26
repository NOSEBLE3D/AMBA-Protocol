`timescale 1ns/1ps

module ahb_slave (
  input         HCLK,
  input         HRESETn,
  input         HSEL,
  input         HWRITE,
  input  [1:0]  HTRANS,
  input  [2:0]  HBURST,
  input  [2:0]  HSIZE,
  input  [31:0] HADDR,
  input  [31:0] HWDATA,
  output reg [31:0] HRDATA,
  output reg        HREADY
);

  // Memory array
  parameter MEM_SIZE = 1024;  // 1K words
  reg [31:0] mem [0:MEM_SIZE-1];
  
  // Define valid transfer
  wire valid_transfer = HSEL && (HTRANS[1]); 

  // Address phase signals
  reg        addr_phase_write;
  reg [31:0] addr_phase_addr;
  reg        addr_phase_valid;

  // Combined address and data phase operation
  always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
      addr_phase_write <= 1'b0;
      addr_phase_addr  <= 32'b0;
      addr_phase_valid <= 1'b0;
      HRDATA          <= 32'b0;
      HREADY          <= 1'b1;
    end else begin
      // Default HREADY value
      HREADY <= 1'b1;
      
      // Address phase
      if (HREADY) begin
        addr_phase_write <= HWRITE;
        addr_phase_addr  <= HADDR;
        addr_phase_valid <= valid_transfer;
      end

      // Data phase
      if (HREADY) begin
        if (valid_transfer && !HWRITE) begin
          // Read operation
          HRDATA <= mem[HADDR[11:2]];
        end
        if (addr_phase_valid && addr_phase_write) begin
          // Write operation
          mem[addr_phase_addr[11:2]] <= HWDATA;
        end
      end
    end
  end

endmodule