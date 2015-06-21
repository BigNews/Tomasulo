`timescale 10ps / 100fs

module dataCache(
				input wire clk,
				
				
				//Read data 
				input wire[31:0] readAddr, output reg hit, output reg[31:0] readData, 
				//Write data
				input wire writeEnable, input wire[31:0] writeAddr, input wire[31:0] writeData, output reg writeDone,
				
				//Read Memory
				output reg[31:0] memoryReadAddr, input wire[511:0] memoryReadData, input wire memoryReadEnable,
				//Write memory
				output reg memoryWritePulse, output reg[31:0] memoryWriteData, output reg[31:0] memoryWriteAddr, input wire memoryWriteDone
				);
		
	//Storages
	reg[511:0] data[0:1023];
	reg[15:0] dataTag[0:1023];
	reg valid[0:1023];
		
	integer i;
	
	//Temporals
	reg[15:0] readTag, writeTag;
	reg[9:0] readIndex, writeIndex;
	reg[5:0] readOffset, writeOffset;
	reg[5:0] wordOffset, writeWordOffset;
	reg[31:0] reserveData, writeReserveData;
	
	//initial
	initial begin
		memoryReadAddr = 32'hxxxxxxxx;
		memoryWritePulse = 1'b0;
		memoryWriteData = 512'b0;
		memoryWriteAddr = 32'b0;
		
		for (i = 0; i < 1023; ++i) begin
			valid[i] = 1'b0;
		end
	end

	//ReadDataChanged
	always @(readAddr) begin
		hit = 0;
		readTag = readAddr[31:16];
		readIndex = readAddr[15:6];
		readOffset = readAddr[5:0];
		wordOffset = readOffset / 4 * 4;
		
		case (wordOffset)
			6'b000000: reserveData = data[readIndex][0*32+31:0*32];
			6'b000100: reserveData = data[readIndex][1*32+31:1*32];
			6'b001000: reserveData = data[readIndex][2*32+31:2*32];
			6'b001100: reserveData = data[readIndex][3*32+31:3*32];
			6'b010000: reserveData = data[readIndex][4*32+31:4*32];
			6'b010100: reserveData = data[readIndex][5*32+31:5*32]; 
			6'b011000: reserveData = data[readIndex][6*32+31:6*32];
			6'b011100: reserveData = data[readIndex][7*32+31:7*32];
			
			6'b100000: reserveData = data[readIndex][8*32+31:8*32];
			6'b100100: reserveData = data[readIndex][9*32+31:9*32];
			6'b101000: reserveData = data[readIndex][10*32+31:10*32];
			6'b101100: reserveData = data[readIndex][11*32+31:11*32];
			6'b110000: reserveData = data[readIndex][12*32+31:12*32];
			6'b110100: reserveData = data[readIndex][13*32+31:13*32];
			6'b111000: reserveData = data[readIndex][14*32+31:14*32];
			6'b111100: reserveData = data[readIndex][15*32+31:15*32];
		endcase
		
		readData = reserveData;
		
		if (readTag == dataTag[readIndex] && valid[readIndex] == 1) hit = 1; else hit = 0;
	end
	
	always @(posedge writeEnable) begin
		writeDone = 1'b0;
	end
		
	always @(posedge clk) begin
		
		if (writeEnable) begin
			//$display("only once");
			writeTag = writeAddr[31:16];
			writeIndex = writeAddr[15:6];
			writeOffset = writeAddr[5:0];
			writeWordOffset = writeOffset / 4 * 4;
			
			if (writeTag == dataTag[writeIndex]) begin
				case (writeWordOffset)
					6'b000000: data[writeIndex][0*32+31:0*32] = writeData;
					6'b000100: data[writeIndex][1*32+31:1*32] = writeData;
					6'b001000: data[writeIndex][2*32+31:2*32] = writeData;
					6'b001100: data[writeIndex][3*32+31:3*32] = writeData;
					6'b010000: data[writeIndex][4*32+31:4*32] = writeData;
					6'b010100: data[writeIndex][5*32+31:5*32] = writeData;
					6'b011000: data[writeIndex][6*32+31:6*32] = writeData;
					6'b011100: data[writeIndex][7*32+31:7*32] = writeData;
					
					6'b100000: data[writeIndex][8*32+31:8*32] = writeData;
					6'b100100: data[writeIndex][9*32+31:9*32] = writeData;
					6'b101000: data[writeIndex][10*32+31:10*32] = writeData;
					6'b101100: data[writeIndex][11*32+31:11*32] = writeData;
					6'b110000: data[writeIndex][12*32+31:12*32] = writeData;
					6'b110100: data[writeIndex][13*32+31:13*32] = writeData;
					6'b111000: data[writeIndex][14*32+31:14*32] = writeData;
					6'b111100: data[writeIndex][15*32+31:15*32] = writeData;
				endcase
				
				hit = 0;
				readTag = readAddr[31:16];
				readIndex = readAddr[15:6];
				readOffset = readAddr[5:0];
				wordOffset = readOffset / 4 * 4;
				
				case (wordOffset)
					6'b000000: reserveData = data[readIndex][0*32+31:0*32];
					6'b000100: reserveData = data[readIndex][1*32+31:1*32];
					6'b001000: reserveData = data[readIndex][2*32+31:2*32];
					6'b001100: reserveData = data[readIndex][3*32+31:3*32];
					6'b010000: reserveData = data[readIndex][4*32+31:4*32];
					6'b010100: reserveData = data[readIndex][5*32+31:5*32]; 
					6'b011000: reserveData = data[readIndex][6*32+31:6*32];
					6'b011100: reserveData = data[readIndex][7*32+31:7*32];
					
					6'b100000: reserveData = data[readIndex][8*32+31:8*32];
					6'b100100: reserveData = data[readIndex][9*32+31:9*32];
					6'b101000: reserveData = data[readIndex][10*32+31:10*32];
					6'b101100: reserveData = data[readIndex][11*32+31:11*32];
					6'b110000: reserveData = data[readIndex][12*32+31:12*32];
					6'b110100: reserveData = data[readIndex][13*32+31:13*32];
					6'b111000: reserveData = data[readIndex][14*32+31:14*32];
					6'b111100: reserveData = data[readIndex][15*32+31:15*32];
				endcase
				
				readData = reserveData;
				
				if (readTag == dataTag[readIndex] & valid[readIndex] == 1) hit = 1; else hit = 0;
			end
			
			memoryWriteData = writeData;
			memoryWriteAddr = writeAddr;
			
			memoryWritePulse = 1'b1;
			//writeEnable = 1'b0;
			#0.01;
		end
		
		writeDone = memoryWriteDone;
		
		#0 begin
			if (hit == 0) begin
				memoryReadAddr = readAddr;
				#0.01
				//readTag = readAddr[31:16];
				//readIndex = readAddr[15:6];
				if (memoryReadEnable == 1) begin
					readTag = readAddr[31:16];
					readIndex = readAddr[15:6];
					readOffset = readAddr[5:0];
					wordOffset = readOffset / 4 * 4;
				
					dataTag[readIndex] = readTag;
					data[readIndex] = memoryReadData;
					//$display($time, ": memoryReadData = %x", memoryReadData);
					//$display($time, ": data[readIndex] = %x", data[readIndex]);
					valid[readIndex] = 1'b1;
					
					case (wordOffset)
						6'b000000: reserveData = data[readIndex][0*32+31:0*32];
						6'b000100: reserveData = data[readIndex][1*32+31:1*32];
						6'b001000: reserveData = data[readIndex][2*32+31:2*32];
						6'b001100: reserveData = data[readIndex][3*32+31:3*32];
						6'b010000: reserveData = data[readIndex][4*32+31:4*32];
						6'b010100: reserveData = data[readIndex][5*32+31:5*32]; 
						6'b011000: reserveData = data[readIndex][6*32+31:6*32];
						6'b011100: reserveData = data[readIndex][7*32+31:7*32];
						
						6'b100000: reserveData = data[readIndex][8*32+31:8*32];
						6'b100100: reserveData = data[readIndex][9*32+31:9*32];
						6'b101000: reserveData = data[readIndex][10*32+31:10*32];
						6'b101100: reserveData = data[readIndex][11*32+31:11*32];
						6'b110000: reserveData = data[readIndex][12*32+31:12*32];
						6'b110100: reserveData = data[readIndex][13*32+31:13*32];
						6'b111000: reserveData = data[readIndex][14*32+31:14*32];
						6'b111100: reserveData = data[readIndex][15*32+31:15*32];
					endcase
					
					//$display($time, ": %d %d", data[readIndex][31:0], wordOffset);
					
					readData = reserveData;
					//$display($time, ": %h", readData);
					
					if (readTag == dataTag[readIndex] & valid[readIndex] == 1) hit = 1; else hit = 0;
				end
			end
		end
		
		memoryWritePulse = 1'b0;
	end
				
endmodule