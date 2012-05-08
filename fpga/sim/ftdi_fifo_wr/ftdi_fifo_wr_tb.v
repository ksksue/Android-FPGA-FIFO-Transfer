/*
 * Test Bench
 */
`timescale 1ns / 1ps
module ftdi_fifo_wr_tb;

//////////////////////////////////////////////////////////////////////////////
// system clock parameters
//////////////////////////////////////////////////////////////////////////////
//localparam real FRQ = 50_000_000;  // 24MHz // realistic option
localparam real FRQ =  48000;  //  48kHz // option for faster simulation
localparam real CP  = 1000000000/FRQ;  // clock period

//////////////////////////////////////////////////////////////////////////////
// reg and wire
//////////////////////////////////////////////////////////////////////////////
reg         act_wr;
reg         fifo_txe;
reg [7:0]   wr_data;

wire        run_wr;
wire        done_wr;
wire        fifo_wr;
wire [7:0]  fifo_wr_data;

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

`ifdef HOGE
integer i;
task BITINPUT;
    input CARRY;
    input [23:0] RES_DATA;
    input [2:0] GRS;
    reg [27:0] DATA;
    begin

    DATA <= {CARRY,RES_DATA,GRS};
    @(posedge CLK)
    CTRL_IN <= 1'b1;
    @(posedge CLK)
    CTRL_IN <= 1'b0;
    RES_MAN <= DATA[0];
    for(i=1;i<27;i=i+1) begin
        @(posedge CLK)
        RES_MAN <= DATA[i];
    end
    @(posedge CLK)
    CTRL_IN <= 1'b1;
    RES_MAN <= DATA[i];
    @(posedge CLK)
    CTRL_IN <= 1'b0;
    RES_MAN <= 1'b0;
    end
endtask
`endif

initial begin
    act_wr          <= 1'b1;
    fifo_txe        <= 1'b1;
    wr_data         <= 8'h00;

    wait (rst);

//////////////////////////////////////////////////////////////////////////////
    @(posedge clk)

    act_wr          <= 1'b0;
    fifo_txe        <= 1'b0;

    @(posedge clk)
    act_wr          <= 1'b1;
    fifo_txe        <= 1'b0;

    wait (~done_wr);

    act_wr          <= 1'b1;
    fifo_txe        <= 1'b1;

//////////////////////////////////////////////////////////////////////////////
    @(posedge clk)
    act_wr          <= 1'b1;
    fifo_txe        <= 1'b1;
    wr_data         <= 8'h01;

    @(posedge clk)

    act_wr          <= 1'b0;
    fifo_txe        <= 1'b0;

    @(posedge clk)
    act_wr          <= 1'b1;
    fifo_txe        <= 1'b0;

    wait (~done_wr);

//////////////////////////////////////////////////////////////////////////////
    repeat (40) @(posedge clk);

    $stop(0);
end

//////////////////////////////////////////////////////////////////////////////
// RTL instance
//////////////////////////////////////////////////////////////////////////////

ftdi_fifo_wr ftdi_fifo_wr(
    // Connect to Inner Logic
    .iACT_WR_n(act_wr),
    .oRUN_WR_n(run_wr),
    .oDONE_WR_n(done_wr),
    .iWR_DATA(wr_data),

    // Connect to FTDI FIFO Module
    .iFIFO_TXE_n(fifo_txe),
    .oFIFO_WR(fifo_wr),
    .oFIFO_DATA(fifo_wr_data),

    // Connect to System Signals
    .clk(clk),
    .rst(rst)
);

endmodule
