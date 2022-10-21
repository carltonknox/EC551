`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2022 04:27:24 PM
// Design Name: 
// Module Name: CPU
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


module CPU#(
    parameter DATA_SIZE = 16,
    parameter ADDRESS_LENGTH = 12
    )(input clock,reset,
      output [DATA_SIZE-1:0] PC_out,
      output [DATA_SIZE*6-1:0] R_allout
    );
    wire [2:0] reg_select1,reg_select2;
    wire [DATA_SIZE-1:0] reg_in1,reg_in2,reg_out1,reg_out2;
    wire write_enable1,write_enable2;
    register_file registers(reg_select1,reg_in1,write_enable1,reg_out1,reg_select2,write_enable2,reg_in2,reg_out2,reset,clock,R_allout);
    
    ALU alu();   
    wire [DATA_SIZE-1:0] mem_out,
                         mem_in;
    wire [ADDRESS_LENGTH-1:0] mem_address;
    wire write_enable_mem;
    wire [DATA_SIZE-1:0] fetch_out;
    wire [ADDRESS_LENGTH-1:0] PC_address;
    memory mem(mem_address,PC_address,mem_in,mem_out,fetch_out,write_enable_mem,clock,reset);

    wire [DATA_SIZE-1:0] PC_next;
    wire [DATA_SIZE-1:0] instruction;
    wire PC_enable;
    register PC(PC_out,PC_next,,PC_enable,clock);
    fetch_unit FU(PC_out,fetch_out,PC_address,instruction);
    
    wire mcu_op,mcu_en;
    wire [DATA_SIZE-1:0] r_in_data,r_out_data,r_out_address;
    memory_controller MCU(mcu_op,mcu_en,r_out_address,r_out_data,mem_out,r_in_data,mem_in,write_enable_memtoreg,write_enable_mem,mem_address);
    
    control controller(instruction,reg_select1,reg_select2,reg_out1,reg_out2,mcu_op,mcu_en,r_in_data,r_out_data,r_out_address,write_enable1,write_enable2,reg_in1,reg_in2);
endmodule

module control#(
    parameter DATA_SIZE = 16,
    parameter ADDRESS_LENGTH = 12
    )(input [DATA_SIZE-1:0] instruction,
      output [2:0] Rn,Rm,
      input [DATA_SIZE-1:0] R_outn,R_outm,
      output reg mcu_op, mcu_en,
      input [DATA_SIZE-1:0] r_in_data,
      output reg [DATA_SIZE-1:0] r_out_data,r_out_address,
      output reg Rn_write,Rm_write,
      output reg [DATA_SIZE-1:0] Rn_in,Rm_in
      );
    wire [3:0] operation;
    wire [6:0] Rn,Rm;
    assign operation = instruction[15:12];
    assign Rn = instruction[8:6];
    assign Rm = instruction[2:0];
    always@(*) begin
    //default:
    begin
        r_out_address<=0;
        mcu_op <= 0;
        mcu_en <= 0;
        Rn_write<=0;
        Rm_write<=0;
        Rn_in<=0;
        Rm_in<=0;
    end
    case(operation)
        4'b1011: begin
            mcu_op <= 0;
            mcu_en <= 1;
            Rn_write<=0;
            Rm_write<=0;
            r_out_address <=R_outn; 
        end
        4'b1100 : begin
            mcu_op <= 1;
            mcu_en <= 1;
            Rn_write<=1;
            Rm_write<=0;
            r_out_address <=R_outm;
            Rn_in<=r_in_data;
        end
     endcase
     end

    
endmodule
