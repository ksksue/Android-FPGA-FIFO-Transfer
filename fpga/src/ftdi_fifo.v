/*
 * ftdi fifo driver tester
 *
 * read  test : n loop read  from 0x00 to 0xFF. (n = READ_LOOP_COUNT)
 * write test : n loop write from 0x00 to 0xFF. (n = WRITE_LOOP_COUNT)
 *
 * run read test -> O.K. -> run write test
 *
 * if rd_ctrl_state == ST_RDCTRL_VERIFY_NG then the read test is NG.
 * if wr_ctrl_state == ST_WRCTRL_VERIFY_NG then the write test is NG.
 */

/*
 * Copyright (C) 2012 @ksksue
 * Licensed under the Apache License, Version 2.0
 * http://www.apache.org/licenses/LICENSE-2.0
 */


//////////////////////////////////////////////////////////////////////////////
// includes
//////////////////////////////////////////////////////////////////////////////
`include "timescale.v"

//////////////////////////////////////////////////////////////////////////////
// module and I/O ports
//////////////////////////////////////////////////////////////////////////////
module ftdi_fifo(
    // Connect to FTDI FIFO Module
    input           iFIFO_RXF_n,    // Read from FIFO
    output          oFIFO_RD_n,     // Read Enable
    input   [7:0]   iFIFO_DATA,     // Read Data
    
    input           iFIFO_TXE_n,    // Write to FIFO
    output          oFIFO_WR_n,     // Write Enable
    output  [7:0]   oFIFO_DATA,     // Write Data
    output          oFIFO_OE_n,     // Output Enable for Bi-direction Bus
    
    output          oRD_VERIFY_NG,  // Verify NG then 1'b1

    // Connect to System Signals
    input   clk,                    // System Clock 50MHz(20ns)
    input   rst                     // System Reset
);

//////////////////////////////////////////////////////////////////////////////
// parameter
//////////////////////////////////////////////////////////////////////////////
parameter   READ_LOOP_COUNT     = 1;
parameter   WRITE_LOOP_COUNT    = 1000;

parameter   ST_RDCTRL_IDLE          = 3'b000,
            ST_RDCTRL_LOOP          = 3'b001,
            ST_RDCTRL_VERIFY_LOOP   = 3'b010,
            ST_RDCTRL_DATA_WAIT     = 3'b011,
            ST_RDCTRL_VERIFY_DATA   = 3'b100,
            ST_RDCTRL_VERIFY_NG     = 3'b101,
            ST_RDCTRL_DONE          = 3'b111;
            
parameter   ST_WRCTRL_IDLE          = 3'b000,
            ST_WRCTRL_LOOP          = 3'b001,
            ST_WRCTRL_VERIFY_LOOP   = 3'b010,
            ST_WRCTRL_DATA_WAIT     = 3'b011,
            ST_WRCTRL_DONE          = 3'b111;

//////////////////////////////////////////////////////////////////////////////
// reg and wire
//////////////////////////////////////////////////////////////////////////////

// read inner ctrl signal
reg         rd_act_n;           // Avtivate read sequence
wire        rd_done_n;          // Done read sequence
wire        rd_ready_n;         // Ready read sequence
reg  [7:0]  rd_data;            // Read data
wire [7:0]  rd_data_from_fifo;  // Read data from FIFO

// read fifo ctrl signal
wire        fifo_rxf_n;         // RXF signal from FIFO
wire        fifo_rd_n;          // RD signal to FIFO
wire [7:0]  fifo_rd_data;       // Data from FIFO

// write inner ctrl signal
reg         wr_act_n;           // Activate write sequence
wire        wr_done_n;          // Done write sequence
wire        wr_ready_n;         // Ready write sequence
wire [7:0]  wr_data;            // Write data

// write fifo ctrl signal
wire        fifo_txe_n;         // TXE signal from FIFO
wire        fifo_wr_n;          // WR signal to FIFO
wire [7:0]  fifo_wr_data;       // Data to FIFO
wire        fifo_oe_n;          // Output Enable for Bi-direction Bus

// used in state machine
reg  [2:0]  rd_ctrl_state;
reg         rd_loop_count;
reg  [31:0] rd_loop_counter;
reg         rd_verify_loop_count;
reg  [7:0]  rd_verify_loop_counter;

reg  [2:0]  wr_ctrl_state;
reg         wr_loop_count;
reg  [31:0] wr_loop_counter;
reg         wr_verify_loop_count;
reg  [7:0]  wr_verify_loop_counter;

//////////////////////////////////////////////////////////////////////////////
// RTL instance
//////////////////////////////////////////////////////////////////////////////
ftdi_fifo_rd ftdi_fifo_rd(
    // Connect to Inner Logic
    .iACT_RD_n(rd_act_n),
    .oDONE_RD_n(rd_done_n),
    .oREADY_RD_n(rd_ready_n),
    .oRD_DATA(rd_data_from_fifo),

    // Connect to FTDI FIFO Module
    .iFIFO_RXF_n(fifo_rxf_n),
    .oFIFO_RD_n(fifo_rd_n),
    .iFIFO_DATA(fifo_rd_data),

    // Connect to System Signals
    .clk(clk),
    .rst(rst)
);

ftdi_fifo_wr ftdi_fifo_wr(
    // Connect to Inner Logic
    .iACT_WR_n(wr_act_n),
    .oDONE_WR_n(wr_done_n),
    .oREADY_WR_n(wr_ready_n),
    .iWR_DATA(wr_data),
    
    // Connect to FTDI FIFO Module
    .iFIFO_TXE_n(fifo_txe_n),
    .oFIFO_WR_n(fifo_wr_n),
    .oFIFO_DATA(fifo_wr_data),
    .oFIFO_OE_n(fifo_oe_n),
    
    // Connect to System Signals
    .clk(clk),
    .rst(rst)
    );
    
//////////////////////////////////////////////////////////////////////////////
// RTL
//////////////////////////////////////////////////////////////////////////////


assign fifo_rxf_n   = iFIFO_RXF_n;
assign oFIFO_RD_n   = fifo_rd_n;
assign fifo_rd_data = iFIFO_DATA;

assign fifo_txe_n   = iFIFO_TXE_n;
assign oFIFO_WR_n   = fifo_wr_n;
assign oFIFO_DATA   = fifo_wr_data;
assign wr_data      = wr_verify_loop_counter;
assign oFIFO_OE_n   = fifo_oe_n;

assign oRD_VERIFY_NG = (rd_ctrl_state == ST_RDCTRL_VERIFY_NG);

// read loop counter
always@(posedge clk or negedge rst)
begin
    if(!rst)begin
        rd_loop_counter <= 0;
    end else begin
        if(rd_loop_count == 1'b0) begin
            rd_loop_counter <= rd_loop_counter + 1;
        end else begin
            rd_loop_counter <= rd_loop_counter;
        end
    end
end

// read verify loop counter
always@(posedge clk or negedge rst)
begin
    if(!rst)begin
        rd_verify_loop_counter <= 0;
    end else begin
        if(rd_verify_loop_count == 1'b0) begin
            rd_verify_loop_counter <= rd_verify_loop_counter + 1;
        end else begin
            rd_verify_loop_counter <= rd_verify_loop_counter;
        end
    end
end

// write loop counter
always@(posedge clk or negedge rst)
begin
    if(!rst)begin
        wr_loop_counter <= 0;
    end else begin
        if(wr_loop_count == 1'b0) begin
            wr_loop_counter <= wr_loop_counter + 1;
        end else begin
            wr_loop_counter <= wr_loop_counter;
        end
    end
end

// write verify loop counter
always@(posedge clk or negedge rst)
begin
    if(!rst)begin
        wr_verify_loop_counter <= 0;
    end else begin
        if(wr_verify_loop_count == 1'b0) begin
            wr_verify_loop_counter <= wr_verify_loop_counter + 1;
        end else begin
            wr_verify_loop_counter <= wr_verify_loop_counter;
        end
    end
end


// read loop and verify data state machine

always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        rd_act_n                <= 1'b1;
        rd_data                 <= 0;
        rd_loop_count           <= 1'b1;
        rd_verify_loop_count    <= 1'b1;
        rd_ctrl_state           <= ST_RDCTRL_IDLE;
    end else begin
        case(rd_ctrl_state)
        
        ST_RDCTRL_IDLE: begin
            rd_act_n                <= 1'b1;
            rd_data                 <= 0;
            rd_loop_count           <= 1'b1;
            rd_verify_loop_count    <= 1'b1;
            rd_ctrl_state           <= ST_RDCTRL_LOOP;
        end
        
        // loop count
        ST_RDCTRL_LOOP: begin
            rd_act_n                <= 1'b1;
            rd_data                 <= rd_data;
            rd_loop_count           <= 1'b0;
            rd_verify_loop_count    <= 1'b1;
            if(rd_loop_counter == READ_LOOP_COUNT) begin
                rd_ctrl_state           <= ST_RDCTRL_DONE;
            end else begin
                rd_ctrl_state           <= ST_RDCTRL_VERIFY_LOOP;
            end
        end
        
        // verify data loop count 0x00->0xFF
        ST_RDCTRL_VERIFY_LOOP: begin
            rd_act_n                <= 1'b0;
            rd_data                 <= rd_data;
            rd_loop_count           <= 1'b1;
            rd_verify_loop_count    <= 1'b0;
            if(rd_verify_loop_counter == 8'hFF) begin
                rd_ctrl_state   <= ST_RDCTRL_LOOP;
            end else begin
                rd_ctrl_state   <= ST_RDCTRL_DATA_WAIT;
            end
        end

        // wait done signal        
        ST_RDCTRL_DATA_WAIT: begin
            rd_act_n                <= 1'b1;
            rd_data                 <= rd_data_from_fifo;
            rd_loop_count           <= 1'b1;
            rd_verify_loop_count    <= 1'b1; 
            if(rd_done_n == 1'b0) begin
                rd_ctrl_state   <= ST_RDCTRL_VERIFY_DATA;
            end else begin
                rd_ctrl_state   <= ST_RDCTRL_DATA_WAIT;
            end
        end
        
        // verify
        ST_RDCTRL_VERIFY_DATA: begin
            rd_act_n                <= 1'b1;
            rd_data                 <= rd_data;
            rd_loop_count           <= 1'b1;
            rd_verify_loop_count    <= 1'b1;
            if(rd_data == (rd_verify_loop_counter-1)) begin
                rd_ctrl_state   <= ST_RDCTRL_VERIFY_LOOP;
            end else begin
                rd_ctrl_state   <= ST_RDCTRL_VERIFY_NG;
            end
        end
        
        // do nothing
        ST_RDCTRL_VERIFY_NG: begin
            rd_act_n                <= rd_act_n;
            rd_data                 <= rd_data;
            rd_loop_count           <= rd_loop_count;
            rd_verify_loop_count    <= rd_verify_loop_count;
            rd_ctrl_state           <= ST_RDCTRL_VERIFY_NG;
        end
        
        // do nothing
        ST_RDCTRL_DONE: begin
            rd_act_n                <= rd_act_n;
            rd_data                 <= rd_data;
            rd_loop_count           <= rd_loop_count;
            rd_verify_loop_count    <= rd_verify_loop_count;
            rd_ctrl_state           <= ST_RDCTRL_DONE;
        end
        
        endcase
    end
end

// write loop and verify data state machine
always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        wr_act_n                <= 1'b1;
        wr_loop_count           <= 1'b1;
        wr_verify_loop_count    <= 1'b1;
        wr_ctrl_state           <= ST_WRCTRL_IDLE;
    end else begin
        case(wr_ctrl_state)
        
        ST_WRCTRL_IDLE: begin
            wr_act_n                <= 1'b1;
            wr_loop_count           <= 1'b1;
            wr_verify_loop_count    <= 1'b1;
            if(rd_ctrl_state == ST_RDCTRL_DONE) begin
                wr_ctrl_state           <= ST_WRCTRL_LOOP;
            end else begin
                wr_ctrl_state           <= ST_WRCTRL_IDLE;
            end
        end
        
        // loop count
        ST_WRCTRL_LOOP: begin
            wr_act_n                <= 1'b1;
            wr_loop_count           <= 1'b0;
            wr_verify_loop_count    <= 1'b1;
            if(wr_loop_counter == WRITE_LOOP_COUNT) begin
                wr_ctrl_state           <= ST_WRCTRL_DONE;
            end else begin
                wr_ctrl_state           <= ST_WRCTRL_VERIFY_LOOP;
            end
        end
        
        // verify data loop count 0x00->0xFF
        ST_WRCTRL_VERIFY_LOOP: begin
            wr_act_n                <= 1'b0;
            wr_loop_count           <= 1'b1;
            wr_verify_loop_count    <= 1'b0;
            if(wr_verify_loop_counter == 8'hFF) begin
                wr_ctrl_state   <= ST_WRCTRL_LOOP;
            end else begin
                wr_ctrl_state   <= ST_WRCTRL_DATA_WAIT;
            end
        end

        // wait done signal        
        ST_WRCTRL_DATA_WAIT: begin
            wr_act_n                <= 1'b1;
            wr_loop_count           <= 1'b1;
            wr_verify_loop_count    <= 1'b1; 
            if(wr_done_n == 1'b0) begin
                wr_ctrl_state   <= ST_WRCTRL_VERIFY_LOOP;
            end else begin
                wr_ctrl_state   <= ST_WRCTRL_DATA_WAIT;
            end
        end
         
        // do nothing
        ST_WRCTRL_DONE: begin
            wr_act_n                <= wr_act_n;
            wr_loop_count           <= wr_loop_count;
            wr_verify_loop_count    <= wr_verify_loop_count;
            wr_ctrl_state           <= ST_WRCTRL_DONE;
        end
        
        endcase
    end
end

endmodule
