`timescale 1ns / 1 ps
`define SYS_RATE 125000000
`define BAND_RATE 9600
`define SYS_TIME 8
`define TIME 104166
module rx_tb;    
	  reg   clk;	
	  reg   rst;	
	  reg	uart_rx;
	  wire [7:0]  seg7;
	  reg miso;
	  wire cs;
	  wire mosi;
	  wire sclk;
	integer i;
	reg [7:0]data_test=8'd0;
  initial begin
			//$dumpfile("test.vcd");
			//$dumpvars;
		end 
    UART_Data_Processor u_rx_top(
    .clk(clk),
    .rst(rst), 
    .rx_pin_in(uart_rx), 
    .MISO(miso),
	.CS_n(cs),
	.MOSI(mosi),
	.SPI_CLK(sclk),
    .seg7(seg7)
    );	
    
    initial begin   
    clk=0;
    miso = 1'b0;
    rst=1; 
    
    //$monitor("dataout = %8b, cs = %b , sclk = %b  ", dataout,cs, sclk);
        data_test=8'h30;
       
                    
        #(`TIME) rst=0;uart_rx=1;
        #(`TIME) uart_rx=0;
        
       #(`TIME) uart_rx = 1'b0;
        #(`TIME) uart_rx = 1'b1;
        #(`TIME) uart_rx = 1'b0;
        #(`TIME) uart_rx = 1'b0;
        #(`TIME) uart_rx = 1'b1;
        #(`TIME) uart_rx = 1'b0;
        #(`TIME) uart_rx = 1'b1;
        #(`TIME) uart_rx = 1'b0;
        #(`TIME) uart_rx=1;
        #(`TIME) uart_rx=0;
       
       
       
       
        #(`TIME) uart_rx = data_test[0];
        #(`TIME) uart_rx = data_test[1];
        #(`TIME) uart_rx = data_test[2];
        #(`TIME) uart_rx = data_test[3];

        #(`TIME) uart_rx = data_test[4];
        #(`TIME) uart_rx = data_test[5];
        #(`TIME) uart_rx = data_test[6];
        #(`TIME) uart_rx = data_test[7];
        data_test=data_test+1;

          #512; 
        #189340; // Allow enough time for SPI Master to enter SEND_CMD state
        miso = 1'b0; // Simulate received bit 1
        #992;       // Wait for 1MHz clock cycle (1�gs)
        miso = 1'b0; // Simulate received bit 0
        #992;       // Wait for next cycle
        miso = 1'b1; // Continue simulating received bits
        #992;
        miso = 1'b1;
        #992;
        miso = 1'b0;
        #992;
        miso = 1'b0;
        #992;
        miso = 1'b0;
        #992;
        miso = 1'b0; // Simulate 8th bit
        #992;
        miso = 1'b0; // Simulate 8th bit
        #(`TIME) uart_rx=1;
 #189340;
     #189340;
      #189340;
       #189340;
    $finish;
    end
     
    always #(4) clk<=~clk;

endmodule

