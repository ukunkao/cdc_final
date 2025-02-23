
module UART_Data_Processor(
    input clk,
    input rst,
    //uart
    input rx_pin_in,
    //spi
    input  wire        MISO,
    output wire        MOSI,
    output wire        SPI_CLK,
    output wire        CS_n,
    
    output [7:0] seg7

);

    //==========================================================
    //  UART
    //==========================================================


    wire rx_pin_H2L;
    Edge_Detector rx_in_detect(
        .clk( clk ),
        .rst( rst ),
        .pin_in( rx_pin_in ),
        .sig_H2L( rx_pin_H2L )
    );

    wire rx_band_sig;
    wire clk_bps;
    Baud_Rate_Generator rx_baud_gen(
        .clk( clk ),
        .rst( rst ),
        .band_sig( rx_band_sig ),
        .clk_bps( clk_bps )
    );

    wire [15:0] rx_data;
    wire       rx_done_sig;
    UART_Control_Unit rx_control(
        .clk( clk ),
        .rst( rst ),
        .rx_pin_in( rx_pin_in ),
        .rx_pin_H2L( rx_pin_H2L ),
        .rx_band_sig( rx_band_sig ),
        .rx_clk_bps( clk_bps ),
        .out_data( rx_data ),
        .rx_done_sig( rx_done_sig )
    );


 
  
    wire       start_read;
    wire [7:0]addr_offset;        
    
    Cmd_Flash_Logic u_cmd_flash_logic (
        .sys_clk         ( clk        ),  
        .sys_rst_n       ( rst       ),  
        .rx_done_sig     ( rx_done_sig),
        .rx_data         ( rx_data    ),
        .start_read      ( start_read ),
        .addr_offset     ( addr_offset ) ,
        .write_enable    ( write_enable )
    );

    wire [7:0] data_out;
    wire       spi_sig;

    SPI_control_read_only u_spi_control (
                .sys_clk    ( clk ),
                .sys_rst_n  ( rst ), 
                .start_read ( start_read_spi ),
                .addr_offset( read_data ),
                .MISO       ( MISO ),
                .MOSI       ( MOSI ),
                .SPI_CLK    ( SPI_CLK ),
                .spclk      ( spclk ),
                .CS_n       ( CS_n ),
                .data_out   ( data_out  ),
                .spi_sig    (spi_sig),
                .read_enable(read_enable)
            );
    
    wire spclk;

    SPI_clock u_SPI_clock (
                .clk    ( clk ),
                .spi_sig ( spi_sig ),
                .rst  ( rst ), 
                .spclk ( spclk )
        );


    ASCII_to_7seg u_ASCII2seg7(
        .rst      ( rst ),  
        .ASCII    ( data_out ),
        .seg7_out ( seg7 )
    );
//-----------1bit double ff-----------
 wire start_read_spi;
 flip_flop_synch_1bit flip_flop_synch_1bit(
        .async_data(start_read),      
        .a_clk(clk),               
        .a_rst_n(rst),          
        .b_clk(spclk),            
        .b_rst_n(rst),        
        .sync_data(start_read_spi)  
    );

//-----------fifo---------------------

     wire write_enable;
     wire read_enable;
     wire [7:0] read_data;
     wire fifo_full;
     wire fifo_empty;


    wire write_enable_out;
    wire read_enable_out;
    wire [3:0] write_addr;
    wire [3:0] read_addr;
    wire [3:0] write_addr_gray;
    wire [3:0] read_addr_gray;
    wire [3:0] write_addr_gray_sync_1;
    wire [3:0] read_addr_gray_sync_1;

 
    fifo_memory mem(
        .write_data(addr_offset),
        .write_addr(write_addr),
        .write_enable(write_enable),
        .write_clk(clk),
        .write_rst_n(rst),
        .read_addr(read_addr),
        .read_enable(read_enable),
        .read_clk(spclk),
        .read_rst_n(rst),
        .read_data(read_data)
    );

    write_control_logic wctrl(
        .write_clk(write_clk),
        .write_rst_n(write_rst_n),
        .write_enable_in(write_enable),
        .read_addr_gray_sync(write_addr_gray_sync_1),
        .write_addr_gray(write_addr_gray),
        .write_addr(write_addr),
        .write_enable_out(write_enable_out),
        .fifo_full(fifo_full)
    );

    read_control_logic rctrl(
        .read_clk(read_clk),
        .read_rst_n(read_rst_n),
        .read_enable_in(read_enable),
        .write_addr_gray_sync(read_addr_gray_sync_1),
        .read_addr(read_addr),
        .read_addr_gray(read_addr_gray),
        .read_enable_out(read_enable_out),
        .fifo_empty(fifo_empty)
    );

    flip_flop_synch sync_write(
        .async_data(read_addr_gray),      
        .a_clk(read_clk),               
        .a_rst_n(read_rst_n),           
        .b_clk(write_clk),             
        .b_rst_n(write_rst_n),         
        .sync_data(write_addr_gray_sync_1)  
    );

    flip_flop_synch sync_read(
        .async_data(write_addr_gray),   
        .a_clk(write_clk),              
        .a_rst_n(write_rst_n),         
        .b_clk(read_clk),              
        .b_rst_n(read_rst_n),         
        .sync_data(read_addr_gray_sync_1)  
    );



endmodule
