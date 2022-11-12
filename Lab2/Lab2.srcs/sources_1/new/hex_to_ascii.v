`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2022 11:15:11 PM
// Design Name: 
// Module Name: ascii_to_hexdigit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hex_to_ascii(
    input [3:0] hexdigit,
    output reg [7:0] ascii
    );
    always@(*) begin
    case(hexdigit)
        0: ascii=8'h30;
        1: ascii=8'h31;
        2: ascii=8'h32;
        3: ascii=8'h33;
        4: ascii=8'h34;
        5: ascii=8'h35;
        6: ascii=8'h36;
        7: ascii=8'h37;
        8: ascii=8'h38;
        9: ascii=8'h39;
        10: ascii=8'h61;
        11: ascii=8'h62;
        12: ascii=8'h63;
        13: ascii=8'h64;
        14: ascii=8'h65;
        15: ascii=8'h66;
        default : ascii=0;
        
    endcase end
endmodule
