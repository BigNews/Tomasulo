`timescale 10ps / 100fs

module regstatus (
	//input wire[5:0] operatorType,
	input wire[4:0] reg1,
	input wire[4:0] reg2,
	
	input wire writeEnable,
	input wire[5:0] writedata,
	input wire[4:0] writeIndex,
	
	input wire[4:0] ROBindex,
	output reg[5:0] ROBstatus,
	
	output reg[5:0] q1,
	output reg[5:0] q2,
	
	input wire regStatusEnable, 
	output reg funcUnitEnable
);

reg[5:0] status[0:31];
integer i;

initial begin
	funcUnitEnable = 1'b0;
	for (i = 0; i < 32; i=i+1) begin
		status[i] = 6'b010000;
	end
	q1 = 6'b010000;
	q2 = 6'b010000;
end

always @(ROBindex) begin
	if (ROBstatus < 16) begin
		ROBstatus = status[ROBindex];
	end
	else ROBstatus = 6'b010000;
end

always @(posedge writeEnable) begin
	status[writeIndex] = writedata;
	
	if (reg1 < 32) begin
		q1 = status[reg1];
	end
	else q1 = 6'b010000;
	if (reg2 < 32) begin
		q2 = status[reg2];
	end
	else q2 = 6'b010000;
	if (ROBstatus < 16) begin
		ROBstatus = status[ROBindex];
	end
	else ROBstatus = 6'b010000;
end

always @(posedge regStatusEnable) begin
	funcUnitEnable = 1'b0;
	
	//$display("regstatus: reg1 = %b %b, reg2 = %b %b", reg1, reg2, status[reg1], status[reg2]);

	if (reg1 < 32) begin
		q1 = status[reg1];
	end
	else q1 = 6'b010000;
	if (reg2 < 32) begin
		q2 = status[reg2];
	end
	else q2 = 6'b010000;
	
	#0.01
	funcUnitEnable = 1'b1;
end

endmodule