`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: Decoder
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Decoder Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v)	acknowledge that the program was written based on the microarchitecture described in the book Digital Design and Computer Architecture, ARM Edition by Harris and Harris;
--		(vi) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vii) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module Decoder(
    input [3:0] Rd,
    input [1:0] Op,
    input [5:0] Funct,
    output PCS, 
    output RegW, 
    output MemW, 
    output MemtoReg, 
    output ALUSrc, 
    output [1:0] ImmSrc, 
    output [1:0] RegSrc, 
    output NoWrite, 
    output [1:0] ALUControl,
    output [1:0] FlagW
    );
    
    wire ALUOp;
	wire Branch;
    reg [9:0] controls ;
	reg [3:0] aluc;
	reg offset;
  
    //<extra signals, if any>

	always @* begin
		case (Op) 
			2'b00: 
				begin
					case (Funct[5]) 
						1'b0: 
						  begin
						    controls = 10'b0000001001;
						    offset = 0;
						  end
					   1'b1: 
						begin
						    controls = 10'b0001001001;
						    offset = 0;
						end
					endcase
				end
			2'b01: 
				begin
					case (Funct[0])
						1'b0:
						  begin
						    controls = 10'b0011010100;
						    offset = ~Funct[3];
						end
					   1'b1:
						begin
						    controls = 10'b0101011000;
						    offset = ~Funct[3];
						end
					endcase
				end
			2'b10: 
				begin
					controls = 10'b1001100010;
					offset = 0;
				end
			default: 
		        begin
		            controls = 10'b0000000000;
		            offset = 0;
		        end     
		endcase
		
		
	   case (ALUOp) 
			1'b0 :
			 begin
				aluc = 4'b0000;
				aluc[2] = offset;
			 end
		    1'b1 :
			 begin
				case (Funct[4:0])
					5'b01000: 
						begin
							aluc =4'b0000;
						end
					5'b01001: 
						begin
							aluc = 4'b0011;
						end
					5'b00100: 
						begin
							aluc = 4'b0100;
						end
					5'b00101: 
						begin
							aluc = 4'b0111;
						end
					5'b00000: 
						begin
							aluc = 4'b1000;
						end
					5'b00001: 
						begin
							aluc = 4'b1010;
						end
					5'b11000: 
						begin
							aluc = 4'b1100;
						end
					5'b11001: 
						begin
							aluc = 4'b1110;
						end
					5'b10101:
						begin
							aluc = 4'b0111;
						end
					5'b10111:
					   begin
					        aluc = 4'b0011;
					   end
					default: 
					   begin
					       aluc = 0;
					   end
				endcase
			 end
		endcase
	end
	
	assign {Branch,MemtoReg,MemW,ALUSrc,ImmSrc,RegW,RegSrc,ALUOp} = controls;
	assign {ALUControl,FlagW} = aluc;
	assign NoWrite = ALUOp & ((Funct==5'b10101)||(Funct==5'b10111));
	assign PCS = Branch | ((Rd==15)&RegW);
endmodule





