/*
 * FT245R FIFO mode read sequencer
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
 * 0.i:_|~|_|~|_|~|_|~|_|~|_|~|_|~|_|~|_|~|_|_|~|_|_|
 *
 * 1.o:_____________|~~~~~~~~~~~~~~~~~~~~~~~|________
 *
 * 2.i:~~~~~|___|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *
 * 3.o:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|___|~~~~~~~~
 *
 * 4.o:==========================><==================
 *
 * 0.clk
 * 1.oREADY_RD_n
 * 2.iACT_RD_n
 * 3.oDONE_RD_n
 * 4.oRD_DATA
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
module ftdi_fifo_rd(
    // Connect to Inner Logic
    input           iACT_RD_n,      // Activate Read Sequence Signal
    output          oDONE_RD_n,     // Done Read Sequence Signal
    output          oREADY_RD_n,    // READY Read Sequence Signal
    output  [7:0]   oRD_DATA,       // Write Data

    // Connect to FTDI FIFO Module
    input           iFIFO_RXF_n,    // Read from FIFO
    output          oFIFO_RD_n,     // Read Enable
    input   [7:0]   iFIFO_DATA,     // Read Data

    // Connect to System Signals
    input   clk,                    // System Clock 50MHz(20ns)
    input   rst                     // System Reset
    );

//////////////////////////////////////////////////////////////////////////////
// reg and wire
//////////////////////////////////////////////////////////////////////////////
reg         fifo_rd_n;
reg         ready_rd_n;
reg         done_rd_n;
reg [3:0]   state_rd;
reg [7:0]   data_rd;

//////////////////////////////////////////////////////////////////////////////
// parameter
//////////////////////////////////////////////////////////////////////////////
parameter   ST_RD_IDLE          = 4'b0000,
            ST_RD_WAIT_RXF      = 4'b0001,
            ST_RD_NEG_RD        = 4'b0010,
            ST_RD_DATA_WAIT1    = 4'b0011,
            ST_RD_DATA_WAIT2    = 4'b0100,
            ST_RD_DATA_WAIT3    = 4'b0101,
            ST_RD_DATA_WAIT4    = 4'b0110,
            ST_RD_DATA_IN       = 4'b0111,
            ST_RD_POS_RD        = 4'b1000,
            ST_RD_PRE_CHARGE    = 4'b1001,
            ST_RD_DONE          = 4'b1010;

//////////////////////////////////////////////////////////////////////////////
// RTL
//////////////////////////////////////////////////////////////////////////////

assign oFIFO_RD_n   = fifo_rd_n;
assign oREADY_RD_n  = ready_rd_n;
assign oDONE_RD_n   = done_rd_n;
assign oRD_DATA     = data_rd;

// FSM for reading fifo
always@(posedge clk or negedge rst) begin
    if(!rst) begin
        fifo_rd_n   <= 1'b1;
        data_rd     <= 8'h00;
        ready_rd_n  <= 1'b1;
        done_rd_n   <= 1'b1;
        state_rd    <= ST_RD_IDLE;
    end
    else begin
        case(state_rd)
        ST_RD_IDLE: begin
            fifo_rd_n       <= 1'b1;
            data_rd         <= data_rd;
            ready_rd_n      <= 1'b0;
            done_rd_n       <= 1'b1;
            if(iACT_RD_n == 1'b0 && iFIFO_RXF_n == 1'b0) begin
                state_rd    <= ST_RD_NEG_RD;
            end else if(iACT_RD_n == 1'b0 && iFIFO_RXF_n == 1'b1) begin
                state_rd    <= ST_RD_WAIT_RXF;
            end else begin
                state_rd    <= ST_RD_IDLE;
            end
        end

        ST_RD_WAIT_RXF: begin
            fifo_rd_n       <= 1'b1;
            data_rd         <= data_rd;
            ready_rd_n      <= 1'b1;
            done_rd_n       <= 1'b1;
            if(iFIFO_RXF_n == 1'b0) begin
                state_rd    <= ST_RD_NEG_RD;
            end else begin
                state_rd    <= ST_RD_WAIT_RXF;
            end
        end
        
        ST_RD_NEG_RD: begin
            fifo_rd_n       <= 1'b0;
            data_rd         <= data_rd;
            ready_rd_n      <= 1'b1;
            done_rd_n       <= 1'b1;
            state_rd        <= ST_RD_DATA_WAIT1;
        end

        ST_RD_DATA_WAIT1: begin
            fifo_rd_n       <= 1'b0;
            data_rd         <= data_rd;
            ready_rd_n      <= 1'b1;
            done_rd_n       <= 1'b1;
            state_rd        <= ST_RD_DATA_WAIT2;
        end

        ST_RD_DATA_WAIT2: begin
            fifo_rd_n       <= 1'b0;
            data_rd         <= data_rd;
            ready_rd_n      <= 1'b1;
            done_rd_n       <= 1'b1;
            state_rd        <= ST_RD_DATA_WAIT3;
        end
        
        ST_RD_DATA_WAIT3: begin
            fifo_rd_n       <= 1'b0;
            data_rd         <= data_rd;
            ready_rd_n      <= 1'b1;
            done_rd_n       <= 1'b1;
            state_rd        <= ST_RD_DATA_WAIT4;
        end
        
        ST_RD_DATA_WAIT4: begin
            fifo_rd_n       <= 1'b0;
            data_rd         <= data_rd;
            ready_rd_n      <= 1'b1;
            done_rd_n       <= 1'b1;
            state_rd        <= ST_RD_DATA_IN;
        end

        ST_RD_DATA_IN: begin
            fifo_rd_n       <= 1'b0;
            data_rd         <= iFIFO_DATA;
            ready_rd_n      <= 1'b1;
            done_rd_n       <= 1'b1;
            state_rd        <= ST_RD_POS_RD;
        end

        ST_RD_POS_RD: begin
            fifo_rd_n       <= 1'b1;
            data_rd         <= data_rd;
            ready_rd_n      <= 1'b1;
            done_rd_n       <= 1'b1;
            state_rd        <= ST_RD_PRE_CHARGE;
        end

        ST_RD_PRE_CHARGE: begin
            fifo_rd_n       <= 1'b1;
            data_rd         <= data_rd;
            ready_rd_n      <= 1'b1;
            done_rd_n       <= 1'b1;
            state_rd        <= ST_RD_DONE;
        end

        ST_RD_DONE: begin
            fifo_rd_n       <= 1'b1;
            data_rd         <= data_rd;
            ready_rd_n      <= 1'b1;
            done_rd_n       <= 1'b0;
            state_rd        <= ST_RD_IDLE;
        end

        endcase
    end // end of if(!rst)-else
end // end of always


endmodule

