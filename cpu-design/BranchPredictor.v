`timescale 10ps / 100fs

module branchPredictor(
						//Branch Write
						input wire branchWriteEnable, input wire[1:0] branchWriteData, input wire[31:0] branchWriteAddr,
						
						//Branch Read for PC
						input wire[31:0] branchPCReadAddr, output reg branchPCPredict,
						
						//Branch Read for ROB
						input wire[31:0] branchROBReadAddr, output reg[1:0] branchROBPredict
						);
		
	//local memories.
	
	reg[1:0] perAddr0[0:1023], perAddr1[0:1023], perAddr2[0:1023], perAddr3[0:1023];
	reg[1:0] global[0:1];
	
	integer i;
	initial begin
		//branchPCReadAddr = 32'h00000000;
		//branchROBReadAddr = 32'h00000000;
		for (i = 0; i < 1024; ++i) begin
			perAddr0[i] = 2'b00;
			perAddr1[i] = 2'b00;
			perAddr2[i] = 2'b00;
			perAddr3[i] = 2'b00;
		end
		global[0] = 2'b00;
		global[1] = 2'b00;
		/*for (i = 0; i < 1024; ++i) begin
			perAddr0[i] = 2'b11;
			perAddr1[i] = 2'b11;
			perAddr2[i] = 2'b11;
			perAddr3[i] = 2'b11;
		end
		global[0] = 2'b11;
		global[1] = 2'b11;*/
	end
	
	always @(branchPCReadAddr or branchROBReadAddr) begin
		if (global[0] <= 1) begin
			if (global[1] <= 1) begin
				branchPCPredict = perAddr0[branchPCReadAddr][1:1];
				branchROBPredict = perAddr0[branchROBReadAddr];
			end
			else begin
				branchPCPredict = perAddr2[branchPCReadAddr][1:1];
				branchROBPredict = perAddr2[branchROBReadAddr];
			end
		end
		else begin
			if (global[1] <= 1) begin
				branchPCPredict = perAddr1[branchPCReadAddr][1:1];
				branchROBPredict = perAddr1[branchROBReadAddr];
			end
			else begin
				branchPCPredict = perAddr3[branchPCReadAddr][1:1];
				branchROBPredict = perAddr3[branchROBReadAddr];
			end
		end
	end
	
	always @(posedge branchWriteEnable) begin
		if (global[0] <= 1) begin
			if (global[1] <= 1) begin
				perAddr0[branchWriteAddr] = branchWriteData;
			end
			else begin
				perAddr2[branchWriteAddr] = branchWriteData;
			end
		end
		else begin
			if (global[1] <= 1) begin
				perAddr1[branchWriteAddr] = branchWriteData;
			end
			else begin
				perAddr3[branchWriteAddr] = branchWriteData;
			end
		end
		global[1] = global[0];
		global[0] = branchWriteData;
		
		if (global[0] <= 1) begin
			if (global[1] <= 1) begin
				branchPCPredict = perAddr0[branchPCReadAddr][1:1];
				branchROBPredict = perAddr0[branchROBReadAddr];
			end
			else begin
				branchPCPredict = perAddr2[branchPCReadAddr][1:1];
				branchROBPredict = perAddr2[branchROBReadAddr];
			end
		end
		else begin
			if (global[1] <= 1) begin
				branchPCPredict = perAddr1[branchPCReadAddr][1:1];
				branchROBPredict = perAddr1[branchROBReadAddr];
			end
			else begin
				branchPCPredict = perAddr3[branchPCReadAddr][1:1];
				branchROBPredict = perAddr3[branchROBReadAddr];
			end
		end
	end
		
						
endmodule