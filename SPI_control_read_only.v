//====================================================================
//SPI_control_read_only
//    0x03  (CMD + ADDR + 1 Byte DATA)
//====================================================================
module SPI_control_read_only(
    input  wire        sys_clk,
    input  wire        sys_rst_n,    
    input  wire        start_read,
    input  wire [7:0]  addr_offset,          
    input  wire        spclk,

    input  wire        MISO,
    output reg         MOSI,
    output wire        SPI_CLK,
    output reg         CS_n,

    output reg         spi_sig,
    output reg  [7:0]  data_out,
    output reg         read_enable

);

    localparam S_IDLE = 3'd0;
    localparam S_CS   = 3'd1;
    localparam S_CMD  = 3'd2;  
    localparam S_ADDR = 3'd3;  
    localparam S_READ = 3'd4;  
    localparam S_DONE = 3'd5;

    reg [2:0]  current_state, next_state;
    reg [5:0]  bit_cnt;
    reg [7:0]  read_reg;  
    reg [23:0]  addr;

    localparam [7:0] READ_CMD = 8'h03;

   

    always @(*) begin
    case (addr_offset)
     8'b0011_0000: addr=24'h000000;
     8'b0011_0001: addr=24'h000001;
     8'b0011_0010: addr=24'h000002;
     8'b0011_0011: addr=24'h000003;
     8'b0011_0100: addr=24'h000004;
     8'b0011_0101: addr=24'h000005;
     8'b0011_0110: addr=24'h000006;
     8'b0011_0111: addr=24'h000007;
     8'b0011_1000: addr=24'h000008;
     8'b0011_1001: addr=24'h000009;
     8'b0100_0001: addr=24'h00000A;
     8'b0100_0010: addr=24'h00000B;
     8'b0100_0011: addr=24'h00000C;
     8'b0100_0100: addr=24'h00000D;
     8'b0100_0101: addr=24'h00000E;
     8'b0100_0110: addr=24'h00000F;
     default: addr= 24'h00000E;
    endcase
   end

   

     always @(negedge spclk or posedge sys_rst_n) begin
        if(sys_rst_n) begin
            current_state <= S_IDLE;
            MOSI <= 1'b0;
            read_reg <= 8'd0;
            data_out   <= 8'd0;
            bit_cnt <= 6'd0;
            spi_sig <= 1'b1;
            CS_n <= 1'b1;
            read_enable <= 1'b0;
        end
        else begin
            case(current_state)
                S_IDLE:  begin
                    if (start_read == 1'b1) begin
                        current_state <= S_CS;
                    end
                end
                S_CS : begin
                    CS_n <= 1'b0;
                    current_state <= S_CMD;
                    MOSI <= READ_CMD[7];
                    read_enable <= 1'b1;
                end
                S_CMD:  begin
                    MOSI <= READ_CMD[6 - bit_cnt];
                        if (bit_cnt == 6'd6) begin
                            current_state <= S_ADDR;
                            bit_cnt <= 6'd0;
                            read_enable <= 1'b0;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                end
                S_ADDR:  begin
                        MOSI <= addr[23 - bit_cnt];
                            if (bit_cnt == 6'd23) begin
                            current_state <= S_READ;
                            bit_cnt <= 6'd0;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                end
                S_READ:   begin
                    MOSI <= 1'b0;
                      if (bit_cnt > 6'd0) begin
                        read_reg[8 - bit_cnt] <= MISO;
                        if (bit_cnt == 6'd8) begin
                                current_state <= S_DONE;
                                bit_cnt <= 6'd0;
                                CS_n <= 1'b1;
                            end 
                        else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end
                    else begin
                                bit_cnt <= bit_cnt + 1'b1;
                    end
                end
                S_DONE:  begin
                    data_out <= read_reg;
                    current_state <= S_IDLE;
                end
                default: begin
                     MOSI <= 1'b0;
                     CS_n <= 1'b1;
                end
            endcase
        end
    end

    

    




    assign SPI_CLK = spclk;
endmodule
