`timescale 1ns / 1ps
module Baud_Rate_Generator(
    input clk,
    input rst,
    input band_sig,
    output reg clk_bps
);

    parameter SYS_RATE = 125000000;
    parameter BAND_RATE = 9600;
    parameter CNT_BAND = SYS_RATE / BAND_RATE;
    parameter HALF_CNT_BAND = CNT_BAND / 2;

    reg [13:0] cnt_bps;
    always @( posedge clk or posedge rst )
        if( rst )
        begin
            cnt_bps <= HALF_CNT_BAND;
            clk_bps <= 1'b0;
        end
        else if( !band_sig )
        begin
            cnt_bps <= HALF_CNT_BAND;
            clk_bps <= 1'b0;
        end
        else if( cnt_bps == CNT_BAND )
        begin
            cnt_bps <= 14'd0;
            clk_bps <= 1'b1;
        end
        else
        begin
            cnt_bps <= cnt_bps + 1'b1;
            clk_bps <= 1'b0;
        end

endmodule