`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2022 08:17:17 PM
// Design Name: 
// Module Name: demo_vlog
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


module demo_vlog(input clock,
    input PS2_CLK,
    input PS2_DATA,
    output [6:0]SEG,
    output [7:0]AN,
    output DP,
    output uart_tx

    );
    reg CLK50MHZ=0;    
    wire [31:0]keycode;
    
    always @(posedge(clock))begin
        CLK50MHZ<=~CLK50MHZ;
    end
    wire flag;
    PS2Receiver keyboard (
        .clk(CLK50MHZ),
        .kclk(PS2_CLK),
        .kdata(PS2_DATA),
        .keycodeout(keycode[31:0]),
        .flag(flag)
        );
    wire ready;
    wire [7:0] data;
    wire send;
    reg cnt;
//    always@(posedge PS2_CLK) //here
//    begin
//        if(cnt)
//            send=0;
//        cnt=1;
        
//        end
    wire div_clock;
    clock_div_22#(21) cd(CLK50MHZ,0,div_clock);
    assign send = flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
    assign data = keycode[7:0];
//    always@(posedge flag) begin
//        if(keycode[15:8]!=8'hF0) begin
////            send<=1;
//            data<=keycode[7:0];
//        end
//        else send=0;
////        if(keycode[15:8]==8'hF0) begin
////            data=keycode[7:0];
////        end
//    end
//    always@(negedge PS2_CLK) begin
//        send<=0;
//    end
    UART_TX_CTRL UTC(.CLK(clock),.READY(ready),.UART_TX(uart_tx),.DATA(data),.SEND(send));
endmodule