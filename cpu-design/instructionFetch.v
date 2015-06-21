`timescale 10ps / 100fs

module instructionFetch (
	input wire[31:0] pc,
	
	output reg[31:0] instr,
	output reg isend
);

parameter size = 128;
reg [31:0] mem[0:size-1];

integer i;
initial begin
	$readmemb("instruction.txt", mem, 0);
	
	/*for (i = 0; i < 10; ++i) begin
		$display($time, ": %d  %b", i, mem[i]);
	end*/
	
	isend = 1'b0;
end

always @(pc) begin
	instr = mem[pc];
	if (instr[31:26] == 6'b111111) begin
		isend = 1'b1;
	end
	else isend = 1'b0;
end

endmodule