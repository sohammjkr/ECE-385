// 2/14/22 Lab 4 Processor for 8 bit multiplier
//Top Level
//for use with ECE 385 Spring 2021

//Always use input/output logic types when possible, prevents issues with tools that have strict type enforcement

module Processor (input logic   Clk,     // Internal
                                Reset,   // Push button 0
                                Execute, // Push button 1
                  input  logic [7:0]  SW,     // input data
                  output logic [16:0]  Reg,    // DEBUG
						output logic [9:0] LED,
						output logic [6:0] HEX0, 
										 HEX1, 
										 HEX2, 
										 HEX3,
										 HEX4,
										 HEX5);
	
logic Reset_SH, Ld_A, D_Sub, Shift_En, Execute_SH, M_val, Redo;

logic [8:0] Sum, Sub;

assign Reset_SH = ~Reset;
assign Execute_SH = ~Execute;
logic [15:0] A;
logic [16:0] RegOut;


assign Reg [15:0] = A;

	 //Instantiation of modules here

	 ripple_adder adder(.A({SW[7], SW[7:0]}), .B({Reg[15], Reg[15:8]}), .cin(1'b0), .S(Sum[8:0]));
	
	 sub subtract( .Register({Reg[15], Reg[15:8]}), .D({SW[7], SW[7:0]}), .D_Sub(Sub[8:0]));
	
	

	
	 register_unit    reg_unit (
                        .Clk(Clk),
                        .Reset(Reset_SH),
                        .Ld_A, //note these are inferred assignments, because of the existence a logic variable of the same name
								. D_Sub,
								.Shift_En,
								.Redo,
								.D(SW),
								.Sum(Sum),
								.Sub(Sub),
								.Data_Out(Reg),
								.M_sig(M_val));
			
			 
	 control          control_unit (
                        .Clk(Clk),
                        .Reset(Reset_SH),
                        .Execute(Execute_SH),
								.MSB(M_val),
                        .Shift_En,
                        .Ld_A,
								.Ld_Sub(D_Sub),
								.Redo);
						

		HexDriver		Hex0 (
								.In0(A[3:0]),
								.Out0(HEX0) );
								
		HexDriver		Hex1 (
								.In0(A[7:4]),
								.Out0(HEX1) );
								
		HexDriver		Hex2 (
								.In0(A[11:8]),
								.Out0(HEX2) );
								
		HexDriver		Hex3 (
								.In0(A[15:12]),
								.Out0(HEX3) );
								
		HexDriver		Hex4 (
								.In0(5'b11111),
								.Out0(HEX4) );											
		HexDriver		Hex5 (
								.In0(5'b11111),
								.Out0(HEX5) );
								
endmodule
