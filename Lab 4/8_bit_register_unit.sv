module register_unit (input  logic Clk, Reset, Ld_A, D_Sub, Shift_En, Redo,
                      input  logic [7:0]  D,
							 input logic [8:0] Sum, Sub, 	 
                      output logic [16:0]  Data_Out,
							 output logic M_sig);

    reg_8  reg_A (.*, .ADD(Ld_A), .SUB(D_Sub), .M(M_sig), .Sum(Sum), .Sub(Sub), .Redo(Redo));
						


endmodule
