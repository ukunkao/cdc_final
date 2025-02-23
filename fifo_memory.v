
module fifo_memory (
    input wire [7:0] write_data,
    input wire [3:0] write_addr,
    input wire write_enable,
    input wire write_clk,
    input wire write_rst_n,
    input wire [3:0] read_addr,
    input wire read_enable,
    input wire read_clk,
    input wire read_rst_n,
    output reg [7:0] read_data
);


    reg [7:0] fifo_data[0:7];
    reg [7:0] fifo_data_next[0:7];
    reg [7:0] read_data_comb;

    integer i;


    always @(posedge write_clk or posedge write_rst_n) begin
        if (write_rst_n) begin
            for (i = 0; i < 8; i = i + 1) begin
                fifo_data[i] <= 8'h00;
            end
        end else begin
            for (i = 0; i < 8; i = i + 1) begin
                fifo_data[i] <= fifo_data_next[i];
            end
        end
    end


    always @(posedge read_clk or posedge read_rst_n) begin
        if (read_rst_n) begin
            read_data <= 8'h00;
        end else if (read_enable) begin
            read_data <= read_data_comb;
        end
    end


    always @(*) begin

        for (i = 0; i <8; i = i + 1) begin
            fifo_data_next[i] = fifo_data[i];
        end
        

        if (write_enable) begin
            fifo_data_next[write_addr[2:0]] = write_data;
        end


        if (read_enable) begin
            read_data_comb = fifo_data[read_addr[2:0]];
        end
         else begin
            read_data_comb = read_data;
        end
    end

endmodule



