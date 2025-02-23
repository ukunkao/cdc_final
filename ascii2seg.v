module ASCII_to_7seg(
    input  wire       rst,     
    input  wire [7:0] ASCII,
    output reg  [7:0] seg7_out   
);
 
    
    always @(*) begin
        if(rst) begin
            seg7_out = 8'h00; 
        end
        else begin
            case(ASCII)
                8'b0000_0000: seg7_out = 8'b00000011;
                8'b0000_0001: seg7_out = 8'b10011111;
                8'b0000_0010: seg7_out = 8'b00100101;
                8'b0000_0011: seg7_out = 8'b00001101;
                8'b0000_0100: seg7_out = 8'b10011001;
                8'b0000_0101: seg7_out = 8'b01001001;
                8'b0000_0110: seg7_out = 8'b01000001;
                8'b0000_0111: seg7_out = 8'b00011111;
                8'b0000_1000: seg7_out = 8'b00000001;
                8'b0000_1001: seg7_out = 8'b00001001;
                8'b0000_1010: seg7_out = 8'b00010001;
                8'b0000_1011: seg7_out = 8'b11000001;
                8'b0000_1100: seg7_out = 8'b11100101;
                8'b0000_1101: seg7_out = 8'b10000101;
                8'b0000_1110: seg7_out = 8'b01100001;
                8'b0000_1111: seg7_out = 8'b01110001;
                default: seg7_out = 8'b01100001;
            endcase
        end
    end
endmodule