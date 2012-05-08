/*
 * FT245R FIFO mode write sequencer
 *
 * assumed system clock : 50MHz
 */

/*
 * Copyright (C) 2012 @ksksue
 * Licensed under the Apache License, Version 2.0
 * http://www.apache.org/licenses/LICENSE-2.0
 */
 
/* Timing chart
 *
 * Timing chart for inner logic
 *
 * 0.i:_|~|_|~|_|~|_|~|_|~|_|~|_|~|_|~|_|~|_|~|_|~|_|
 *
 * 1.o:_____________|~~~~~~~~~~~~~~~~~~~~~~~|________
 *
 * 2.i:~~~~~|___|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *
 * 3.o:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|___|~~~~~~~~
 *
 * 4.i:====><========================================
 *
 * 0.clk
 * 1.oREADY_WR_n
 * 2.iACT_WR_n
 * 3.oDONE_WR_n
 * 4.iWR_DATA
 *
 * To starting the sequence, set iACT_*'s signal negative.
 * The end triger is oDONE_*'s negative signal.
 *
 *
 * Check datasheet about FTDI FIFO's timing
 * http://www.ftdichip.com/Products/ICs/FT245R.htm
 */

//////////////////////////////////////////////////////////////////////////////
// includes
//////////////////////////////////////////////////////////////////////////////
`include "timescale.v"

//////////////////////////////////////////////////////////////////////////////
// module and I/O ports
//////////////////////////////////////////////////////////////////////////////
module ftdi_fifo_wr(
    // Connect to Inner Logic
    input           iACT_WR_n,      // Activate Write Sequence Signal
    output          oDONE_WR_n,     // Done Write Sequence Signal
    output          oREADY_WR_n,    // Ready Write Sequence Signal
    input   [7:0]   iWR_DATA,       // Write Data
    output          oFIFO_OE_n,     // Output Enable for Bi-direction Bus

    // Connect to FTDI FIFO Module
    input           iFIFO_TXE_n,    // Write to FIFO
    output          oFIFO_WR_n,     // Write Enable
    output  [7:0]   oFIFO_DATA,     // Write Data

    // Connect to System Signals
    input           clk,            // System Clock 50MHz(20ns)
    input           rst             // System Reset
    );

//////////////////////////////////////////////////////////////////////////////
// reg and wire
//////////////////////////////////////////////////////////////////////////////
reg         fifo_wr_n;
reg         fifo_oe_n;
reg  [7:0]  data_wr;
reg         ready_wr_n;
reg         done_wr_n;
reg  [3:0]  state_wr;

//////////////////////////////////////////////////////////////////////////////
// parameter
//////////////////////////////////////////////////////////////////////////////
parameter   ST_WR_IDLE              = 4'b0000,
            ST_WR_WAIT_TXE          = 4'b0001,
            ST_WR_POS_WR_DATA_OUT   = 4'b0010,
            ST_WR_DATA_SETUP1       = 4'b0011,
            ST_WR_DATA_SETUP2       = 4'b0100,
            ST_WR_NEG_WR            = 4'b0101,
            ST_WR_PRE_CHARGE1       = 4'b0110,
            ST_WR_PRE_CHARGE2       = 4'b0111,
            ST_WR_DONE              = 4'b1000;

//////////////////////////////////////////////////////////////////////////////
// RTL
//////////////////////////////////////////////////////////////////////////////
assign oREADY_WR_n  = ready_wr_n;
assign oDONE_WR_n   = done_wr_n;
assign oFIFO_WR_n   = fifo_wr_n;
assign oFIFO_DATA   = data_wr;
assign oFIFO_OE_n   = fifo_oe_n;

// FSM for reading fifo
always@(posedge clk or negedge rst) begin
    if(!rst) begin
        fifo_wr_n   <= 1'b1;
        fifo_oe_n   <= 1'b1;
        data_wr     <= 8'h00;
        ready_wr_n  <= 1'b1;
        done_wr_n   <= 1'b1;
        state_wr    <= ST_WR_IDLE;
    end
    else begin
        case(state_wr)
        ST_WR_IDLE: begin
            fifo_wr_n   <= 1'b1;
            fifo_oe_n   <= 1'b1;
            data_wr     <= iWR_DATA;
            ready_wr_n  <= 1'b0;
            done_wr_n   <= 1'b1;
            if(iACT_WR_n == 1'b0 && iFIFO_TXE_n == 1'b0) begin
                state_wr    <= ST_WR_POS_WR_DATA_OUT;
            end else if(iACT_WR_n == 1'b0 && iFIFO_TXE_n == 1'b1) begin
                state_wr    <= ST_WR_WAIT_TXE;
            end else begin
                state_wr    <= ST_WR_IDLE;
            end
        end

        ST_WR_WAIT_TXE: begin
            fifo_wr_n   <= 1'b1;
            fifo_oe_n   <= 1'b1;
            data_wr     <= data_wr;
            ready_wr_n  <= 1'b1;
            done_wr_n   <= 1'b1;
            if(iFIFO_TXE_n == 1'b0) begin
                state_wr    <= ST_WR_POS_WR_DATA_OUT;
            end else begin
                state_wr    <= ST_WR_WAIT_TXE;
            end
        end
        
        ST_WR_POS_WR_DATA_OUT: begin
            fifo_wr_n   <= 1'b1;
            fifo_oe_n   <= 1'b0;
            data_wr     <= data_wr;
            ready_wr_n  <= 1'b1;
            done_wr_n   <= 1'b1;
            state_wr    <= ST_WR_DATA_SETUP1;
        end

        ST_WR_DATA_SETUP1: begin
            fifo_wr_n   <= 1'b1;
            fifo_oe_n   <= 1'b0;
            data_wr     <= data_wr;
            ready_wr_n  <= 1'b1;
            done_wr_n   <= 1'b1;
            state_wr    <= ST_WR_DATA_SETUP2;
        end

        ST_WR_DATA_SETUP2: begin
            fifo_wr_n   <= 1'b1;
            fifo_oe_n   <= 1'b0;
            data_wr     <= data_wr;
            ready_wr_n  <= 1'b1;
            done_wr_n   <= 1'b1;
            state_wr    <= ST_WR_NEG_WR;
        end

        ST_WR_NEG_WR: begin
            fifo_wr_n   <= 1'b0;
            fifo_oe_n   <= 1'b0;
            data_wr     <= data_wr;
            ready_wr_n  <= 1'b1;
            done_wr_n   <= 1'b1;
            state_wr    <= ST_WR_PRE_CHARGE1;
        end

        ST_WR_PRE_CHARGE1: begin
            fifo_wr_n   <= 1'b0;
            fifo_oe_n   <= 1'b0;
            data_wr     <= data_wr;
            ready_wr_n  <= 1'b1;
            done_wr_n   <= 1'b1;
            state_wr    <= ST_WR_PRE_CHARGE2;
        end

        ST_WR_PRE_CHARGE2: begin
            fifo_wr_n   <= 1'b0;
            fifo_oe_n   <= 1'b1;
            data_wr     <= data_wr;
            ready_wr_n  <= 1'b1;
            done_wr_n   <= 1'b1;
            state_wr    <= ST_WR_DONE;
        end

        ST_WR_DONE: begin
            fifo_wr_n   <= 1'b1;
            fifo_oe_n   <= 1'b1;
            data_wr     <= data_wr;
            ready_wr_n  <= 1'b1;
            done_wr_n   <= 1'b0;
            state_wr    <= ST_WR_IDLE;
        end
        endcase
    end // end of if(!rst)-else
end // end of always

endmodule
