`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2022 10:16:14 PM
// Design Name: 
// Module Name: modeA
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


module modeA(
    input [7:0] ascii_in,
    input ready,
    input clk,
    input rst,
    input flag,
    output reg send,
    output [7:0] ascii_out,
    output reg [2:0] state
    );
    
    // ---------Input: ascii to hex (and operation)---------
    parameter XOR = 2'b00, ADD = 2'b01, SUB = 2'b10, AND = 2'b11;
    
    // ---------Calculation: ALU---------
    // input
    reg [2:0] ALU_integer_a;
    wire [2:0] ALU_integer_a_wire = ALU_integer_a;
    reg [1:0] ALU_operation;
    wire [1:0] ALU_operation_wire = ALU_operation;
    reg [2:0] ALU_integer_b;
    wire [2:0] ALU_integer_b_wire = ALU_integer_b;
    reg ALU_rst;
    wire ALU_rst_wire = (rst | ALU_rst);
    
    // output
    wire ALU_print;
    wire [3:0] ALU_result;
    
    // ALU module
    modeA_ALU ALU(.integer_a(ALU_integer_a_wire), .operation(ALU_operation_wire), .integer_b(ALU_integer_b_wire), .clk(clk), .rst(ALU_rst_wire), .print(ALU_print), .result(ALU_result));
    
    
    // ---------Output: hex to ascii---------
    reg [7:0] result;
    reg [1:0] i;
    reg [3:0] hex_out;
    wire [3:0] hex_out_wire = hex_out;
    hex_to_ascii hex2ascii(hex_out_wire, ascii_out);
    
    // FSM
    parameter S_read = 3'b001, S_calc = 3'b010, S_print = 3'b100;
    reg [1:0] read_state;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // RESET
            ALU_rst <= 1;
            state <= S_read;
            read_state <= 0;
            ALU_integer_a <= 3'h0;
            ALU_operation <= 2'h0;
            ALU_integer_b <= 3'h0;
            send <= 0;
            hex_out <= 4'b0;
            i <= 2'd0;
            result <= 8'b0;

        end
        else begin
            case (state)
                // S_read
                S_read: begin
                    if (flag) begin
                        case (read_state)
                            // no input
                            0: begin
                                case (ascii_in)
                                    8'h30: begin
                                        ALU_integer_a <= 3'h0;
                                        read_state <= 1;
                                    end
                                    8'h31: begin
                                        ALU_integer_a <= 3'h1;
                                        read_state <= 1;
                                    end 
                                    8'h32: begin
                                        ALU_integer_a <= 3'h2;
                                        read_state <= 1;
                                    end
                                    8'h33: begin
                                        ALU_integer_a <= 3'h3;
                                        read_state <= 1;
                                    end
                                    8'h34: begin
                                        ALU_integer_a <= 3'h4;
                                        read_state <= 1;
                                    end
                                    8'h35: begin
                                        ALU_integer_a <= 3'h5;
                                        read_state <= 1;
                                    end
                                    8'h36: begin
                                        ALU_integer_a <= 3'h6;
                                        read_state <= 1;
                                    end
                                    8'h37: begin
                                        ALU_integer_a <= 3'h7;
                                        read_state <= 1;
                                    end
                                    default: begin
                                        ALU_integer_a <= 3'h0;  // treat as 0
                                        read_state <= 0;        // stay at same state
                                    end
                                endcase 
                            end // end of no input
                            
                            // 1 input
                            1: begin
                                case (ascii_in)
                                    // operation XOR ^
                                    8'h5e: begin
                                        ALU_operation <= XOR;
                                        read_state <= 2;
                                    end
                                    // operation ADD +
                                    8'h2b: begin
                                        ALU_operation <= ADD;
                                        read_state <= 2;
                                    end 
                                    // operation SUB -
                                    8'h2d: begin
                                        ALU_operation <= SUB;
                                        read_state <= 2;
                                    end
                                    // operation AND #
                                    8'h23: begin
                                        ALU_operation <= AND;
                                        read_state <= 2;
                                    end
                                    default: begin
                                        ALU_operation <= 2'h0;  // treat as 0
                                        read_state <= 1;        // stay at same state
                                    end
                                endcase
                            end // end of 1 input
                            
                            // 2 input
                            2: begin
                                case (ascii_in)
                                    8'h30: begin
                                        ALU_integer_b <= 3'h0;
                                        read_state <= 3;
                                    end
                                    8'h31: begin
                                        ALU_integer_b <= 3'h1;
                                        read_state <= 3;
                                    end 
                                    8'h32: begin
                                        ALU_integer_b <= 3'h2;
                                        read_state <= 3;
                                    end
                                    8'h33: begin
                                        ALU_integer_b <= 3'h3;
                                        read_state <= 3;
                                    end
                                    8'h34: begin
                                        ALU_integer_b <= 3'h4;
                                        read_state <= 3;
                                    end
                                    8'h35: begin
                                        ALU_integer_b <= 3'h5;
                                        read_state <= 3;
                                    end
                                    8'h36: begin
                                        ALU_integer_b <= 3'h6;
                                        read_state <= 3;
                                    end
                                    8'h37: begin
                                        ALU_integer_b <= 3'h7;
                                        read_state <= 3;
                                    end
                                    default: begin
                                        ALU_integer_b <= 3'h0;  // treat as 0
                                        read_state <= 2;        // stay at same state
                                    end
                                endcase
                            end // end of 2 input
                            
                            // 3 input
                            3: begin
                                // if user press ENTER, move to calculation
                                if (ascii_in == 8'h0A) begin
                                    ALU_rst <= 0;
                                    state <= S_calc;
                                end
                            end // end of 3 input
                            
                            // default
                            default: begin
                                read_state <= 0;    // reset to read_state 0
                            end // end of default
                        endcase // end of read_state
                    end
                    // else stay at same state
                    else begin
                        state <= S_read;
                    end
                end // end of S_read
                
                // S_calc
                S_calc: begin
                    // if print is high, go to S_print
                    if (ALU_print) begin
                        result [3:0] <= ALU_result % 10;
                        result [7:4] <= (ALU_result / 10) % 10;
                        state <= S_print;
                    end 
                    // else stay at S_calc
                    else begin
                        state <= S_calc;
                    end
                end // end of S_calc
                
                // S_print
                S_print: begin
                    if (i < 2) begin
                        if (ready) begin
                            hex_out <= result[7:4];
                            result[7:4] <= result[3:0];
                            result[3:0] <= 4'b0;
                            i <= i + 1;
                        end 
                    send <= 1;
                    state <= S_print;    
                    end
                    else begin
                        ALU_rst <= 1;
                        state <= S_read;
                        read_state <= 0;
                        ALU_integer_a <= 3'h0;
                        ALU_operation <= 2'h0;
                        ALU_integer_a <= 3'h0;
                        send <= 0;
                        hex_out <= 4'b0;
                        i <= 2'd0;
                        result <= 8'b0;
                    end
                end // end of S_print
                
                default: begin
                end // end of default
            endcase // state
        end
    end
   
endmodule


