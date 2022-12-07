`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2022 10:19:28 PM
// Design Name: 
// Module Name: modeA_ALU
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


module modeA_ALU(
    input [2:0] integer_a,
    input [1:0] operation,
    input [2:0] integer_b,
    input clk,
    input rst,
    output reg print,
    output reg [3:0] result
    );
    
    // operations
    parameter XOR = 2'b00, ADD = 2'b01, SUB = 2'b10, AND = 2'b11;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            print <= 0;
            result <= 4'b0;
        end 
        else begin
            case(operation)
                // XOR 
                XOR: begin
                    print <= 1;
                    result <= integer_a ^ integer_b;
                end // end of XOR
                
                // ADD
                ADD: begin
                    print <= 1;
                    result <= integer_a + integer_b;
                end // end of ADD
                
                // SUB 
                SUB: begin
                    print <= 1;
                    result <= integer_a - integer_b;
                end // end of SUB
                
                // AND
                AND: begin
                    print <= 1;
                    result <= integer_a & integer_b;
                end // end of AND
                
            endcase    
        end
    end
    
    
    
endmodule
