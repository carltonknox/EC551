`timescale 1ns / 1ps

module modeA_tb();
    reg [7:0] ascii_in;
    reg ready;
    reg clk;
    reg rst;
    reg flag;
    wire send;
    wire [7:0] ascii_out;
    wire [2:0] state;
    
    modeA DUT(.ascii_in(ascii_in), .ready(ready), .clk(clk), .rst(rst), .flag(flag), .send(send), .ascii_out(ascii_out), .state(state));
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 1;
        ready = 1;
        flag = 0;
        
        #10 rst = 0;
        
        // input 1
        #20;
        flag = 1;
        ascii_in = 8'h36;
        
        #10;
        flag = 0;
        ascii_in = 0;
        
        // input +
        #20
        flag = 1;
        ascii_in = 8'h2B;
        
        #10;
        flag = 0;
        ascii_in = 0;
        
        // input 0
        #20
        flag = 1;
        ascii_in = 8'h33;
        
        #10;
        flag = 0;
        ascii_in = 0;
        
        //input ENTER
        #20
        flag = 1;
        ascii_in = 8'h0a;
        
        #10
        flag = 0;
        ascii_in = 0;
        
        #1000;
    
    end
    
endmodule