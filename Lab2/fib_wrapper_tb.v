`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2022 10:48:48 PM
// Design Name: 
// Module Name: fib_wrapper_tb
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


module fib_wrapper_tb();

reg clk, rst, ready, flag;
reg [7:0] ascii;
wire send;
wire [3:0] hex;

fib_wrapper DUT(.ascii(ascii), .ready(ready), .clk(clk), .rst(rst), .flag(flag), .send(send), .hex(hex));

always #5 clk= ~clk;

initial begin
    clk = 0;
    rst = 1;
    ready = 1;
    flag = 0;
    
    #10 rst = 0;
    
    // input 1
    #20
    flag = 1;
    ascii = 8'h31;
    
    #10
    flag = 0;
    
    // input 0
    #20
    flag = 1;
    ascii = 8'h30;
    
    #10
    flag = 0;
    
    //input ENTER
    #20
    flag = 1;
    ascii = 8'h0a;
    
    #10
    flag = 0;
    
    #1000;

end


endmodule
