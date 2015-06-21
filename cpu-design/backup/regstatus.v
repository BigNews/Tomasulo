module regstatus (
	input wire[5:0] operatorType,
	input wire[4:0] reg1,
	input wire[4:0] reg2,
	input wire writeEnable,
	input wire[5:0] writedata,
	input wire[5:0] writeIndex,
	
	output reg[5:0] q1,
	output reg[5:0] q2
);

reg[5:0] status[0:31];
integer i;

initial begin
	for (i = 0; i < 32; i=i+1) begin
		status[i] = 6'b010000;
	end
end

always @(reg1 or reg2 or posedge writeEnable) begin
	if (writeEnable == 1'b1) begin
		status[writeIndex] = writedata;
	end
	if (reg1 < 32) begin
		q1 = status[reg1];
	end
	if (reg2 < 32) begin
		q2 = status[reg2];
	end
end

endmodule