/*
	82:82 busy
	81:76 operator
	75:44 data1   //saved-value
	43:12 data2	  //saved-address
	11:6 q1
	5:0 q2
*/

`timescale 10ps / 100fs

module storeRS (
	input wire clock,
	input wire[5:0] operatorType,
	input wire[31:0] data1,
	input wire[5:0] q1,
	input wire[31:0] data2,
	input wire[5:0] q2,
	input reset,
	input wire[31:0] offset_in,
	input wire[5:0] destRobNum,
	
	output reg[5:0] robNum_out,
	output reg available,
	
	input wire iscast,
	input wire[31:0] cdbdata,
	input wire[5:0] robNum,
	input wire iscast2,
	input wire[31:0] cdbdata2,
	input wire[5:0] robNum2,
	
	input wire ready,
	input wire[31:0] value,
	
	output reg[31:0] data1_out,
	output reg[31:0] data2_out,
	output reg storeEnable,
	
	output reg[5:0] index,
	
	input wire funcUnitEnable
);

parameter swOp = 6'b000111;
parameter invalidNum = 6'b010000;

reg[82:0] rs[0:3];
reg[5:0] destRob[0:3];
reg[31:0] offset[0:3];
integer i;

initial begin
	for (i = 0;i < 4; i=i+1) begin
		rs[i] = 82'b0;
	end
	available = 1'b1;
	storeEnable = 1'b0;
end

always @(posedge reset) begin
	robNum_out = invalidNum;
	for (i = 0;i < 4; i = i+1) begin
		rs[i][82:82] = 1'b0;
	end
	available = 1'b1;
end

always @(posedge iscast or posedge iscast2) begin
	for (i = 0;i < 4; i=i+1) begin
		if (rs[i][82:82] == 1'b1 && iscast == 1'b1) begin
			if (rs[i][11:6] == robNum) begin
				rs[i][75:44] = cdbdata;
				rs[i][11:6] = invalidNum;
			end
			if (rs[i][5:0] == robNum) begin
				rs[i][43:12] = cdbdata;
				rs[i][5:0] = invalidNum;
			end
		end
		if (rs[i][82:82] == 1'b1 && iscast2 == 1'b1) begin
			if (rs[i][11:6] == robNum2) begin
				rs[i][75:44] = cdbdata2;
				rs[i][11:6] = invalidNum;
			end
			if (rs[i][5:0] == robNum2) begin
				rs[i][43:12] = cdbdata2;
				rs[i][5:0] = invalidNum;
			end
		end
	end
end

reg breakmark;

always @(posedge clock) begin
	breakmark = 1'b0;
	storeEnable = 1'b0;
	for (i = 0;i < 4; i=i+1) begin
		if (rs[i][82:82] == 1'b1 && breakmark == 1'b0) begin
			//$display("entered.");
			if (rs[i][11:6] == invalidNum && rs[i][5:0] == invalidNum) begin
				//$display("entered.");
				rs[i][82:82] = 1'b0;
				robNum_out = destRob[i];
				data1_out = rs[i][75:44];
				data2_out = rs[i][43:12] + offset[i];
				available = 1'b1;
				breakmark = 1'b1;
				storeEnable = 1'b1;
			end
		end
	end
end

reg[31:0] data1_tmp;
reg[5:0] q1_tmp;
reg[31:0] data2_tmp;
reg[5:0] q2_tmp;

always @(posedge funcUnitEnable) begin
	if (operatorType == swOp) begin
		robNum_out = robNum;
		
		index = q1;
		#0.01
		data1_tmp = data1;
		q1_tmp = q1;
		if (index < 16 && ready == 1'b1) begin
			data1_tmp = value;
			q1_tmp = invalidNum;
		end
		
		index = q2;
		#0.01
		data2_tmp = data2;
		q2_tmp = q2;
		if (index < 16 && ready == 1'b1) begin
			data2_tmp = value;
			q2_tmp = invalidNum;
		end
		
		index = invalidNum;
		
		breakmark = 1'b0;
		for (i = 0;i < 4; i=i+1) begin
			if (rs[i][82:82] == 1'b0 && breakmark == 1'b0) begin
				destRob[i] = destRobNum;
				offset[i] = offset_in;
				rs[i][82:82] = 1'b1;
				rs[i][81:76] = operatorType;
				rs[i][75:44] = data1_tmp;
				rs[i][43:12] = data2_tmp;
				rs[i][11:6] = q1_tmp;
				rs[i][5:0] = q2_tmp;
				breakmark = 1'b1;
			end
		end
		
		available = 1'b0;
		breakmark = 1'b0;
		for (i = 0;i < 4; i = i+1) begin
			if (rs[i][82:82] == 1'b0 && breakmark == 1'b0) begin
				available = 1'b1;
				breakmark = 1'b1;
			end
		end
	end
end

endmodule