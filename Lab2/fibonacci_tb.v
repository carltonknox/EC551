`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2022 12:18:53 AM
// Design Name: 
// Module Name: fibonacci_tb
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


module fibonacci_tb();
    
    reg clk, rst;
    reg [5:0] n;
    wire [31:0] sum;
    wire print;
    
    fibonacci DUT(.clk(clk), .rst(rst), .n(n), .sum(sum), .print(print));
    
    always #5 clk = ~clk;
    
    initial begin
       
       clk = 0;
       rst = 1;
       n = 5;
       
       # 10
       rst = 0;
       
       # 100
       rst = 1;
       n = 10;
       
       # 10
       rst = 0; 
       
       # 100
       rst = 1;
       n = 20;
       
       #10
       rst = 0;
                
    end    
    
endmodule
