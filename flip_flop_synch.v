
module flip_flop_synch(
    input wire a_clk,           
    input wire a_rst_n,         
    input wire b_clk,           
    input wire b_rst_n,        
    input wire [3:0] async_data,   
    output reg [3:0] sync_data     
);


    reg [3:0] stage1;
    reg [3:0] stage2;

    always @(posedge a_clk or posedge a_rst_n) begin
        if (a_rst_n) begin
            stage1 <= 4'b0000;
        end else begin
            stage1 <= async_data;
        end
    end


    always @(posedge b_clk or posedge b_rst_n) begin
        if (b_rst_n) begin
            stage2 <= 4'b0000;
            sync_data <= 4'b0000;
        end else begin
            stage2 <= stage1;  
            sync_data <= stage2;   
        end
    end
endmodule


