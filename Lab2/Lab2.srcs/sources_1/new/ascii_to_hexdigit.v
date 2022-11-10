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


module ascii_to_hexdigit(
    input [7:0] ascii,
    output reg [3:0] hexdigit
    );
    always@(*)
    case(ascii)
        8'h30: hexdigit=4'h0;
        8'h31: hexdigit=4'h1;
        8'h32: hexdigit=4'h2;
        8'h33: hexdigit=4'h3;
        8'h34: hexdigit=4'h4;
        8'h35: hexdigit=4'h5;
        8'h36: hexdigit=4'h6;
        8'h37: hexdigit=4'h7;
        8'h38: hexdigit=4'h8;
        8'h39: hexdigit=4'h9;
        8'h61: hexdigit=4'ha;
        8'h62: hexdigit=4'hb;
        8'h63: hexdigit=4'hc;
        8'h64: hexdigit=4'hd;
        8'h65: hexdigit=4'he;
        8'h66: hexdigit=4'hf;
        
    endcase
endmodule
