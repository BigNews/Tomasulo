`timescale 1ns/10ps

module or_test;

	reg[31:0] cnt;
	
	reg[31:0] a, b;
	
	initial begin
		cnt = 32'b0;
		a = 32'b0;
		b = 32'b0;
		$display($time, "initial: a = %d  b = %d  cnt = %d", a, b, cnt);
	end
	
	always @(a) begin
	   cnt = cnt + 1;
	   $display($time, ": cnt updated: %d", cnt);
	end
	
	always @(a) begin
	   cnt = cnt + 1;
	   $display($time, ": cnt updated: %d", cnt);
	end
	
	always #10 begin
	   a = a + 1;
	   #0.01
	   b = cnt;
	   $display($time, ": a updated: %d", a);
	   $display($time, ": b updated: %d", b);
	end
	
	initial #100 begin
	   $display($time, ": a = %d     b = %d", a, b);
	   $display($time, ": cnt = %d", cnt);
	   $finish;
	end

endmodule