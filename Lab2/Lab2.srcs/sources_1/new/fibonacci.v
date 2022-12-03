`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2022 11:24:42 PM
// Design Name: 
// Module Name: fibonacci
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


module fibonacci(
    input clk,
    input rst,
    input [5:0] n,
    output [31:0] sum,
    output reg print
    );
    
    reg [31:0] current;
    reg [31:0] previous;
    reg [5:0] counter;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            previous <= 32'b0;
            current <= 32'b1;
            counter <= 6'b1;
            print <= 0;       
        end else if (counter < n) begin
            current <= current + previous;
            previous <= current;
            counter <= counter + 1;
            print <= 0;
        end else begin
            print <= 1;
        end
    end

    assign sum = current;
    
endmodule
