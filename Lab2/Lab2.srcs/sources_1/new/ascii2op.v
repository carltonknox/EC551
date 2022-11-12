module ascii2op(input ascii, output reg out);
always @(ascii) begin
    case (ascii)
    94: out = 2'b11; // ^
    43: out = 2'b00; // +
    45: out = 2'b01; // -
    35: out = 2'b10; // ++
    endcase
end
endmodule