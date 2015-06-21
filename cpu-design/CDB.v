`timescale 10ps / 100fs

module CDB(
	//input wire clock,
	input wire enable,
	input wire[5:0] robNum,
	input wire[31:0] data,
	
	output reg iscast_out,
	output reg[5:0] robNum_out,
	output reg[31:0] data_out
);

parameter invalidNum = 6'b010000;

initial begin
	iscast_out = 0;
end

always @(posedge enable) begin
	iscast_out = 0;
	robNum_out = robNum;
	data_out = data;
	iscast_out = 1;
	#0.1
	iscast_out = 0;
end

endmodule