`timescale 10ps / 100fs

module test;

CPU cpu();

initial begin
	$dumpfile("cpu.vcd");
	$dumpvars(0,cpu);
end

endmodule