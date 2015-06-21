`timescale 10ps / 100fs

module instructionDecode(
	input wire clock,
	input wire decodePulse,
	input wire[31:0] instr,
	input wire available,
	
	output reg[5:0] operatorType,
	output reg[31:0] data1,
	output reg[31:0] data2,
	output reg[31:0] instr_out,
	output reg[4:0] reg1,
	output reg[4:0] reg2,
	output reg[4:0] destreg,
	
	output reg notfull,
	output reg ROBissueValid,
	
	output reg regstatusEnable
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

reg ava;

initial begin
	ROBissueValid = 1'b0;
	regstatusEnable = 1'b0;
end

always @(posedge clock) begin
	ROBissueValid = 1'b0;
end

always @(posedge decodePulse) begin
	regstatusEnable = 1'b0;

    operatorType = 6'b111111;
	//reg1 = 0; reg2 = 0;
	//data1 = 
	//ROBissueValid = 1'b0;
	ava = available;
	notfull = ava;
	if (ava == 1'b1) begin
		if (instr[31:26] == 6'b000000) begin
			if (instr[5:0] == 6'b100000) begin
				operatorType = addOp;
			end
			if (instr[5:0] == 6'b100010) begin
				operatorType = subOp;
			end
			if (instr[5:0] == 6'b000000) begin
				operatorType = sllOp;
			end
			if (instr[5:0] == 6'b000010) begin
				operatorType = srlOp;
			end
		end
		
		if (instr[31:26] == 6'b001000) begin
			operatorType = addiOp;
		end
		
		if (instr[31:26] == 6'b011100) begin
			if (instr[5:0] == 6'b000010) begin
				operatorType = mulOp;
			end
		end
		
		//$display($time, "lwOp pending %b", instr);
		if (instr[31:26] == 6'b100011) begin
			operatorType = lwOp;
		end
		
		if (instr[31:26] == 6'b101011) begin
			operatorType = swOp;
		end
		
		if (instr[31:26] == 6'b110000) begin
			operatorType = liOp;
		end
		
		if (instr[31:26] == 6'b000101) begin
			operatorType = bneOp;
		end
		
		//$display($time, ": %b %b", operatorType, instr);
		
		instr_out = instr;
		
		if (operatorType == addiOp) begin
			destreg = instr[25:21];
			reg1 = instr[20:16];
			data2 = {{16{1'b0}},{instr[15:0]}};
		end
		
		if (operatorType == addOp) begin
			reg1 = instr[25:21];
			reg2 = instr[20:16];
			destreg = instr[15:11];
		end
		
		if (operatorType == mulOp) begin
			reg1 = instr[25:21];
			reg2 = instr[20:16];
			destreg = instr[15:11];
		end
		
		if (operatorType == lwOp) begin
			destreg = instr[25:21];
			reg1 = instr[20:16];
			data2 = instr[15:0];
		end
		
		if (operatorType == swOp) begin
			reg1 = instr[25:21];
			reg2 = instr[20:16];
			data2 = instr[15:0];
		end
		
		if (operatorType == bneOp) begin
			reg1 = instr[25:21];
			reg2 = instr[20:16];
			data2 = instr[15:0];
		end
		
		if (operatorType == liOp) begin
			destreg = instr[25:21];
			reg1 = instr[20:16];
			data2 = instr[15:0];
		end
		
		regstatusEnable = 1'b1;
		ROBissueValid = 1'b1;
		//$display("regstatus: destreg = %b, reg1 = %b, reg2 = %b", destreg, reg1, reg2);
	end
end

endmodule