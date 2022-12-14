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
    wire [3:0] hexdigit;
    ascii_to_hexdigit a2h1(ascii,hexdigit);
    
    ps2_to_ascii pta(keycode[7:0],ascii);
    
    parameter DATA_SIZE = 16;
    parameter ADDRESS_LENGTH = 12;
    reg DMA;
    reg [ADDRESS_LENGTH-1:0] address_DMA;
    reg [DATA_SIZE-1:0] data_in_DMA;
    reg cpu_en;//cpu enable
    wire [DATA_SIZE-1:0] PC_out;
    wire [DATA_SIZE*6-1:0] R_allout;
    wire halted;
    wire divided_clock;
    clock_divider cd(clock,reset,divided_clock);
    CPU epyc(divided_clock,reset | ~cpu_en,0,PC_out,R_allout,DMA,address_DMA,data_in_DMA,halted);
    //genvar i;
//    generate for(i=0;i<6;i=i+1) begin
//        register R(R_allout[(i+1)*DATA_SIZE-1:i*DATA_SIZE],R_allin[(i+1)*DATA_SIZE-1:i*DATA_SIZE],reset,R_enable[i],clock);

    
    wire ready;
    reg [7:0] data;
    reg send;
    parameter WSS =60;
    reg [8*WSS-1:0] welcomeString = "\n\rHello EC551. My name is updog Jr.\n\rPlease enter a mode: ";
    parameter LSS=40;
    reg [8*LSS-1:0] LString = "\n\rMode L: Load Instructions from UART\n\r";
    parameter ISS=31;
    reg [8*LSS-1:0] IString = "\n\rMode I: Enter Instructions\n\r";
    parameter RegSS=16;
    reg [8*RegSS-1:0] RegString = "\n\rR_ = 0x____\n\r";
    reg [4:0] k_reg;
    parameter ASS=33;
    reg [8*ASS-1:0] AString = "\n\rMode A: Run an ALU operation\n\r";
    parameter BSS=30;
    reg [8*BSS-1:0] BString = "\n\rMode B: Benchmark Program\n\r";
    
    
    
    reg [5:0] i;
    reg [3:0] i_reg;
    wire [7:0] i_reg_ascii;
    wire [7:0] reg_val_ascii;
    reg [3:0] reg_val;
    hex_to_ascii h2a(i_reg,i_reg_ascii);
    hex_to_ascii h2a2(reg_val,reg_val_ascii);
    reg [DATA_SIZE/4-1:0] j_reg;
    reg idle;
    reg [2:0] cnt;
    
    // ------------------------- Mode B ---------------------------
    parameter S_Bread = 3'b001, S_Bcalc = 3'b010, S_Bprint = 3'b100;
    
    reg B_newline;
    wire B_send;
    wire [3:0] B_hex;
    wire [7:0] B_ascii;
    reg B_rst;
    wire B_rst_wire = B_rst;
    wire [2:0] B_state;
    // B_rst checks fsm is in correct state;
    fib_wrapper fib_module(.ascii(ascii), .flag(flag&&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0)), .ready(ready), .clk(clock), .rst(B_rst_wire), .send(B_send), .hex(B_hex), .state(B_state));
    hex_to_ascii fib_hex2ascii(B_hex,B_ascii);
    // ------------------------- Mode A ---------------------------
    wire A_send;
    wire [7:0] A_ascii;
    reg A_rst;
    wire A_rst_wire = A_rst;
    wire [2:0] A_state;
    // A_rst checks fsm is in correct state;
    modeA A_module(.ascii_in(ascii), .ready(ready), .clk(clock), .rst(A_rst_wire), .flag(flag&&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0)), .send(A_send), .ascii_out(A_ascii), .state(A_state));
    // ------------------------- State Machine ----------------------
    
   always @(posedge(clock))begin
        CLK50MHZ<=~CLK50MHZ;
        
        if(reset) begin
            state=0;
            i=0;
            send=0;
            nextstate=1;
            CLK50MHZ=0; 
            cpu_en=0;
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
                        if(i==ISS) begin
                            idle=1;
                            send=0;
                            end
                end
                else begin
                    if(idle) begin
                        DMA=0;
                        address_DMA=31;
                        data_in_DMA<=0;
                        idle=0;
                        cnt=0;
                        cpu_en<=0;
                        data=0;
                    end
                    else begin
                        if(cnt<4) begin
                            cpu_en=0;
                            if(flag && ascii==8'h72) begin//r
                                cnt<=6;
                                send<=0;
                                i_reg<=0;
                                j_reg<=0;
                                k_reg<=0;
                            end
                            else begin
                                send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                                data = ascii;
                                if(send) begin
                                    
                                    data_in_DMA[4*(4-cnt)-1 -: 4]=hexdigit;
                                    cnt=cnt+1;                         
                                end
                            end
                        end
                        else if(cnt==4) begin
                            send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                            data = ascii;
                            if(send && ascii==8'h0A) begin
                                cnt=5;
                                DMA=1;
                            end
                            
                        end
                        else if(cnt==5) begin//fix
                            DMA=0;
                            address_DMA=address_DMA+1;
                            send<=1;
                            data<=8'h0D;
                            if(ready) begin
                                send=0;
                                i=29;
                            end
                        end
                        else if(cnt==6)begin
                            cpu_en<=1;
                            
                            if(halted && ready) begin
                                
                                if(i_reg<6) begin
                                    
                                    if(k_reg<RegSS) begin
                                        case(k_reg)
                                            4: data = i_reg_ascii;

                                            10:begin
                                                reg_val <= R_allout[(i_reg+1)*DATA_SIZE-1-0 -:4]; 
                                                data<=reg_val_ascii;                                                 
                                            end
                                            11:begin 
                                                reg_val <= R_allout[(i_reg+1)*DATA_SIZE-1-4 -:4];
                                                data <= reg_val_ascii;                                                
                                            end
                                            12:begin 
                                                reg_val <= R_allout[(i_reg+1)*DATA_SIZE-1-8-:4]; 
                                                data <= reg_val_ascii; 
                                            end
                                            13:begin 
                                                reg_val <= R_allout[(i_reg+1)*DATA_SIZE-1-12-:4];
                                                data <= reg_val_ascii; 
                                            end
                                            default:data= RegString[8*(RegSS-k_reg)-1 -:8];
                                        endcase
//                                        data= RegString[8*(RegSS-k_reg)-1 -:8];
                                        send=1;
                                        if(ready) begin
                                            k_reg=k_reg+1;
                                        end
                                    end
                                    else begin//done with current reg, go to next
                                        if(k_reg==RegSS) begin
//                                            send=0;
                                            k_reg=0;
                                            i_reg=i_reg+1;
                                        end
                                    end
                                end
                                else begin//done printing regs
                                    idle=1;
                                    send=0;
                                    cpu_en=0;
                                end
                            end
                        end
                        
                    end
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
                        A_rst = 1;
                        if(ready)
                            i = i+1;
                end
                else begin
                    A_rst = 0;
                    case (A_state)
                        S_read: begin
                            // user enter number
                            send <=  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                            data <= ascii;
                        end
                        
                        S_calc: begin
                            // halt sending data until result is ready
                            send <= 0;
                            data <= 0; 
                        end
                        
                        S_print: begin
                            if (A_send) begin
                                // print result
                                send <= 1;
                                data <= A_ascii;
                            end 
                            else begin
                                send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                                data = ascii;
                            end
                        end
                        default: begin
                            send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                            data = ascii;
                        end 
                    endcase
                end
            end
            5: begin//B
                if(i<BSS) begin
                        data = BString[8*(BSS-i)-1 -: 8];
                        send=1;
                        B_rst = 1;
                        if(ready)
                            i = i+1;
                end
                else begin
                    B_rst = 0;
                    case (B_state)
                        S_Bread: begin
                            // user enter number
                            send <=  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                            data <= ascii;
                            B_newline <= 1;
                        end
                        
                        S_Bcalc: begin
                            if (B_newline) begin
                                // new line after input
                                send <= 1;
                                data <= "\n";
                                B_newline <= 0;
                            end 
                            else begin
                                // halt sending data until result is ready
                                send <= 0;
                                data <= 0;
                            end  
                        end
                        
                        S_Bprint: begin
                            if (B_send) begin
                                // print result
                                send <= 1;
                                data <= B_ascii;
                                B_newline <= 1;
                            end 
                            else if (B_newline) begin
                                // new line after output
                                send <= 1;
                                data <= "\n";
                                B_newline <= 0;
                            end 
                            else begin
                                send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                                data = ascii;
                            end
                        end
                        default: begin
                            send =  flag &&(keycode[15:8]!=8'hF0)&&(keycode[7:0]!=8'hF0);
                            data = ascii;
                        end 
                    endcase
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
