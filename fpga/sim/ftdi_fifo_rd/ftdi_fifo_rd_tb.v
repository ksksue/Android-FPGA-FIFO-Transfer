/*
 * Test Bench
 */
`timescale 1ns / 1ps
module ftdi_fifo_rd_tb;

//////////////////////////////////////////////////////////////////////////////
// system clock parameters
//////////////////////////////////////////////////////////////////////////////
//localparam real FRQ = 50_000_000;  // 24MHz // realistic option
localparam real FRQ =  48000;  //  48kHz // option for faster simulation
localparam real CP  = 1000000000/FRQ;  // clock period

//////////////////////////////////////////////////////////////////////////////
// reg and wire
//////////////////////////////////////////////////////////////////////////////
reg         act_rd;
reg         fifo_rxf;
reg [7:0]   fifo_rd_data;

wire        run_rd;
wire        done_rd;
wire        fifo_rd;
wire [7:0]  rd_data;

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
    act_rd          <= 1'b1;
    fifo_rxf        <= 1'b1;
    fifo_rd_data    <= 8'h00;

    wait (rst);

//////////////////////////////////////////////////////////////////////////////
    @(posedge clk)

    act_rd          <= 1'b0;
    fifo_rxf        <= 1'b0;

    @(posedge clk)
    act_rd          <= 1'b1;
    fifo_rxf        <= 1'b0;

    wait (~done_rd);

    act_rd          <= 1'b1;
    fifo_rxf        <= 1'b1;

//////////////////////////////////////////////////////////////////////////////
    @(posedge clk)
    act_rd          <= 1'b1;
    fifo_rxf        <= 1'b1;
    fifo_rd_data    <= 8'h01;

    @(posedge clk)

    act_rd          <= 1'b0;
    fifo_rxf        <= 1'b0;

    @(posedge clk)
    act_rd          <= 1'b1;
    fifo_rxf        <= 1'b0;

    wait (~done_rd);

//////////////////////////////////////////////////////////////////////////////
    repeat (40) @(posedge clk);

    $stop(0);
end

//////////////////////////////////////////////////////////////////////////////
// RTL instance
//////////////////////////////////////////////////////////////////////////////

ftdi_fifo_rd ftdi_fifo_rd(
    // Connect to Inner Logic
    .iACT_RD_n(act_rd),
    .oRUN_RD_n(run_rd),
    .oDONE_RD_n(done_rd),
    .oRD_DATA(rd_data),

    // Connect to FTDI FIFO Module
    .iFIFO_RXF_n(fifo_rxf),
    .oFIFO_RD_n(fifo_rd),
    .iFIFO_DATA(fifo_rd_data),

    // Connect to System Signals
    .clk(clk),
    .rst(rst)
);

endmodule
