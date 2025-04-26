`timescale 1ns/1ps

module ahb_master (
  input        HCLK,
  input        HRESETn,
  input        HREADY,
  input [31:0] ADDR,
  input [31:0] WDATA,
  input        WRITE,
  input [2:0]  BURST,
  input [2:0]  SIZE,
  input        transfer_start,   // <-- Added as input

  output reg [31:0] HADDR,
  output reg [31:0] HWDATA,
  output reg        HWRITE,
  output reg [2:0]  HBURST,
  output reg [2:0]  HSIZE,
  output reg [1:0]  HTRANS,
  output reg        HSEL
);

  // FSM states
  parameter IDLE = 2'b00, NONSEQ = 2'b10, SEQ = 2'b11, BUSY = 2'b01;

  reg [1:0] state, next_state;
  reg [3:0] burst_count;

  reg [31:0] data_latch;
  // FSM Sequential
  always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
      state <= IDLE;
    else if (HREADY)
      state <= next_state;
  end

  // FSM Combinational
  always @(*) begin
    case (state)
      IDLE: begin
        //HSEL <= 0;
        if (transfer_start)
          next_state = NONSEQ;
        else
          next_state = IDLE;
      end

      NONSEQ: begin
        //HSEL <= 1;
        if (BURST == 3'b000)
          next_state = IDLE;
        else
          next_state = SEQ;
      end

      SEQ: begin
        //HSEL <= 1;
        if (burst_count == 0)
          next_state = IDLE;
        else
          next_state = SEQ;
      end

      BUSY: begin
        //HSEL <= 0;
        next_state = NONSEQ;
      end

      default: next_state = IDLE;
    endcase
  end 

  // Control Logic
  always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
      HADDR        <= 0;
      HWDATA       <= 0;
      HWRITE       <= 0;
      HBURST       <= 0;
      HSIZE        <= 0;
      HTRANS       <= IDLE;
      burst_count  <= 0;
      HSEL         <= 0;
    end else if (HREADY) begin
      HWDATA <= data_latch;
      case (next_state)

        IDLE: begin
          HADDR     <= 32'h0;
          HWDATA    <= WDATA;
          HWRITE    <= 0;
          HTRANS    <= IDLE;
          HSEL      <= 0;
          
            /*if (transfer_start)
          next_state = NONSEQ;
        else
          next_state = IDLE;*/
        end

        NONSEQ: begin
          HADDR     <= ADDR;
          data_latch    <= WDATA;
          HWRITE    <= WRITE;
          HBURST    <= BURST;
          HSIZE     <= SIZE; // {1'b0, SIZE}
          HTRANS    <= NONSEQ;
          HSEL      <= 1;

          case (BURST)
            3'b010, 3'b011: burst_count <= 3;
            3'b100, 3'b101: burst_count <= 7;
            3'b110, 3'b111: burst_count <= 15;
            default:        burst_count <= 0;
          endcase
          
           /* if (BURST == 3'b000)
          next_state = IDLE;
        else
          next_state = SEQ;*/
        end

        SEQ: begin
          data_latch <= WDATA;
          HWRITE <= WRITE;
          HTRANS <= SEQ;
          HSEL   <= 1;
          case (HBURST)
            3'b010, 3'b100, 3'b110:
              HADDR <= wrap_address_generator(HADDR, HSIZE, HBURST);
            3'b001, 3'b011, 3'b101, 3'b111:
              HADDR <= increment_address_generator(HADDR, HBURST);
            default:
              HADDR <= HADDR;
          endcase

          if (burst_count != 0)
            burst_count <= burst_count - 1;
            
         /*  else if (burst_count == 0)
          next_state = IDLE;
        else
          next_state = SEQ; */
        end

        BUSY: begin
          HADDR     <= 0;
          HWDATA    <= 0;
          HWRITE    <= 0;
          HTRANS    <= BUSY;
          HSEL      <= 0;
           // next_state = NONSEQ;
        end

        default: begin
          HTRANS <= IDLE;
        end
      endcase
    end
  end

  // ========= Function for WRAP Address ========= //
function [31:0] wrap_address_generator;
  input [31:0] curr_addr;
  input [2:0]  hsize;
  input [2:0]  hburst;

  reg [31:0] num_bytes;
  reg [31:0] burst_len;
  reg [31:0] boundary;
  reg [31:0] offset_mask;
  reg [31:0] next_addr;
begin
  // Byte count
  case (hsize)
    3'b000: num_bytes = 1;
    3'b001: num_bytes = 2;
    3'b010: num_bytes = 4;
    3'b011: num_bytes = 8;
    3'b100: num_bytes = 16;
    default: num_bytes = 4;
  endcase

  // Burst length
  case (hburst)
    3'b010: burst_len = 4;
    3'b100: burst_len = 8;
    3'b110: burst_len = 16;
    default: burst_len = 1;
  endcase

  // Wrap boundary: clear lower bits based on total wrap size
  boundary = (curr_addr / (num_bytes * burst_len)) * (num_bytes * burst_len);
  offset_mask = (num_bytes * burst_len) - 1;

  // Next address
  next_addr = curr_addr + burst_len;
  if ((next_addr & offset_mask) == 0)
    wrap_address_generator = boundary;
  else
    wrap_address_generator = next_addr;
end
endfunction


  // ========= Function for INCR Address ========= //
  function [31:0] increment_address_generator;
    input [31:0] current_addr;
    //input [1:0] hsize;
    input [2:0] burst;

    reg [31:0] num_bytes;
    begin
      case (burst)
        3'b000: num_bytes = 0;
        3'b001: num_bytes = 4;
        3'b011: num_bytes = 4;
        3'b101: num_bytes = 8;
        3'b111: num_bytes = 16;
        default: num_bytes = 0;
      endcase

      increment_address_generator = current_addr + num_bytes;
    end
  endfunction

endmodule
