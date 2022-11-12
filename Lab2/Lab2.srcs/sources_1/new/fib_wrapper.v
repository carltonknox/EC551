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
    input flag,
    output reg send,
    output reg [3:0] hex
    );
    
    // input side
    reg [11:0] num_in;
    wire [5:0] n = num_in[11:8]*4'd10 + num_in[7:4];
    
    // output side
    wire print;
    wire [31:0] sum_wire;
    reg [31:0] result;
    reg [3:0] i;
    reg check;

    // input side
    always @(negedge flag)begin
        // shift registers recording last 3 keypresses       
        // translating ascii to bcd
        case(ascii)
            8'h30: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'h0;
            end
            8'h31: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'h1;
            end
            8'h32: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'h2;
            end
            8'h33: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'h3;
            end
            8'h34: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'h4;
            end
            8'h35: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'h5;
            end
            8'h36: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'h6;
            end
            8'h37: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'h7;
            end
            8'h38: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'h8;
            end
            8'h39: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'h9;
            end
            8'h0A: begin
            num_in[11:8]<= num_in[7:4];
            num_in[7:4]<=num_in[3:0];
            num_in[3:0]<=4'ha; // ENTER
            end
        endcase
   end
   
   // fib module (rst goes low when last input is ENTER)
    fibonacci fibonacci(.clk(clk), .rst(rst | (num_in[3:0] != 4'ha)), .n(n), .sum(sum_wire), .print(print));

   // output side
   always @(posedge clk) begin
        if (rst) begin
            send <= 0;
            hex <= 4'b0;
            i <= 4'd8;
            result <= 32'b0;
        // store fib result
        end else if (print) begin
            result <= sum_wire;
            check <= 1;
        // print fib result
        end else if ((check) & (ready) & (i != 0)) begin
            hex <= result[31:28];
            result[31:28]<=result[27:24];
            result[27:24]<=result[23:20];
            result[23:20]<=result[19:16];
            result[19:16]<=result[15:12];
            result[15:12]<=result[11:8];
            result[11:8]<=result[7:4];
            result[7:4]<=result[3:0];
            result[3:0]<=4'b0;
            send <= 1;
            i <= i-1;   
        end else begin
            send <= 0;
        end
   end
endmodule

