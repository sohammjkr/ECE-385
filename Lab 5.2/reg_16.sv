module reg_16 (input logic Clk, Reset, Load,
					input logic [15:0] Reg_In,
					output logic [15:0] Reg_Out
					);
					
logic [15:0] Reg_Temp;					

always_ff @ (posedge Clk) 
	begin
		if(Reset)
		begin
			Reg_Out <= 16'h0000;
		end
			else if(Load)
			begin
				Reg_Out <= Reg_In;
			end
	end
endmodule

