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
    always@(*)
    case(ascii)
        4'h0: ascii=8'h30;
        4'h1: ascii=8'h31;
        4'h2: ascii=8'h32;
        4'h3: ascii=8'h33;
        4'h4: ascii=8'h34;
        4'h5: ascii=8'h35;
        4'h6: ascii=8'h36;
        4'h7: ascii=8'h37;
        4'h8: ascii=8'h38;
        4'h9: ascii=8'h39;
        4'ha: ascii=8'h61;
        4'hb: ascii=8'h62;
        4'hc: ascii=8'h63;
        4'hd: ascii=8'h64;
        4'he: ascii=8'h65;
        4'hf: ascii=8'h66;
        
    endcase
endmodule
