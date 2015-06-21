/*
	88:88 busy
	87:82 dest
	81:76 operator
	75:44 data1
	43:12 data2
	11:6 q1
	5:0 q2
*/

`timescale 10ps / 100fs

module bneRS (
	input wire clock,
	input wire[5:0] operatorType,
	input wire[5:0] robNum,
	input wire[31:0] data1,
	input wire[31:0] data2,
	input wire[5:0] q1,
	input wire[5:0] q2,
	input wire reset,
	
	input wire CDBiscast,
	input wire[5:0] CDBrobNum,
	input wire[31:0] CDBdata,
	
	input wire CDBiscast2,
	input wire[5:0] CDBrobNum2,
	input wire[31:0] CDBdata2,
	
	output reg[5:0] robNum_out,
	
	output reg bneResultEnable,
	output reg[31:0] data_out,
	output reg available,
	
	output reg[5:0] index,
	input wire ready,
	input wire[31:0] value,
	input wire funcUnitEnable
);

parameter bneOp = 6'b001000;
parameter invalidNum = 6'b010000;

reg[88:0] rs[0:3];
integer i;
//reg busy;
reg breakmark;

initial begin
	bneResultEnable = 1'b0;
	for (i = 0;i < 4; i=i+1) begin
		rs[i] = {89{1'b0}};
	end
	available = 1'b1;
	index = invalidNum;
	//busy = 1'b0;
end

always @(posedge reset) begin
	robNum_out = invalidNum;
	for (i = 0;i < 4; i=i+1) begin
		rs[i][88:88] = 1'b0;
	end
	available = 1'b1;
end

always @(posedge CDBiscast or posedge CDBiscast2) begin
	for (i = 0;i < 4; i=i+1) begin
		//$display("need1 = %b  need2 = %b  bus1 = %b cdb1cast = %b", rs[i][11:6], rs[i][5:0], CDBrobNum, CDBiscast);
		if (rs[i][88:88] == 1'b1 && CDBiscast == 1'b1) begin
			if (rs[i][11:6] == CDBrobNum) begin
				rs[i][75:44] = CDBdata;
				rs[i][11:6] = invalidNum;
				//$display("affected by 1");
			end
			if (rs[i][5:0] == CDBrobNum) begin
				rs[i][43:12] = CDBdata;
				rs[i][5:0] =  invalidNum;
				//$display("affected by 2");
			end
		end
		
		if (rs[i][88:88] == 1'b1 && CDBiscast2 == 1'b1) begin
			if (rs[i][11:6] == CDBrobNum2) begin
				rs[i][75:44] = CDBdata2;
				rs[i][11:6] = invalidNum;
				//$display("affected by 3");
			end
			if (rs[i][5:0] == CDBrobNum2) begin
				rs[i][43:12] = CDBdata2;
				rs[i][5:0] =  invalidNum;
				//$display("affected by 4");
			end
			/*if (rs[i][5:0] == invalidNum and rs[i][11:6] == invalidNum) begin
				rs[i][88:88] = 1'b0;
				data_out = rs[i][75:44]+rs[i][43:12];
				broadcast = 1'b1;
				available = 1'b1;
			end*/
		end
	end
end

always @(posedge clock) begin
	#50
	//broadcast = 1'b0;
	//busy = 1'b1;
	breakmark = 1'b0;
	//robNum_out = robNum;
	bneResultEnable = 1'b0;
	for (i = 0;i < 4; i = i+1) begin
		if (rs[i][88:88] == 1'b1 && breakmark == 1'b0) begin
			//$display($time, "sdfadsfsdafsadfdsa");
			if (rs[i][11:6] == invalidNum && rs[i][5:0] == invalidNum) begin
				//$display($time, "I'm coming!!!");
				//$display($time, "I'm coming!!!");
				rs[i][88:88] = 1'b0;
				//data_out = rs[i][75:44]+rs[i][43:12];
				if (rs[i][75:44] == rs[i][43:12]) data_out = 32'b0;
				else data_out = 32'b1;
				robNum_out = rs[i][87:82];
				bneResultEnable = 1'b1;
				available = 1'b1;
				breakmark = 1'b1;
			end
		end
	end
end

reg[31:0] data1_tmp;
reg[5:0] q1_tmp;
reg[31:0] data2_tmp;
reg[5:0] q2_tmp;

always @(posedge funcUnitEnable) begin
	if (operatorType == bneOp) begin
		/*if (q1 == invalidNum and q2 == invalidNum) begin
			data_out <= data1+data2;
			broadcast <= 1'b1;
		end else */
		begin
			
			index = q1;
			#0.01
			data1_tmp = data1;
			q1_tmp = q1;
			//$display($time, "  cdfassadf: %b %b", q1_tmp, ready);
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
			
			/*if (q1 == invalidNum and q2 == invalidNum) begin
				data_out <= data1+data2;
				broadcast <= 1'b1;
			end else */
				//broadcast <= 1'b0;
				breakmark = 1'b0;
				for (i = 0; i < 4; i=i+1) begin
					if (rs[i][88:88] == 1'b0 && breakmark == 1'b0) begin
						rs[i][88:88] = 1'b1;
						rs[i][87:82] = robNum;
						rs[i][81:76] = operatorType;
						rs[i][75:44] = data1_tmp;
						rs[i][43:12] = data2_tmp;
						rs[i][11:6] = q1_tmp;
						rs[i][5:0] = q2_tmp;
						//$display("chayedan: %b %b %b %b %b %b", robNum, operatorType, data1_tmp, data2_tmp, q1_tmp, q2_tmp);
						breakmark = 1'b1;
					end
				end
				available = 1'b0;
				for (i = 0; i < 4; i=i+1) begin
					if (rs[i][88:88] == 1'b0) begin
						available = 1'b1;
					end
				end
		end
	end
end

endmodule