/*
	50:50 busy
	49:44 dest
	43:38 operator
	37:6 data
	5:0 q
*/

`timescale 10ps / 100fs

module loadRS(
	input wire clock,
	input wire[5:0] operatorType,
	input wire[31:0] data,
	input wire[5:0] q,
	//input wire[5:0] robNum_in,
	input wire[5:0] destRobNum,
	
	input wire reset,
	
	output reg[5:0] robNum_out,
	output reg[31:0] data_out,
	output reg available,
	
	input wire cdbIscast,
	input wire[31:0] cdbdata,
	input wire[5:0] cdbRobNum,
	input wire cdbIscast2,
	input wire[31:0] cdbdata2,
	input wire[5:0] cdbRobNum2,
	
	output reg[5:0] index,
	input wire ready,
	input wire[31:0] value,
	
	//input wire[31:0] address, // reset busy bit
	input wire[31:0] offset_in,
	
	
	input wire busy,
	
	input wire funcUnitEnable,
	output reg loadEnable
);

parameter lwOp = 6'b000110;
parameter invalidNum = 6'b010000;

reg[50:0] rs[0:3];
reg[31:0] offset[0:3];
reg[5:0] robNum[0:3];
integer i;

initial begin
	for (i = 0;i < 4; i=i+1) begin
		rs[i] = {51{1'b0}};
		offset[i] = 32'b0;
		robNum[i] = 6'b0;
	end
	available = 1'b1;
	loadEnable = 1'b0;
end

/*always @(rsnum) begin
	for (i = 0;i < 4; i = i+1) begin
		if (rs[i][50:50] == 1'b1 and rs[i][37:6] == address) begin
			rs[i][50:50] = 1'b0;
			break;
		end
	end
end*/

reg breakmark;

always @(posedge reset) begin
	robNum_out = invalidNum;
	for (i = 0;i < 4; i=i+1) begin
		rs[i][50:50] = 1'b0;
	end
	available = 1'b1;
end

always @(posedge clock) begin
	#50
	breakmark = 1'b0;
	loadEnable = 1'b0;
	//#0.01
	//loadEnable = 1'b1;
	for (i = 0;i < 4; i=i+1) begin
		//$display($time, "%d %d", rs[i], offset[i]);
		//$display($time, "  dsfewrwer  %d %b %b", i, busy, rs[i][50:50]);
		if (rs[i][50:50] == 1'b1 && breakmark == 1'b0 && busy == 1'b0) begin
			//$display($time, "  dsf  %b %b", rs[i], offset[i]);
			if (rs[i][5:0] == invalidNum) begin
				//$display($time, "%b %b", rs[i], offset[i]);
				data_out = rs[i][37:6]+offset[i];
				//$display($time, "Let me see see : %d", offset[i]);
				robNum_out = robNum[i];
				
				//$display($time, ": (loadRS loadRS) data_out: %h, robNum_out: %b", data_out, robNum_out);
				
				rs[i][50:50] = 1'b0;
				available = 1'b1;
				breakmark = 1'b1;
				loadEnable = 1'b1;
			end
		end
	end
	loadEnable = 1'b0;
end

always @(posedge cdbIscast or posedge cdbIscast2) begin
	for (i = 0;i < 4; i=i+1) begin
		if (rs[i][50:50] == 1'b1 && cdbIscast == 1'b1) begin
			if (rs[i][5:0] == cdbRobNum) begin
				rs[i][37:6] = cdbdata;
				rs[i][5:0] = invalidNum;
			end
		end
		if (rs[i][50:50] == 1'b1 && cdbIscast2 == 1'b1) begin
			if (rs[i][5:0] == cdbRobNum2) begin
				rs[i][37:6] = cdbdata2;
				rs[i][5:0] = invalidNum;
			end
		end
	end
end

reg[31:0] data_tmp;
reg[5:0] q_tmp;

always @(posedge funcUnitEnable) begin

	//$display($time, "loadopType = %d", operatorType);

	if (operatorType == lwOp) begin
		//robNum_out = destRobNum;
		index = q;
		#0.01
		data_tmp = data;
		q_tmp = q;
		if (index < 16 && ready == 1'b1) begin
			data_tmp = value;
			q_tmp = invalidNum;
		end
		index = invalidNum;
		
		//$display($time, ": index = %b, data = %b,  q = %b", index, data, q);
		
		breakmark = 1'b0;
		for (i = 0;i < 4; i = i+1) begin
			if (rs[i][50:50] == 1'b0 && breakmark == 1'b0) begin
				//$display($time, " full = ", i);
				robNum[i] = destRobNum;
				offset[i] = offset_in;
				//$display("%d", offset[i]);
				rs[i][50:50] = 1'b1;
				//rs[i][49:44] = robNum;
				rs[i][43:38] = operatorType;
				rs[i][37:6] = data_tmp;
				rs[i][5:0] = q_tmp;
				breakmark = 1'b1;
			end
		end
		
		available = 1'b0;
		breakmark = 1'b0;
		for (i = 0; i < 4; i = i+1) begin
			if (rs[i][50:50] == 1'b0 && breakmark == 1'b0) begin
				available = 1'b1;
				breakmark = 1'b1;
			end
		end
	end
end

endmodule