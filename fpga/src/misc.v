/*
 * misc. logic
 */

/*
 * Copyright (C) 2012 @ksksue
 * Licensed under the Apache License, Version 2.0
 * http://www.apache.org/licenses/LICENSE-2.0
 */

/*
 * parametalized one buffer
 *
USAGE : 
param_one_buf #(.DATA_WIDTH(32))
 param_one_buf(
        .iDATA(indata),
        .oDATA(outdata),
        .clk(clk));
 */
module param_one_buf #(parameter DATA_WIDTH = 8)
(
    input  [DATA_WIDTH-1:0] iDATA,
    output [DATA_WIDTH-1:0] oDATA,

    input clk
);

reg [DATA_WIDTH-1:0]    in_data;

assign oDATA    = in_data;

always@(posedge clk) begin
    in_data     <= iDATA;
end

endmodule


/*
 * parametalized inout buffer
 *
USAGE : 
param_inout_buf #(.DATA_WIDTH(32))
 iobuf( .ioDATA(iodata),
        .iOE(oe),
        .iDATA(indata),
        .oDATA(outdata),
        .clk(clk));
 */
module param_inout_buf #(parameter DATA_WIDTH = 8)
(
    inout  [DATA_WIDTH-1:0] ioDATA,

    input                   iOE_n,
    input  [DATA_WIDTH-1:0] oDATA,
    output [DATA_WIDTH-1:0] iDATA,

    input clk
);

reg                     oe_n;
reg [DATA_WIDTH-1:0]    in_data;
reg [DATA_WIDTH-1:0]    out_data;

assign ioDATA = (oe_n)? {DATA_WIDTH{1'bZ}} : out_data;
assign iDATA = in_data;

always@(posedge clk) begin
    oe_n        <= iOE_n;
    out_data    <= oDATA;
    in_data     <= ioDATA;
end

endmodule
