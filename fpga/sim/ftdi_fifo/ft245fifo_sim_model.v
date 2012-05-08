/*
 * Simple FT245 FIFO simulation model
 *
 * It's timing model.
 *
 * PAT_NUM : size of buffer (default : 256)
 * fifo_data_rd[0:PAT_NUM-1] = {0, 1, 2, ..., PAT_NUM-1}
 * fifo_data_wr[0:PAT_NUM-1] = no data
 *
 *                    --< fifo_data_rd
 * <--[ioFIFO_DATA]-->|
 *                    --> fifo_data_wr
 *
 * reference to FT245R Datasheet
 * http://www.ftdichip.com/Products/ICs/FT245R.htm
 */

/*
 * Copyright (C) 2012 @ksksue
 * Licensed under the Apache License, Version 2.0
 * http://www.apache.org/licenses/LICENSE-2.0
 */
  
//////////////////////////////////////////////////////////////////////////////
// module and I/O ports
//////////////////////////////////////////////////////////////////////////////
module ft245fifo_sim_model(
        output      oFIFO_RXF_n,    // RXF
        input       iFIFO_RD_n,     // RD
        output      oFIFO_TXE_n,    // TXE
        input       iFIFO_WR_n,     // WR
        inout [7:0] ioFIFO_DATA     // Data bus
);

//////////////////////////////////////////////////////////////////////////////
// parameter
//////////////////////////////////////////////////////////////////////////////
parameter PAT_NUM = 256;

//////////////////////////////////////////////////////////////////////////////
// reg and wire
//////////////////////////////////////////////////////////////////////////////
reg[7:0] fifo_data_rd[0:PAT_NUM-1];
reg[7:0] fifo_data_wr[0:PAT_NUM-1];

//////////////////////////////////////////////////////////////////////////////
// read buffer
//////////////////////////////////////////////////////////////////////////////

//$readmemb("mem.pat",fifo_data);
integer i;
initial begin
for (i=0;i<PAT_NUM;i=i+1) begin
    fifo_data_rd[i] = i;
end
end
//////////////////////////////////////////////////////////////////////////////
// simulator model
//////////////////////////////////////////////////////////////////////////////
reg [7:0]   pfifo_rd;
reg [7:0]   pfifo_wr;
reg         fifo_rxf_n;
reg         fifo_txe_n;

assign oFIFO_RXF_n = fifo_rxf_n;
assign oFIFO_TXE_n = fifo_txe_n;

assign ioFIFO_DATA = iFIFO_RD_n? 8'hZZ : fifo_data_rd[pfifo_rd-1];

initial begin
    pfifo_rd    <= 0;
    fifo_rxf_n  <= 0;
end
always@(posedge iFIFO_RD_n) begin
    pfifo_rd    <= pfifo_rd + 1;
end

initial begin
    pfifo_wr    <= 0;
    fifo_txe_n  <= 0;
end
always@(negedge iFIFO_WR_n) begin
    pfifo_wr                <= pfifo_wr + 1;
    fifo_data_wr[pfifo_wr]  <= ioFIFO_DATA;
end


endmodule
