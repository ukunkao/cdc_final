

module write_control_logic (
    input wire write_clk,
    input wire write_rst_n,
    input wire write_enable_in,
    input wire [3:0] read_addr_gray_sync,  
    output reg [3:0] write_addr_gray,       
    output reg [3:0] write_addr,            
    output reg write_enable_out,
    output reg fifo_full
);

   
    reg [3:0] read_addr;
    reg [3:0] write_ptr_next;
    reg full_next;

  
    always @(posedge write_clk or posedge write_rst_n) begin
        if (write_rst_n) begin
            write_addr <= 4'b0000;
            fifo_full <= 1'b0;
        end else begin
            write_addr <= write_ptr_next;
            fifo_full <= full_next;
        end
    end

    
    always @(*) begin
        
        write_ptr_next = write_addr;

         
        read_addr[3] = read_addr_gray_sync[3];  
        read_addr[2] = read_addr_gray_sync[3] ^ read_addr_gray_sync[2];
        read_addr[1] = read_addr_gray_sync[3] ^ read_addr_gray_sync[2] ^ read_addr_gray_sync[1];
        read_addr[0] = read_addr_gray_sync[3] ^ read_addr_gray_sync[2] ^ read_addr_gray_sync[1] ^ read_addr_gray_sync[0];


        
        write_addr_gray[3] = write_addr[3];                   
        write_addr_gray[2] = write_addr[3] ^ write_addr[2];     
        write_addr_gray[1] = write_addr[2] ^ write_addr[1];
        write_addr_gray[0] = write_addr[1] ^ write_addr[0];


      
        if (write_enable_in == 1'b1 && fifo_full == 1'b0) begin
            write_ptr_next = write_addr + 1'b1;  
            write_enable_out = 1'b1;  
        end else begin
            write_enable_out = 1'b0;  
        end

       
        if ((write_ptr_next[2:0] == read_addr[2:0]) && 
            (write_ptr_next[3] != read_addr[3])) begin
            full_next = 1'b1;  
        end else begin
            full_next = 1'b0;
        end
    end

endmodule








