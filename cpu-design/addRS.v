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

module addRS (
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

	output reg[31:0] data_out,
	output reg broadcast,
	output reg available,
	
	output reg[5:0] index,
	input wire ready,
	input wire[31:0] value,
	
	input wire funcUnitEnable
);

parameter addOp = 6'b000000;
parameter addiOp = 6'b000001;
parameter subOp = 6'b000010;
parameter sllOp = 6'b000011;
parameter srlOp = 6'b000100;
parameter mulOp = 6'b000101;
parameter lwOp = 6'b000110;
parameter swOp = 6'b000111;
parameter bneOp = 6'b001000;
parameter liOp = 6'b001001;
parameter invalidNum = 6'b010000;

reg[88:0] rs[0:3];
integer i;
//reg busy;
reg breakmark;

initial begin
	broadcast = 1'b0;
	for (i = 0;i < 4; i=i+1) begin
		rs[i] = {89{1'b0}};
	end
	available = 1'b1;
	index = invalidNum;
	//busy = 1'b0;
end

always @(posedge reset) begin
	broadcast = 1'b0;
	robNum_out = invalidNum;
	for (i = 0;i < 4; i=i+1) begin
		rs[i][88:88] = 1'b0;
	end
	available = 1'b1;
end

always @(posedge CDBiscast or posedge CDBiscast2) begin
	for (i = 0;i < 4; i=i+1) begin
		if (rs[i][88:88] == 1'b1 && CDBiscast == 1'b1) begin
			if (rs[i][11:6] == CDBrobNum) begin
				rs[i][75:44] = CDBdata;
				rs[i][11:6] = invalidNum;
			end
			if (rs[i][5:0] == CDBrobNum) begin
				rs[i][43:12] = CDBdata;
				rs[i][5:0] =  invalidNum;
			end
		end
		
		if (rs[i][88:88] == 1'b1 && CDBiscast2 == 1'b1) begin
			if (rs[i][11:6] == CDBrobNum2) begin
				rs[i][75:44] = CDBdata2;
				rs[i][11:6] = invalidNum;
			end
			if (rs[i][5:0] == CDBrobNum2) begin
				rs[i][43:12] = CDBdata2;
				rs[i][5:0] =  invalidNum;
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
	broadcast = 1'b0;
	//busy = 1'b1;
	breakmark = 1'b0;
	//robNum_out = robNum;
	for (i = 0;i < 4; i = i+1) begin
		if (rs[i][88:88] == 1'b1 && breakmark == 1'b0) begin
			if (rs[i][11:6] == invalidNum && rs[i][5:0] == invalidNum) begin
				rs[i][88:88] = 1'b0;
				robNum_out = rs[i][87:82];
				
				if (rs[i][81:76] == addOp) data_out = rs[i][75:44]+rs[i][43:12];
				else if (rs[i][81:76] == addiOp) data_out = rs[i][75:44]+rs[i][43:12];
				else if (rs[i][81:76] == subOp) data_out = rs[i][75:44]-rs[i][43:12];
				else if (rs[i][81:76] == mulOp) begin
					$display("data1 = %d, data2 = %d", rs[i][75:44], rs[i][43:12]);
					data_out = rs[i][75:44]*rs[i][43:12];
				end
				else if (rs[i][81:76] == srlOp) data_out = rs[i][75:44]>>rs[i][43:12];
				else if (rs[i][81:76] == sllOp) data_out = rs[i][75:44]<<rs[i][43:12];
				
				broadcast = 1'b1;
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
	if (operatorType == addOp || operatorType == addiOp || operatorType == subOp || operatorType == mulOp || operatorType == srlOp || operatorType == sllOp) begin
		/*if (q1 == invalidNum and q2 == invalidNum) begin
			data_out <= data1+data2;
			broadcast <= 1'b1;
		end else */
		
		begin
			
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
			if (operatorType == addOp || operatorType == mulOp) begin
				q2_tmp = q2;
				if (index < 16 && ready == 1'b1) begin
					data2_tmp = value;
					q2_tmp = invalidNum;
				end
			end
			else q2_tmp = invalidNum;
			
			//if (operatorType == mulOp) $display($time, ": hello! data1_tmp = %d, data2_tmp = %d", data1_tmp, data2_tmp);
			
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