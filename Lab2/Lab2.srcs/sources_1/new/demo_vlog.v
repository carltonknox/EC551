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
    reg [2:0] state;
    reg [2:0] nextstate;
    
    
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
    parameter WSS =60;
    reg [8*WSS-1:0] welcomeString = "\n\rHello EC551. My name is updog Jr.\n\rPlease enter a mode: ";
    parameter LSS=40;
    reg [8*LSS-1:0] LString = "\n\rMode L: Load Instructions from UART\n\r";
    parameter ISS=31;
    reg [8*LSS-1:0] IString = "\n\rMode I: Enter Instructions\n\r";
    parameter ASS=33;
    reg [8*ASS-1:0] AString = "\n\rMode A: Run an ALU operation\n\r";
    parameter BSS=30;
    reg [8*BSS-1:0] BString = "\n\rMode B: Benchmark Program\n\r";
    parameter OSS=7;
    reg [8*OSS-1:0] OString = "\n\r  \n\r";

    reg [5:0] i;
    reg [5:0] j;
    reg [2:0] A;
    reg [2:0] B;
    reg [1:0] ALUOp;
    wire [2:0] C;

    reg idle;
    reg [1:0] cnt;
    ALU alu(A,B,ALUOp,C);   
    
    wire ascii_out;
    ascii2op a2o(data, ascii_out);
   always @(posedge(clock))begin
        CLK50MHZ<=~CLK50MHZ;
        if(reset) begin
            state=0;
            i=0;
            j=63;
            send=0;
            nextstate=1;
            CLK50MHZ=0; 
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
                        state=1;//go to mode select state
                    end
                end
            1 : begin
                send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                data = ascii;
                case(ascii)
                    8'h69:  nextstate = 2;//I
                    8'h6C:  nextstate = 3;//L
                    8'h61:  nextstate = 4;//A
                    8'h62:  nextstate = 5;//B
                    8'h0A:  begin state = nextstate; i=0; send=0; end
                    default:nextstate = 1;//stay
                endcase
            end
            2: begin//I
                if(i<ISS) begin
                        data = IString[8*(ISS-i)-1 -: 8];
                        send=1;
                        if(ready)
                            i = i+1;
                end
                else begin
                    send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                    data = ascii;
                end
            end
            3: begin//L
                if(i<LSS) begin
                        data = LString[8*(LSS-i)-1 -: 8];
                        send=1;
                        if(ready)
                            i = i+1;
                end
                else begin
                send=0;
                    
                end
            end
            4: begin//A
                if(i<ASS) begin
                        data = AString[8*(ASS-i)-1 -: 8];
                        send=1;
                        if(ready)
                            i = i+1;
                        idle = 1;
                end
                else if (j < OSS) begin
                                     
                        data = OString[8*(OSS-i)-1 -: 8];
                        send=1;
                        if(ready)
                            j = j+1;
                        idle = 1;
                end
                else begin
                if (idle) begin
                 cnt = 0;
                 A = 0;
                 B = 0;
                 ALUOp = 0;
                 idle = 0;
                end
                else
                begin
                    send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                    data = ascii;
                    if (flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0)) begin
                        cnt = cnt + 1;
                    end
                    case(cnt)
                    1: A = data - 48;
                    2: ALUOp = ascii_out;
                    3: B = data - 48;
                    endcase
                end
                end
            end
            5: begin//B
                if(i<BSS) begin
                        data = BString[8*(BSS-i)-1 -: 8];
                        send=1;
                        if(ready)
                            i = i+1;
                end
                else begin
                    send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                    data = ascii;
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