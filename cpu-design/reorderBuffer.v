`timescale 10ps / 100fs

module reorderBuffer(
					input wire clk,					

					input wire[5:0] issue_opType, 
					input wire[31:0] issue_data2, input wire[31:0] issue_pc, 
					input wire[4:0] issue_destReg,	
					input wire issueValid,
					//issue
					
					input wire[5:0] adderIndexIn, output reg[31:0] adderResult, output reg adderReadyOut,
					input wire[5:0] loadIndexIn, output reg[31:0] loadResult, output reg loadReadyOut,
					input wire[5:0] saveIndexIn, output reg[31:0] saveResult, output reg saveReadyOut,
					input wire[5:0] bneIndexIn, output reg[31:0] bneResult, output reg bneReadyOut,
					
					output reg available,//Grab informations
					
					output reg statusWriteEnable, output reg[4:0] statusWriteIndex, output reg[5:0] statusWriteData,
					
					output reg cacheWriteEnable, output reg[31:0] cacheWriteData, output reg[31:0] cacheWriteAddr, input wire cacheWriteDone,
					
					input wire[1:0] branchPrediction,
					output reg[31:0] branchAddr,
					
					output reg[31:0] branchWriteAddr, output reg branchWriteEnable, output reg[1:0] branchWriteData,
					
					output reg[31:0] issueNewPC, output reg issueNewPCEnable, 
					
					output reg resetAll,
					
					input wire storeEnable, input wire[5:0] storeRobIndex, input wire[31:0] storeDest, input wire[31:0] storeValue, 
					
					//CDB
					input wire CDBisCast1, input wire[5:0] CDBrobNum1, input wire[31:0] CDBdata1, 
					input wire CDBisCast2, input wire[5:0] CDBrobNum2, input wire[31:0] CDBdata2,
					
					//Index Provider
					output wire[5:0] space,
					
					output reg regWriteEnable, output reg[4:0] regWriteIndex, output reg[31:0] regWriteData,
					
					output reg[4:0] statusIndex, input wire[5:0] statusResult, 
					
					input wire cataclysm,
					
					input wire[31:0] bneWriteResult, input wire bneWriteEnable, input wire[5:0] bneWriteIndex,
					
					output reg worldEnd
					 );
					 
	//Parameters
	parameter addOp = 6'b000000;
	parameter addiOp = 6'b000001;
	parameter subOp = 6'b000010;
	parameter sllOp = 6'b000011;
	parameter srlOp = 6'b000100;
	parameter mulOp = 6'b000101;
	parameter lwOp = 6'b000110;
	parameter swOp = 6'b000111;
	parameter bneOp = 6'b001000;
	parameter catastrophe = 6'b111111;
	//parameter liOp = 6'b001001;
					 
	//Reorder buffer Data
	reg[31:0]	instAddr[0:15];
	reg[5:0] 	opcode[0:15];
	reg[31:0] 	value[0:15];
	reg[31:0] 	dest[0:15];
	//reg[31:0] 	src1[0:15];
	//reg[31:0] 	src2[0:15];
	reg 		ready[0:15];
	reg[1:0]	tempPrediction;
	
	reg stall;
	
	//reg[5:0]	restoreStatus[0:511];
	
	reg[5:0] count;
	
	//queue head & tail
	reg[5:0] head, tail;
	
	/*******************
		Done.
	*******************/
	
	task FinishAll;
	begin
		$finish;
	end
	endtask
	/*******************/
	
	integer i;
	initial begin
		head = 6'b000000;
		tail = 6'b000000;
		
		issueNewPCEnable = 1'b0;
		regWriteEnable = 1'b0;
		branchWriteEnable = 1'b0;
		statusWriteEnable = 1'b0;
		//bneWriteEnable = 1'b0;
		
		for (i = 0; i < 15; ++i) begin
			opcode[i] = 6'b000000;
			value[i] = 32'h00000000;
			dest[i] = 32'h00000000;
			//src1[i] = 32'h00000000;
			//src2[i] = 32'h00000000;
			ready[i] = 1'b0;
			instAddr[i] = 32'h00000000;
		end
		count = 5'b00000;
		available = 1'b1;
		
		resetAll = 1'b0;
	end
	
	assign space = tail;
	
	//Fetch decoded instructions
	always @(posedge issueValid) begin
		#0.1 begin
			statusWriteEnable = 1'b0;
			
			opcode[tail] = issue_opType;
			//$display($time, "bala  %b %b", tail, issue_opType);
			instAddr[tail] = issue_pc;
			ready[tail] = 1'b0;
			
			case (issue_opType)
				
				addOp, subOp, sllOp, srlOp, mulOp: begin
					dest[tail] = {27'b0, issue_destReg};
					//src1[tail] = {27{1'b0}, issue_reg1};	
					//src2[tail] = {27{1'b0}, issue_reg2};
					statusWriteIndex = issue_destReg;
					statusWriteData = tail;
					statusWriteEnable = 1'b1;
				end
				
				addiOp, lwOp: begin
					dest[tail] = {27'b0, issue_destReg};
					//src1[tail] = {27{1'b0}, issue_reg1};
					//src2[tail] = data2;
					
					statusWriteIndex = issue_destReg;
					statusWriteData = tail;
					statusWriteEnable = 1'b1;
				end
				
				swOp: begin
					//dest[tail] = {32'hFFFFFFFF};
					//src1[tail] = 
				end
				
				bneOp: begin
					dest[tail] = issue_data2;
					
					/*for (i = 0; i < 32; ++i) begin
						statusIndex = i[4:0];
						#0.01
						restoreStatus[tail * 32 + i] = statusResult;
						//$display($time, "  READ: restoreStatus[%d] = %b || tail = %d", tail * 32 + i, restoreStatus[tail * 32 + i], tail);
					end*/
					//dest[tail] = {}
				end
				
				catastrophe: begin
					ready[tail] = 1'b1;
				end
				
			endcase
			
			tail = tail + 1;
			if (tail >= 16) tail = tail - 16;
			count = count + 1;
			if (count >= 16) available = 0;
		end
	end
	
	//Commit		will do after 160nanoseconds
	always @(posedge clk) begin
		#120 
		cacheWriteEnable = 1'b0;
		issueNewPCEnable = 1'b0;
		regWriteEnable = 1'b0;
		
		//if (cacheWriteDone == 1) begin
		
			//$display($time, "%d", )
			
			statusWriteEnable = 1'b0;
			branchWriteEnable = 1'b0;
			issueNewPC = 1'b0;
			branchAddr = 32'hFFFFFFFF;
			//$display($time, "head = %b, opcode = %b, value = %b   %d  %d  %d  %d", head, opcode[head], value[head], head, tail, count, ready[head]);
			//$display($time, "count = %d", count);
			//$display($time, ": head = %b, ready = %b", head, ready[head]);
			if (count > 0 && ready[head] == 1'b1) begin
				
				//$display($time, "head = %d   cacheWriteDone = %d", head, cacheWriteDone);
				
				
				if (cacheWriteDone == 1) begin
				case (opcode[head])
					addOp, subOp, sllOp, srlOp, mulOp, addiOp, lwOp: begin
						
						//$display($time, "add word: %d", value[head]);
						//$display($time, "BEFOREaddBacktoRegister: %b %b %d", statusIndex, head[4:0], value[head]);
						statusIndex = dest[head][4:0];
						#0.01
						//$display($time, "AFTERaddBacktoRegister: %b %b %d %d", statusResult, head, value[head], dest[head][4:0]);
						//$display($time, "Condition: %b", statusResult == head);
						
						regWriteIndex = dest[head][4:0];
						regWriteData = value[head];
						regWriteEnable = 1'b1;
						
						if (statusResult == head) begin
							statusWriteIndex = dest[head][4:0];
							statusWriteData = 5'b10000;
							statusWriteEnable = 1'b1;
						end
					end
					
					swOp: begin
						//Need Cash
						
							//$display($time, "save word: %d", value[head]);
							cacheWriteData = value[head];
							cacheWriteAddr = dest[head];
							cacheWriteEnable = 1'b1;

					end
					
					bneOp: begin
						//$display($time, "bne");
						//$display($time, "bneOp from reorderBuffer: %d", instAddr[head]);
						
						branchAddr = instAddr[head];
						//Waiting for branchPredictor's reply;
						#0.01  begin
							tempPrediction = branchPrediction;
							
							//$display($time, "bneOp from reorderBuffer predict: %b", tempPrediction);
							
							if ((tempPrediction <= 1 & value[head] != 0) | (tempPrediction >= 2 & value[head] == 0)) begin
								//$display($time, "bneOp Wrong!");
								//Clean the register status
								for (i = 0; i < 32; ++i) begin
									statusWriteIndex = i[4:0];
									statusWriteData = 6'b010000;//restoreStatus[head * 32 + i];
									//$display($time, "restoreStatus[%d] = %b || head = %d", head * 32 + i, restoreStatus[head * 32 + i], head);
									statusWriteEnable = 1'b1;
									#0.01
									statusWriteEnable = 1'b0;
								end
								
								tail = head + 1;
								count = 1;
								available = 1'b1;
								if (tail >= 16) tail = tail - 16;
								
								//misprediction handle
								if (tempPrediction <= 1) begin
									branchWriteData = {tempPrediction[0:0], 1'b1};
									issueNewPC = dest[head];
								end
								else begin
									branchWriteData = {tempPrediction[0:0], 1'b0};
									issueNewPC = instAddr[head] + 1;
								end
								
								branchWriteAddr = instAddr[head];
								branchWriteEnable = 1'b1;
								issueNewPCEnable = 1'b1;
								
								resetAll = 1'b1;
								//$display($time, "bneOp reset %b", resetAll);
							end
							else begin
								if (tempPrediction <= 1) begin
									branchWriteData = {tempPrediction[0:0], 1'b0};
								end
								else begin
									branchWriteData = {tempPrediction[0:0], 1'b1};
								end
								
								branchWriteAddr = instAddr[head];
								branchWriteEnable = 1'b1;
							end
						end
					end
					
					catastrophe: begin
						worldEnd = 1'b0;
						worldEnd = 1'b1;
						#1;
					end
					
				endcase
				//$display("%d", cacheWriteDone);
				//$display("%d", cacheWriteDone);
					//$display($time, "  commit: head = %b    %b    %d  %d", head, opcode[head], value[head], count);
					head = head + 1;
					count = count - 1;
					if (head >= 16) head = head - 16;
					//$display($time, "  Now: head = %b    %b    %d  %d", head, opcode[head], value[head], count);
					//
				end
			end
			statusWriteEnable = 1'b0;
			branchWriteEnable = 1'b0;
			regWriteEnable = 1'b0;
		//end
		
		resetAll = 1'b0;
	end
	
	//Query from reservation station.
	always @(adderIndexIn) begin
		if (adderIndexIn >= 16) begin
			adderResult = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			adderReadyOut = 1'b0;
		end
		else begin
			adderResult = value[adderIndexIn];
			adderReadyOut = ready[adderIndexIn];
		end
	end
	
	always @(loadIndexIn) begin
		if (loadIndexIn >= 16) begin
			loadResult = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			loadReadyOut = 1'b0;
		end
		else begin
			loadResult = value[loadIndexIn];
			loadReadyOut = ready[loadIndexIn];
		end
	end
	
	always @(saveIndexIn) begin
		if (saveIndexIn >= 16) begin
			saveResult = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			saveReadyOut = 1'b0;
		end
		else begin
			saveResult = value[saveIndexIn];
			saveReadyOut = ready[saveIndexIn];
		end
	end
	
	always @(bneIndexIn) begin
		if (bneIndexIn >= 16) begin
			bneResult = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			bneReadyOut = 1'b0;
		end
		else begin
			bneResult = value[bneIndexIn];
			bneReadyOut = ready[bneIndexIn];
		end
	end
	
	//Store
	always @(posedge storeEnable) begin
		//$display("%d", storeRobIndex);
		if (storeRobIndex < 16) begin
			dest[storeRobIndex] = storeDest;
			value[storeRobIndex] = storeValue;
			ready[storeRobIndex] = 1'b1;
		end
	end
	
	//CDB1
	always @(posedge CDBisCast1) begin
		if (CDBrobNum1 < 16) begin
			//$display($time, "  cdfassadf: %b %b", CDBrobNum1, CDBdata1);
			value[CDBrobNum1] = CDBdata1;
			ready[CDBrobNum1] = 1'b1;
		end
	end
	
	//CDB2
	always @(posedge CDBisCast2) begin
		if (CDBrobNum2 < 16) begin
			value[CDBrobNum2] = CDBdata2;
			ready[CDBrobNum2] = 1'b1;
		end
	end
	
	//BNE
	always @(posedge bneWriteEnable) begin
		if (bneWriteIndex < 16) begin
			value[bneWriteIndex] = bneWriteResult;
			ready[bneWriteIndex] = 1'b1;
		end
	end
	
endmodule