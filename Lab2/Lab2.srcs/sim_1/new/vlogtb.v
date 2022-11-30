`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2022 08:12:43 PM
// Design Name: 
// Module Name: vlogtb
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


module vlogtb(

    );
    reg reset,flag, clock;
    reg [31:0]keycode;
    wire [6:0] SEG;
    wire [7:0] AN;
    wire DP;
    wire uart_tx;
    reg ready;
    wire [7:0] data;
    test_vlog dv(clock
    ,reset,
     flag,
     keycode,
     SEG,
     AN,
     DP,
     uart_tx,
     ready,
     data);
    initial begin
        {reset,flag,keycode,clock}=0;
        ready=1;
        #10 reset=1;
        #10 reset=0;
    end
    initial begin
        #270 keycode=8'h43; flag=1;
        #8 keycode=8'h5A; flag=1;
        #8 flag=0;
        
    end
    initial begin
        #420 
        keycode = 8'h69;
        flag=1;
        #4 flag=0;
            keycode = 8'h70;
        #4 flag=1;
        #4 flag=0;
        #4 flag=1;
        #4 flag=0;
            keycode = 8'h69;
        #4 flag=1;
        #4 flag = 0;
        #4
        keycode = 8'h5A;
        #4 flag=1;
        #8
        keycode = 8'h70;
        #4 flag=0;
        #4 flag=1;
        #4 flag=0;
        #4 flag=1;
        #4 flag=0;
        #4 flag=1;
        #4 flag = 0;
        #4
        keycode = 8'h5A;
        #4 flag=1;
        #4 flag=0;
        #8;#26
        keycode = 8'h2D;
        flag=1;
        #8 keycode = 8'h5A;
        #8 flag=0;
    end
    initial begin
        #570
        keycode = 8'h2D;
        flag=1;
        #8 keycode = 8'h5A;
        #8 flag=0;
    end
    always begin
        #2 clock=~clock;
    end
//    always begin
//        #4 flag=~flag;
//    end
endmodule
