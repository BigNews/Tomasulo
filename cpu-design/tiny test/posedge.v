`include "array.v" 
module arrayWriter(output reg[5:0] index, output reg[31:0] data, output reg writeEnable);

	integer i;
	
	initial begin
		writeEnable = 1'b0;
		for (i = 0; i < 32; ++i) begin
			index = i[5:0];
			data = i;
			writeEnable = 1'b1;
			#0.01
			writeEnable = 1'b0;
		end
	end
	
	array array(.index(arrayWriter.index), .writeData(arrayWriter.data), .writeEnable(arrayWriter.writeEnable));
	
endmodule