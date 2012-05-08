/*
 * Test Bench
 */
`timescale 1ns / 1ps
module ftdi_fifo_tb;

//////////////////////////////////////////////////////////////////////////////
// system clock parameters
//////////////////////////////////////////////////////////////////////////////
//localparam real FRQ = 50_000_000;  // 24MHz // realistic option
localparam real FRQ =  48000;  //  48kHz // option for faster simulation
localparam real CP  = 1000000000/FRQ;  // clock period

//////////////////////////////////////////////////////////////////////////////
// reg and wire
//////////////////////////////////////////////////////////////////////////////
wire        fifo_rxf_n;
wire        fifo_rd_n;
wire [7:0]  fifo_rd_data;
wire        fifo_txe_n;
wire        fifo_wr_n;
wire [7:0]  fifo_wr_data;
wire        fifo_oe_n;
wire        rd_verify_ng;

wire [7:0]  iofifo_data;

//////////////////////////////////////////////////////////////////////////////
// request for a dumpfile
//////////////////////////////////////////////////////////////////////////////
//`define DUMPOUT
`ifdef DUMPOUT
initial begin
    $dumpfile(".vcd");
    $dumpvars(0, hogehoge);
end
`endif

//////////////////////////////////////////////////////////////////////////////
// read a pattern file
//////////////////////////////////////////////////////////////////////////////
//`define READPAT
`ifdef READPAT
parameter PAT_NUM = 256
reg[20:0] pat [0:PAT_NUM-1];

$readmemb("master.pat",pat);

for (i=0;i<PAT_NUM;i=i+1) begin
    {hoge,hogehoge} = pat[i];
end
`endif

//////////////////////////////////////////////////////////////////////////////
// clock and reset
//////////////////////////////////////////////////////////////////////////////

// clock generation
reg clk;
initial         clk = 1'b1;
always #(CP/2)  clk = ~clk;

// reset generation
reg rst;
initial begin
    rst = 1'b0;
    @(posedge clk);
    rst = 1'b1;
end

//////////////////////////////////////////////////////////////////////////////
// Test Sequence
//////////////////////////////////////////////////////////////////////////////

initial begin
    wait(ftdi_fifo.wr_ctrl_state == ftdi_fifo.ST_WRCTRL_DONE)
    $stop(0);
end

//////////////////////////////////////////////////////////////////////////////
// RTL instance
//////////////////////////////////////////////////////////////////////////////

ftdi_fifo ftdi_fifo(
    // Connect to FTDI FIFO Module
    .iFIFO_RXF_n(fifo_rxf_n),
    .oFIFO_RD_n(fifo_rd_n),
    .iFIFO_DATA(fifo_rd_data),
    
    .iFIFO_TXE_n(fifo_txe_n),
    .oFIFO_WR_n(fifo_wr_n),
    .oFIFO_DATA(fifo_wr_data),
    .oFIFO_OE_n(fifo_oe_n),
    
    .oRD_VERIFY_NG(rd_verify_ng),
    
    // Connect to System Signals
    .clk(clk),
    .rst(rst)
);

param_inout_buf #(.DATA_WIDTH(8))
 iobuf( .ioDATA(iofifo_data),
        .iOE_n(fifo_oe_n),
        .iDATA(fifo_rd_data),
        .oDATA(fifo_wr_data),
        .clk(clk));

rl245fifo_sim_model rl245fifo_sim_model(
    .oFIFO_RXF_n(fifo_rxf_n),
    .iFIFO_RD_n(fifo_rd_n),
    .oFIFO_TXE_n(fifo_txe_n),
    .iFIFO_WR_n(fifo_wr_n),
    .ioFIFO_DATA(iofifo_data)
);

endmodule
