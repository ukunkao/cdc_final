
module read_control_logic (
    input wire read_clk,
    input wire read_rst_n,
    input wire read_enable_in,
    input wire [3:0] write_addr_gray_sync,   
    output reg [3:0] read_addr_gray,         
    output reg [3:0] read_addr,             
    output reg read_enable_out,
    output reg fifo_empty
);


    reg [3:0] read_ptr_next; 
    reg [3:0] write_addr;
    reg empty_next;


    always @(posedge read_clk or posedge read_rst_n) begin
        if (read_rst_n) begin
            read_addr <= 4'b0000;
            fifo_empty <= 1'b1;
        end else begin
            read_addr <= read_ptr_next;
            fifo_empty <= empty_next;
        end
    end

    always @(*) begin

        read_ptr_next = read_addr;
        write_addr[3] = write_addr_gray_sync[3];  
        write_addr[2] = write_addr_gray_sync[3] ^ write_addr_gray_sync[2];
        write_addr[1] = write_addr_gray_sync[3] ^ write_addr_gray_sync[2] ^ write_addr_gray_sync[1];
        write_addr[0] = write_addr_gray_sync[3] ^ write_addr_gray_sync[2] ^ write_addr_gray_sync[1] ^ write_addr_gray_sync[0];



        read_addr_gray = {read_addr[3], read_addr[3] ^ read_addr[2], 
                               read_addr[2] ^ read_addr[1], read_addr[1] ^ read_addr[0]};


 
        if (read_enable_in == 1'b1 && fifo_empty == 1'b0) begin
            read_ptr_next = read_addr + 1'b1;  
            read_enable_out = 1'b1;  
        end else begin
            read_enable_out = 1'b0;  
        end


        if (write_addr == read_ptr_next) begin
            empty_next = 1'b1;  
        end else begin
            empty_next = 1'b0;
        end
    end

endmodule








