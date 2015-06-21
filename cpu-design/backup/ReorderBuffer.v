`timescale 1ns / 10ps
module ReorderBuffer(
					input wire clk,					

					input wire[5:0] issue_opType, 
					//input wire[31:0] issue_data1, 
					input wire[31:0] issue_data2, input wire[31:0] issue_pc, 
					//input wire[4:0] issue_reg1, input wire[4:0] issue_reg2, 
					input wire[4:0] issue_destReg,	
					input wire issueValid,
					//issue
					
					input wire[5:0] indexIn, output reg[31:0] result, output reg readyOut,	output reg available,//Grab informations
					
					input wire[31:0] trans, input wire[31:0] offset,
					
					output reg[31:0] destOut,  output reg[31:0] valueOut, output reg avail, 
					
					output reg statusWriteEnable, output reg[5:0] statusWriteIndex, output reg[5:0] statusWriteData,
					
					input wire[1:0] branchPrediction,
					output reg[31:0] branchAddr,
					
					output reg[31:0] branchWriteAddr, output reg branchWriteEnable, output reg[1:0] branchWriteData,
					
					output reg[31:0] issueNewPC, output reg issueNewPCEnable, output reg resetAll
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
	
	
	reg[4:0] count;
	
	//queue head & tail
	reg[4:0] head, tail;
	
	integer i;
	initial begin
		head = 5'b00000;
		tail = 5'b00000;
		issueNewPCEnable = 1'b0;
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
	end
	
	//Fetch decoded instructions
	always @(posedge issueValid) begin
		
		count = count + 1;
		if (count >= 16) available = 0;
		
		opcode[tail] = issue_opType;
		instAddr[tail] = issue_pc;
		ready[tail] = 1'b0;
		
		case (issue_opType)
			
			addOp, subOp, sllOp, srlOp, mulOp: begin
				dest[tail] = {27'b0, issue_destReg};
				//src1[tail] = {27{1'b0}, issue_reg1};	
				//src2[tail] = {27{1'b0}, issue_reg2};
			end
			
			addiOp, lwOp: begin
				dest[tail] = {27'b0, issue_destReg};
				//src1[tail] = {27{1'b0}, issue_reg1};
				//src2[tail] = data2;
			end
			
			swOp: begin
				//dest[tail] = {32'hFFFFFFFF};
				//src1[tail] = 
			end
			
			bneOp: begin
				dest[tail] = issue_data2;
				//dest[tail] = {}
			end
			
		endcase
		
		tail = tail + 1;
		if (tail >= 16) tail = tail - 16;
	end
	
	//Commit		will do after 160nanoseconds
	always @(posedge clk) begin
		#120 begin
			resetAll = 0;
			statusWriteEnable = 1'b0;
			branchWriteEnable = 1'b0;
			issueNewPC = 1'b0;
			branchAddr = 32'hFFFFFFFF;
			if (ready[head] == 1'b1) begin
				case (opcode[head])
					addOp, subOp, sllOp, srlOp, mulOp, addiOp, lwOp: begin
						statusWriteIndex = dest[head][5:0];
						statusWriteData = 5'b10000;
						statusWriteEnable = 1'b1;
					end
					
					swOp: begin
						//Need Cash
					end
					
					bneOp: begin
						branchAddr = instAddr[head];
						//Waiting for branchPredictor's reply;
						#1  begin
							tempPrediction = branchPrediction;
							if ((tempPrediction <= 1 && value[head] != 0) || (tempPrediction >= 2 && value[head] == 0)) begin
								//Clean the register status
								for (i = 0; i < 32; ++i) begin
									statusWriteIndex = i[5:0];
									statusWriteData = 5'b10000;
									statusWriteEnable = 1'b1;
									#1 statusWriteEnable = 1'b0;
								end
								
								resetAll = 1;
								resetAll = 0;
								
								tail = head + 1;
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
					
				endcase
			end
			statusWriteEnable = 1'b0;
			branchWriteEnable = 1'b0;
			resetAll = 0;
		end
	end
	
	//Query from reservation station.
	always @(indexIn) begin
		if (indexIn === 16) begin
			result = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
		end
		else begin
			result = value[indexIn];
		end
	end
	
	
	
	
	
endmodule