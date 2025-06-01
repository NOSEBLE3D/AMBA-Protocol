`timescale 1ns/1ps

module axi4_top (
    // Global Signals
    input wire clk,
    input wire reset,
    
    // User Interface Control Signals
    input wire        wr_tx,           // Write transaction start
    input wire        rd_tx,           // Read transaction start
    output wire       wr_done,         // Write transaction complete
    output wire       rd_done,         // Read transaction complete
    output wire       rd_data_valid,   // Read data valid
    
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
    output wire [31:0] rd_data         // Read data output
);

    // AXI Interconnect Signals
    // Write Address Channel
    wire [31:0] AWADDR;
    wire [7:0]  AWLEN;
    wire [2:0]  AWSIZE;
    wire [1:0]  AWBURST;
    wire        AWVALID;
    wire        AWREADY;
    
    // Write Data Channel
    wire [31:0] WDATA;
    wire        WVALID;
    wire        WLAST;
    wire        WREADY;
    
    // Write Response Channel
    wire        BRESP;
    wire        BVALID;
    wire        BREADY;
    
    // Read Address Channel
    wire [31:0] ARADDR;
    wire [7:0]  ARLEN;
    wire [2:0]  ARSIZE;
    wire [1:0]  ARBURST;
    wire        ARVALID;
    wire        ARREADY;
    
    // Read Data Channel
    wire [31:0] RDATA;
    wire        RRESP;
    wire        RLAST;
    wire        RVALID;
    wire        RREADY;

    // Master Instance
    axi_master master (
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
        
        // Write Address Channel
        .AWADDR(AWADDR),
        .AWLEN(AWLEN),
        .AWSIZE(AWSIZE),
        .AWBURST(AWBURST),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        
        // Write Data Channel
        .WDATA(WDATA),
        .WVALID(WVALID),
        .WLAST(WLAST),
        .WREADY(WREADY),
        
        // Write Response Channel
        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),
        
        // Read Address Channel
        .ARADDR(ARADDR),
        .ARLEN(ARLEN),
        .ARSIZE(ARSIZE),
        .ARBURST(ARBURST),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
        
        // Read Data Channel
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RLAST(RLAST),
        .RVALID(RVALID),
        .RREADY(RREADY)
    );

    // Slave Instance
    axi_slave slave (
        .clk(clk),
        .reset(reset),
        
        // Write Address Channel
        .AWADDR(AWADDR),
        .AWLEN(AWLEN),
        .AWSIZE(AWSIZE),
        .AWBURST(AWBURST),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        
        // Write Data Channel
        .WDATA(WDATA),
        .WVALID(WVALID),
        .WLAST(WLAST),
        .WREADY(WREADY),
        
        // Write Response Channel
        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),
        
        // Read Address Channel
        .ARADDR(ARADDR),
        .ARLEN(ARLEN),
        .ARSIZE(ARSIZE),
        .ARBURST(ARBURST),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
        
        // Read Data Channel
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RLAST(RLAST),
        .RVALID(RVALID),
        .RREADY(RREADY)
    );

endmodule