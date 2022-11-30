module clock_div_1(
	input clk_in,
	input rst,
	output reg divided_clk
    );
    always@(posedge clk_in,posedge rst)
        if(rst==1)
            divided_clk=0;
        else
            divided_clk = ~divided_clk;
endmodule
module clock_div_22#(parameter N = 22)(
	input clk_in,
	input rst,
	output divided_clk
    );
    wire[N:0] w;
    assign w[0] = clk_in;
    assign divided_clk = w[N];
    genvar i;
    generate for(i=0;i<N;i=i+1) begin
        clock_div_1 cd1_(w[i],rst,w[i+1]);
    end
    endgenerate
endmodule
module clock_divider(
	input clk_in,
	input rst,
	output reg divided_clk
    );
	 
	 
reg[31:0] toggle_value = 10000;
//28'b0101111101011110000100000000;

	 
reg[31:0] cnt;

always@(posedge clk_in)
begin
	if (rst==1) begin
		cnt <= 0;
		divided_clk <= 0;
	end
	else begin
		if (cnt==toggle_value) begin
			cnt <= 0;
			divided_clk <= ~divided_clk;
		end
		else begin
			cnt <= cnt +1;
			divided_clk <= divided_clk;		
		end
	end

end
			  
	


endmodule