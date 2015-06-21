`timescale 1ns/10ps

module test;

reg[31:0] tmp[0:200];
reg[63:0] mem[0:200];
reg clock;
reg[16:0] cnt;

parameter step = 10;
integer i;

initial begin
	$readmemh("data.txt",tmp,0);
	clock = 1;
	cnt = 0;
	for (i = 0;i <= 50;i=i+1) begin
		mem[i] = {tmp[i*2+0],tmp[i*2+1]};
	end
end

always #step begin
	clock = ~clock;
end

always @(posedge clock) begin
	if (cnt == 51) $finish;
	
	$display("%d %d", mem[cnt][63:32],
		mem[cnt][31:0]);
	cnt = cnt + 1;
end

endmodule