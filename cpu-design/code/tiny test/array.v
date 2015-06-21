module array(input wire[5:0] index, input wire[31:0] writeData, input wire writeEnable);

	reg[31:0] data[0:31];
	
	always @(posedge writeEnable) begin
		data[index] = writeData;
	end

	integer i;
	initial #100 begin
		for (i = 0; i < 32; ++i)
			$display("data[%d] = %d", i, data[i]);
		$finish;
	end

endmodule