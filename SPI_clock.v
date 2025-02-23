module SPI_clock (
    input clk,  
    input rst,    
    input spi_sig,       
    output reg spclk        
);

    parameter SYS_RATE = 125000000; 
    parameter BAND_RATE = 1000000; 
    parameter CNT_BAND = 125; 
    parameter HALF_CNT_BAND = 62;    

    reg [31:0] cnt_bps; 


    always @( posedge clk or posedge rst )
        if( rst )
        begin
            cnt_bps <= HALF_CNT_BAND;
            spclk <= 1'b0;
        end
        else if( !spi_sig )
        begin
            cnt_bps <= HALF_CNT_BAND;
            spclk <= 1'b0;
        end
        else if( cnt_bps == CNT_BAND )
        begin
            cnt_bps <= 31'd0;
            spclk <= 1'b1;
        end
        else
        begin
            cnt_bps <= cnt_bps + 1'b1;
            spclk <= 1'b0;
        end

    
endmodule