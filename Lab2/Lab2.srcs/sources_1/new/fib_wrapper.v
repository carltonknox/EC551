`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2022 10:36:05 PM
// Design Name: 
// Module Name: fib_wrapper
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

module fib_wrapper(
    input [7:0] ascii,
    input ready,
    input clk,
    input rst,
    input flag,
    output reg send,
    output reg [3:0] hex,
    output reg [2:0] state
    );

    // wrapper regs
    reg [7:0] num_in;  // store input
    reg [31:0] result;  // store output
    reg [3:0] i;        // reg to print char one at a time 

    // fib connection
    // input side
    reg input_state;
    reg [5:0] n;
    wire [5:0] n_wire = n;   // convert from BCD to binary
    reg fib_rst;
    wire fib_rst_wire = fib_rst;
    // output side
    wire print;
    wire [31:0] sum_wire;

    // fib module
    fibonacci fibonacci(.clk(clk), .rst(fib_rst_wire), .n(n_wire), .sum(sum_wire), .print(print));

    // FSM
    parameter S_read = 3'b001, S_calc = 3'b010, S_print = 3'b100;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            send <= 0;
            hex <= 4'b0;
            i <= 4'd0;
            num_in <= 12'b0;
            result <= 32'b0;
            state <= S_read;
            fib_rst <= 1;  
            input_state <= 0;
        end
        else begin
            case(state) 
                // read last 2 key press into reg
                S_read: begin if (flag) begin      
                            case(input_state)
                                // first input
                                0: begin                       
                                case(ascii)
                                    8'h30: begin
                                        num_in[7:4]<=4'h0;
                                        input_state<=1;
                                    end
                                    8'h31: begin
                                        num_in[7:4]<=4'h1;
                                        input_state<=1;
                                    end 
                                    8'h32: begin
                                        num_in[7:4]<=4'h2;
                                        input_state<=1;
                                    end
                                    8'h33: begin
                                        num_in[7:4]<=4'h3;
                                        input_state<=1;
                                    end
                                    8'h34: begin
                                        num_in[7:4]<=4'h4;
                                        input_state<=1;
                                    end
                                    8'h35: begin
                                        num_in[7:4]<=4'h5;
                                        input_state<=1;
                                    end
                                    8'h36: begin
                                        num_in[7:4]<=4'h6;
                                        input_state<=1;
                                    end
                                    8'h37: begin
                                        num_in[7:4]<=4'h7;
                                        input_state<=1;
                                    end
                                    8'h38: begin
                                        num_in[7:4]<=4'h8;
                                        input_state<=1;
                                    end
                                    8'h39: begin
                                        num_in[7:4]<=4'h9;
                                        input_state<=1;
                                    end
                                    8'h0A: begin
                                        // ENTER calculates n for fib module and move to next state
                                        fib_rst <= 0;
                                        n <= num_in[7:4];
                                        state <= S_calc;      
                                    end
                                    default: num_in[7:4]<=4'h0; // other key presses treat as 0, and doesn't advance input state
                                endcase
                                end
                                // second input
                                1: begin                       
                                case(ascii)
                                    8'h30: begin
                                        num_in[3:0]<=4'h0;
                                    end
                                    8'h31: begin
                                        num_in[3:0]<=4'h1;
                                    end 
                                    8'h32: begin
                                        num_in[3:0]<=4'h2;
                                    end
                                    8'h33: begin
                                        num_in[3:0]<=4'h3;
                                    end
                                    8'h34: begin
                                        num_in[3:0]<=4'h4;
                                    end
                                    8'h35: begin
                                        num_in[3:0]<=4'h5;
                                    end
                                    8'h36: begin
                                        num_in[3:0]<=4'h6;
                                    end
                                    8'h37: begin
                                        num_in[3:0]<=4'h7;
                                    end
                                    8'h38: begin
                                        num_in[3:0]<=4'h8;
                                    end
                                    8'h39: begin
                                        num_in[3:0]<=4'h9;
                                    end
                                    8'h0A: begin
                                        // ENTER calculates n for fib module and move to next state
                                        fib_rst <= 0;
                                        n <= num_in[7:4]*4'd10 + num_in[3:0];
                                        state <= S_calc;      
                                    end
                                    default: num_in[3:0]<=4'h0; // other key presses treat as 0
                                endcase
                                end
                            endcase                     

                        end 
                        // else stay at the same state
                        else begin
                            state <= S_read;
                        end
                end

                S_calc: begin if (print) begin
                            // move to print state once print is high
                            result <= sum_wire;
                            state <= S_print;
                        end else begin
                            // stay at same state
                            state <= S_calc;
                        end
                end

                S_print: begin if (i < 8) begin
                            if (ready) begin
                                // shift out result to hex when ready
                                hex <= result[31:28];
                                result[31:28]<=result[27:24];
                                result[27:24]<=result[23:20];
                                result[23:20]<=result[19:16];
                                result[19:16]<=result[15:12];
                                result[15:12]<=result[11:8];
                                result[11:8]<=result[7:4];
                                result[7:4]<=result[3:0];
                                result[3:0]<=4'b0;
                                i <= i+1;
                            end
                            send <= 1;
                            state <= S_print;                                                    
                        end else begin
                            // reset for next execution
                            send <= 0;
                            hex <= 4'b0;
                            i <= 4'd0;
                            num_in <= 12'b0;
                            result <= 32'b0;
                            fib_rst <= 1;
                            state <= S_read;
                            input_state <= 0;
                        end
                end
            endcase
        end
    end

endmodule

