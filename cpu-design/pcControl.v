`timescale 10ps / 100fs

module pcControl(
	input wire clock,
	input wire addempty,
	input wire lwempty,
	input wire swempty,
	input wire robempty,
	input wire bneempty,
	input wire[5:0] operatorType,
	
	output reg available,
	output reg[31:0] pc,
	output reg decodePulse,
	
	input wire jump,
	input wire[31:0] jumppc,
	
	input wire pcChange,
	input wire[31:0] changeData
);

parameter bneOp = 6'b001000;

integer count;

initial begin
	pc = {32{1'b1}};
	available = 1'b1;
	decodePulse = 1'b0;
	
	count = 200;
end

/*always @(operatorType) begin
	if (operatorType == bneOp) begin
		pc_bp = pc;
		#0.01
		if (jump == 1) begin
			pc = jumppc;
		end
	end
end*/

always @(posedge clock) begin
	//pc = pc + 1;
	if (count > 0) begin
	    count = count - 1;
	end
	else begin
		available = addempty & lwempty & swempty & robempty & bneempty;
		
		if (pcChange == 1'b1) begin 
			pc = changeData - 1;
		end else 
		begin
			if (operatorType == bneOp) begin
				if (jump == 1) begin
					pc = jumppc - 1;
				end
			end
		end
		if (available == 1) begin
			decodePulse = 1'b0; 
			pc = pc + 1;
			
			decodePulse = 1'b1;
		end
	end
	//$display($time, ": op = %b  pc = %d", operatorType, pc);
end

/*always @(addempty or lwempty or swempty or robempty or pcChange) begin
	if (pcChange == 1'b1) begin
		pc = changeData;
	end else begin
		available = addempty & lwempty & swempty & robempty;
		if (available == 1'b0) begin
			pc = pc-1;
		end
	end
end*/

endmodule