`timescale 10ps / 100fs

module loadUnit(
	input wire clock,
	
	input wire loadEnable,
	input wire[31:0] addr,
	input wire[5:0] robNum,
	
	output reg[31:0] addr_out,
	input wire hit,
	input wire[31:0] data_in,
	
	output reg cdbEnable,
	output reg[5:0] robNum_out,
	output reg[31:0] cdbdata,
	output reg busy
);



initial begin
	cdbEnable = 1'b0;
	busy = 1'b0;
end

always @(posedge loadEnable) begin
	addr_out = addr;
	busy = 1'b1;
end

always @(posedge clock) begin
	cdbEnable = 1'b0;
	if (hit == 1'b1) begin
		robNum_out = robNum;
		cdbdata = data_in;
		
		//$display($time, ": robNum: %b, cdbdata = %h, addr = %h", robNum, cdbdata, addr_out);
		
		cdbEnable = 1'b1;
		busy = 1'b0;
	end
end

endmodule