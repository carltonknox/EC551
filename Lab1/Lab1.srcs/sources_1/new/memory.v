`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Carlton Knox and Po Hao Chen
// EC551
// 12-bit address space
// 16-bit data size
// 
//////////////////////////////////////////////////////////////////////////////////


module memory#(
parameter DATA_SIZE = 16,
parameter ADDRESS_LENGTH = 12,
parameter MEM_INIT_FILE = "C:/Users/ckowk/Documents_Offline/EC551/Lab1/meminit.txt"
)(
    input [ADDRESS_LENGTH-1:0] address,
    input [ADDRESS_LENGTH-1:0] fetch_address,
    input [DATA_SIZE-1:0] data_in,
    output [DATA_SIZE-1:0] data_out1,
    output [DATA_SIZE-1:0] data_out2,
    input write,
          clock,
          reset,
          DMA,
    input [ADDRESS_LENGTH-1:0] address_DMA,
    input [DATA_SIZE-1:0] data_in_DMA
    );
    reg [DATA_SIZE-1:0] mem [2 ** ADDRESS_LENGTH -1 : 0];
    assign data_out1 = mem[address];
    assign data_out2 = mem[fetch_address];
    always@(posedge clock) begin
        if(DMA) begin
            mem[address_DMA] = data_in_DMA;
        end
        else
        if(write)
            mem[address] = data_in;
    end
    initial begin
        if (MEM_INIT_FILE != "") begin
            $readmemb(MEM_INIT_FILE, mem);
        end
    end
endmodule
