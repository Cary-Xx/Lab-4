`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: CondLogic
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: CondLogic Module
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

module CondLogic(
    input CLK,
    input PCS,
    input RegW,
    input NoWrite,
    input MemW,
    input [1:0] FlagW,//[1] & NZ_SAVED [0] & CV_SAVED
    input [3:0] Cond,
    input [3:0] ALUFlags,
    output PCSrc,
    output RegWrite,
    output MemWrite
    );
    
    reg CondEx ;
    reg N =0, Z =0, C =0, V =0;
    reg[1:0] temp_cond = 0;
    reg[3:0] temp_flags = 0;
    //<extra signals, if any>
    
    always@(Cond, N, Z, C, V)
    begin
        case(Cond)
            4'b0000: CondEx <= Z ;                  // EQ : equal 
            4'b0001: CondEx <= ~Z ;                 // NE : not equal
            4'b0010: CondEx <= C ;                  // CS / HS : carry set/unsigned higher or same
            4'b0011: CondEx <= ~C ;                 // CC / LO : carry clear/unsigned lower
            
            4'b0100: CondEx <= N ;                  // MI : minus/negative
            4'b0101: CondEx <= ~N ;                 // PL : plus/positive or zero
            4'b0110: CondEx <= V ;                  // VS : overflow
            4'b0111: CondEx <= ~V ;                 // VC : no overflow
            
            4'b1000: CondEx <= (~Z) & C ;           // HI : unsigned higher
            4'b1001: CondEx <= Z | (~C) ;           // LS : unsigned lower or same
            4'b1010: CondEx <= N ~^ V ;             // GE : signed greater than or equal
            4'b1011: CondEx <= N ^ V ;              // LT : signed less than
            
            4'b1100: CondEx <= (~Z) & (N ~^ V) ;    // GT : signed greater than
            4'b1101: CondEx <= Z | (N ^ V) ;        // LE : signed less than or equal
            4'b1110: CondEx <= 1'b1  ;              // AL : unconditional
            4'b1111: CondEx <= 0 ;               // unpredictable  
            
            default: CondEx <= 0; 
        endcase   
    end
    
    always@ (posedge CLK) begin
        temp_cond = FlagW & {CondEx,CondEx};
//    {N,Z,C,V} = temp_flags;
        if (temp_cond[1])
            temp_flags[3:2] = ALUFlags [3:2];

        if (temp_cond[0])
            temp_flags[1:0] = ALUFlags[1:0];
//                    temp_cond = FlagW & {CondEx,CondEx};
            {N,Z,C,V} = temp_flags;
     end
    
    //update three outputs
    assign PCSrc = CondEx & PCS;
    assign RegWrite = CondEx & RegW & ~NoWrite;
    assign MemWrite = CondEx & MemW;

        

endmodule













