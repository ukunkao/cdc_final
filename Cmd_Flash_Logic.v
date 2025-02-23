`timescale 1ns / 1ps


module Cmd_Flash_Logic(

    input  wire       sys_clk,        
    input  wire       sys_rst_n,      
    
 
    input  wire       rx_done_sig,    
    input  wire [15:0] rx_data,        
    

    output reg         start_read,
    output reg  [7:0]  addr_offset,
    output reg         write_enable
);

    reg  [7:0] cmd_byte_1, cmd_byte_2;
    reg  [1:0] byte_count;  
    reg  [9:0] count;

  



    always @(posedge sys_clk or posedge sys_rst_n) begin
        if(sys_rst_n) begin
            byte_count        <= 2'd0;
            cmd_byte_1        <= 8'd0;
            cmd_byte_2        <= 8'd0;
            start_read        <= 1'd0;
            write_enable      <= 1'd0;
            count             <= 10'd0;
        end
        else begin
        if(rx_done_sig) 
        begin
                case(byte_count)
                    2'd0: begin
                        cmd_byte_1 <= rx_data[15:8]; 
                        byte_count <= 2'd1;
                    end
                    2'd1: begin
                        cmd_byte_2 <= rx_data[7:0];
                        byte_count <= 2'd2;
                        write_enable <= 1'd1;

                        if(cmd_byte_1 == 8'h52) begin  
                            if(cmd_byte_2 >= 8'h30 && cmd_byte_2 <= 8'h39) begin
                                addr_offset <= cmd_byte_2 ; 
                            end

                            else if(cmd_byte_2 >= 8'h41 && cmd_byte_2 <= 8'h46) begin
                                addr_offset <= cmd_byte_2 ; 
                            end
                            else begin

                                addr_offset <= 8'b0100_0101;
                            end
                        end

                    end
                    2'd2: begin
                        start_read <= 1'd1;
                        byte_count <= 2'd3;
                        if ( count == 10'd500 ) begin
                            write_enable <= 1'd0;
                            count      <= 10'd0;
                        end
                        else begin
                            count <= count + 1;
                            byte_count <= 2'd2;
                        end
                    end
                    2'd3: begin
                        start_read <= 1'd0;
                        if ( count == 10'd500 ) begin
                            count      <= 10'd0;
                            byte_count <= 2'd0;
                        end
                        else begin
                            count <= count + 1;
                            byte_count <= 2'd3;
                        end  
                    end
                    default: byte_count <= 2'd0;
                endcase
            end
        end
    end

    
endmodule
