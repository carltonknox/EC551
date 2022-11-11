`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2022 10:36:05 PM
// Design Name: 
// Module Name: fib_wrapper
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


module fib_wrapper(
    input [7:0] ascii,
    input ready,
    input clk,
    input rst,
    output reg send,
    output reg [7:0] data
    );
    
    // input side
    reg [7:0] BCD;
    reg [11:0] num_in = 12'b0;
    wire [5:0] n = num_in[11:8]*4'd10 + num_in[7:4];
    
    // output side
    wire print;
    wire [31:0] sum_wire;
    reg [31:0] result = 0;
    reg [2:0] i = 3'd7;
    
    always @(posedge ready)begin
        // shift registers recording last 3 keypresses
        num_in[11:8]<= num_in[7:4];
        num_in[7:4]<=num_in[3:0];
        
        //translating ascii to bcd
        case(ascii)
            8'h30: num_in[3:0]<=4'h0;
            8'h31: num_in[3:0]<=4'h1;
            8'h32: num_in[3:0]<=4'h2;
            8'h33: num_in[3:0]<=4'h3;
            8'h34: num_in[3:0]<=4'h4;
            8'h35: num_in[3:0]<=4'h5;
            8'h36: num_in[3:0]<=4'h6;
            8'h37: num_in[3:0]<=4'h7;
            8'h38: num_in[3:0]<=4'h8;
            8'h39: num_in[3:0]<=4'h9;
            8'h0A: num_in[3:0]<=4'ha; // ENTER
        endcase
   end
   
   // fib module (rst goes low when last input is ENTER)
    fibonacci fibonacci(.clk(clk), .rst((num_in[3:0] == 4'ha)?0:1), .n(n), .sum(sum_wire), .print(print));

   // storing fib result
   always @(negedge print)begin
        result <= sum_wire;
   end
   
   // printing fib result
   always @(posedge clk) begin
        if ((result != 0) & (ready == 1) & (i != 0)) begin
            data <= result[31:24];
            result[31:24]<=result[23:16];
            result[23:16]<=result[15:8];
            result[15:8]<=result[7:0];
            send <= 1;
            i <= i-1;   
        end else begin
            send <= 0;
        end
   end
endmodule

