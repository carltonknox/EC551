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
    input reset,
    input PS2_CLK,
    input PS2_DATA,
    output [6:0]SEG,
    output [7:0]AN,
    output DP,
    output uart_tx
    );
    reg CLK50MHZ=0;    
    wire [31:0]keycode;
    reg [0:0] state;
    
    
    wire flag;
    PS2Receiver keyboard (
        .clk(CLK50MHZ),
        .kclk(PS2_CLK),
        .kdata(PS2_DATA),
        .keycodeout(keycode[31:0]),
        .flag(flag)
        );
        
    wire [7:0] ascii;
    ps2_to_ascii pta(keycode[7:0],ascii);
    
    wire ready;
    reg [7:0] data;
    reg send;
    parameter WSS =58;
    reg [8*WSS-1:0] welcomeString = "Hello EC551. My name is updog Jr.\n\rPlease enter a mode: ";
    reg [5:0] i;
   always @(posedge(clock))begin
        CLK50MHZ<=~CLK50MHZ;
        if(reset) begin
            state=0;
            i=0;
            send=0;
        end
        else begin
        //welcome
        case(state)
            0 :  begin
                    if(i<WSS) begin
                        data = welcomeString[8*(WSS-i)-1 -: 8];
                        send=1;
                        if(ready)
                            i = i+1;
                    end
                    else begin
                        send=0;
                        state=1;
                    end
                end
            default : begin
                send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                data = ascii;
            end
        endcase
        end
        
    end
    
//    assign send = flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
    
//    assign data = ascii;
    
    UART_TX_CTRL UTC(.CLK(clock),.READY(ready),.UART_TX(uart_tx),.DATA(data),.SEND(send));
endmodule