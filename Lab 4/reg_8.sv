module reg_8 (input  logic Clk, Reset, ADD, Shift_En, SUB, Redo,
              input  logic [7:0] D,
				  input logic [8:0] Sum, Sub,
				  output logic M,
              output logic [16:0]  Data_Out);

				  
	logic [16:0] Data_Next;
	logic X, X_Next;
	
	  
 always_ff @ (posedge Clk)
    begin
			
	 	 if (Reset) //	ClearXA_LoadB_Reset
		 
			begin
			Data_Out [16:8] <=  8'h0;	// First 8 bits go to 0 (Register A)
			Data_Out [7:0] <= D;		// Last 8 bits are the switch inputs (Register B)
			X <= 1'b0;
			end
			
			else if (ADD)
				begin		 
					Data_Out <= {Sum, Data_Out[7:0]};		//  Value of Switches plus register A
					X <= Sum[8];

				end
			
			else if (SUB)
		 
				begin
					Data_Out <= {Sub, Data_Out[7:0]};		//  Value of Switches plus register A
					X <= Sub[8];

				end
			
			else if (Shift_En)
		 
				begin
					Data_Out[15:0] <= {X, Data_Out[16:1]}; 
					Data_Out[16] <= X;
				end
				
			else if (Redo)	
				begin
					Data_Out <=  {8'h0, Data_Out[7:0]};	// First 8 bits go to 0 (Register A)
					X <= 1'b0;
				end
		else begin 
			Data_Out <= Data_Out;
			X <= X;			
		end
		
	 	 M <= Data_Out[0];
		
	end

endmodule
