
`timescale 1ns / 1ps

module UART_Control_Unit (
    input clk,
    input rst,
    input rx_pin_in,
    input rx_pin_H2L,
    output reg rx_band_sig,
    input rx_clk_bps,
    output reg [15:0] out_data,
    output reg rx_done_sig

);

   localparam [2:0] IDLE = 3'b000, BEGIN = 3'b001, DATA=3'b010, END = 3'b011, BFREE = 3'b100 ,FINISH = 3'b101;
    reg [4:0] pos;
            
    reg [7:0] rx_data;
    reg [2:0] data_bit_count; 
    reg [1:0] count;
    reg [15:0] out_data1;

    always @(posedge clk or posedge rst)
        if (rst) begin
            rx_band_sig <= 1'b0;
            rx_data <= 8'd0;
            pos <= IDLE;
            data_bit_count<=3'd0;
            rx_done_sig <= 1'b0;
            count <= 2'd0;
        end else begin
            case (pos)
                IDLE:
                    if (rx_pin_H2L) begin
                        rx_done_sig <= 1'b0;
                        rx_band_sig <= 1'b1;
                        pos <= BEGIN;
                        rx_data <= 8'd0;
                        data_bit_count<=3'd0;
                    end
                BEGIN:
                    if (rx_clk_bps) begin
                        if (rx_pin_in == 1'b0) begin
                            pos <= DATA;
                        end else begin
                            rx_band_sig <= 1'b0;
                            pos <= IDLE;
                        end
                    end
                DATA: begin
            if (rx_clk_bps) begin
                rx_data[data_bit_count] <= rx_pin_in;
                if (data_bit_count == 3'd7) begin
                    pos <= END;
                end else begin
                    data_bit_count <= data_bit_count + 1'b1;
                end
            end
        end
                END:
                    if (rx_clk_bps) begin
                        rx_band_sig <= 1'b0;
                        pos <= BFREE;                     
                      if (count == 2'd0) begin
                        out_data1 <= {rx_data,out_data1[7:0]};
                      end
                      else if (count == 2'd1) begin
                        out_data1 <= {out_data1[15:8],rx_data};
                      end
                    end
                BFREE:
                    begin
                        if (out_data1[15:8] != 8'h52 && count == 2'd0 ) begin
                                rx_done_sig <= 1'b0;
                                pos <= IDLE;
                                count <= 2'd0;
                        end
                        else  begin
                                rx_done_sig <= 1'b0;
                                pos <= FINISH;
                                count <= count + 2'd1;
                        end
                    end
                FINISH:
                    begin
                        if (count == 2'd2) begin
                            out_data <= out_data1;
                            count <= 2'd0;
                            rx_done_sig <= 1'b1;
                            out_data1 <= 16'd0;
                        end
                        pos <= IDLE;
                    end
            endcase
        end

endmodule