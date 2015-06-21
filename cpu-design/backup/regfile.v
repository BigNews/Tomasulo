

module regfile (
	input wire[5:0] operatorType,
	input wire[4:0] reg1,
	input wire[4:0] reg2,
	input wire[31:0] data1_in,
	input wire[31:0] data2_in,
	input wire readEnable,
	
	input wire ROBwriteEnable,
	input wire[31:0] ROBwriteData,
	input wire[4:0] ROBwriteIndex,
	
	output reg[31:0] data1,
	output reg[31:0] data2
);
	
	//Parameters
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
	
	//Registers
	reg[31:0] mem[0:31];
	integer i;

	initial begin
		for (i = 0; i < 32; i=i+1) begin
			mem[i] = {32{1'b0}};
		end
	end

	//Operation retrieves data from registers.
	always @(operatorType or reg1 or reg2 or data1_in or data2_in) begin
		if (operatorType == addiOp) begin
			data1 = mem[reg1];
			data2 = data2_in;
		end
		if (operatorType == addOp) begin
			data1 = mem[reg1];
			data2 = mem[reg2];
		end
		if (operatorType == lwOp) begin
			data1 = mem[reg1]+data2_in;
		end
		if (operatorType == swOp) begin
			data1 = mem[reg1];
			data2 = mem[reg2]+data2;
		end
		if (operatorType == bneOp) begin
			data1 = mem[reg1];
			data2 = mem[reg2];
		end
	end
	
	//Reorder buffer write back.
	always @(posedge ROBwriteEnable) begin
		mem[ROBwriteIndex] = ROBwriteData;
	end

endmodule