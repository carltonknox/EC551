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
    output reg [3:0] hex
    );

    // wrapper regs
    reg [11:0] num_in;  // store input
    reg [31:0] result;  // store output
    reg [3:0] i;        // reg to print char one at a time 

    // fib connection
    // input side
    wire [5:0] n_wire = num_in[11:8]*4'd10 + num_in[7:4];   // convert from BCD to binary
    reg fib_rst;
    wire fib_rst_wire = fib_rst;
    // output side
    wire print;
    wire [31:0] sum_wire;

    // fib module
    fibonacci fibonacci(.clk(clk), .rst(fib_rst_wire), .n(n_wire), .sum(sum_wire), .print(print));

    // FSM
    reg [2:0] state, next_state;
    parameter S_read = 3'b001, S_calc = 3'b010, S_print = 3'b100;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            send <= 0;
            hex <= 4'b0;
            i <= 4'd0;
            num_in <= 12'b0;
            result <= 32'b0;
            next_state <= S_read;
            fib_rst <= 1;  
        end
        else begin
            case(state) 
                // read last 3 key press into shift reg
                S_read: begin if (flag) begin
                            num_in[11:8]<= num_in[7:4];
                            num_in[7:4]<=num_in[3:0];
                            case(ascii)
                                8'h30: num_in[3:0]<=4'h0;
                                8'h31: num_in[3:0]<=4'h1;
                                8'h32: num_in[3:0]<=4'h2;
                                8'h33: num_in[3:0]<=4'h3;
                                8'h34: num_in[3:0]<=4'h4;
                                8'h35: num_in[3:0]<=4'h5;
                                8'h36: num_in[3:0]<=4'h6;
                                8'h37: num_in[3:0]<=4'h7;
                                8'h38: num_in[3:0]<=4'h8;
                                8'h39: num_in[3:0]<=4'h9;
                                8'h0A: num_in[3:0]<=4'ha;
                            endcase
                            // stay at same state
                            next_state <= S_read;

                        // move to calc state if last key press is enter
                        end else if (num_in[3:0] == 4'ha) begin
                            // begin fib calculation
                            fib_rst <= 0;
                            next_state <= S_calc;
                            end
                end

                S_calc: begin if (print) begin
                            // move to print state once print is high
                            result <= sum_wire;
                            next_state <= S_print;
                        end else begin
                            // stay at same state
                            next_state <= S_calc;
                        end
                end

                S_print: begin if ((ready) && (i < 8)) begin
                            // shift out result to hex
                            hex <= result[31:28];
                            result[31:28]<=result[27:24];
                            result[27:24]<=result[23:20];
                            result[23:20]<=result[19:16];
                            result[19:16]<=result[15:12];
                            result[15:12]<=result[11:8];
                            result[11:8]<=result[7:4];
                            result[7:4]<=result[3:0];
                            result[3:0]<=4'b0;
                            send <= 1;
                            i <= i+1;
                            next_state <= S_print;
                        end else if ((~ready) && (i < 8)) begin
                            // halt if ready is not high
                            send <= 1;
                            next_state <= S_print;
                        end else begin
                            // reset for next execution
                            send <= 0;
                            hex <= 4'b0;
                            i <= 4'd0;
                            num_in <= 12'b0;
                            result <= 32'b0;
                            fib_rst <= 1;
                            next_state <= S_read;
                        end
                end
            endcase
        end
    end

    // update state
    always @(posedge clk) state <= next_state;

endmodule

