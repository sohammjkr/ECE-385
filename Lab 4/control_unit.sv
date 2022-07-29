//Two-always example for state machine

module control (input  logic Clk, Reset, Execute, MSB,
                output logic Shift_En, Ld_A, Ld_Sub, Redo);

    enum logic [4:0] {A, B, C, D, E, F, G, H, Z}   curr_state, next_state; 
	 
	 logic [8:0] count, count_next;


	//updates flip flop, current state is the only one
    always_ff @ (posedge Clk) 
	 
    begin
        if (Reset) begin
            curr_state <= A;
				count <= 8'h00;
			end
        else 
			begin
            curr_state <= next_state;
				count <= count_next; 
			end
    end

    // Assign outputs based on state
	always_comb 
	
	begin
        
		  next_state  = curr_state;	//required because I haven't enumerated all possibilities below
        unique case (curr_state) 

		  //A is Run, B has M = 1,  
		  
            A :begin 
						
						if(Execute) begin
                       next_state = Z;
							end
						
					end
					
				Z: begin
						next_state = B;
					end
							  			  
            B :  begin
						if(MSB) begin
						
							next_state = C;
						end
					  
						else begin
							next_state = D;
						end
					  end
					  
            C :  begin //ADD
					
						next_state = D;
					  end
										  
            D :  begin		//Sfhit
					
						next_state = E;
					  end
					  
            E :  begin			//Check Counter and go 
						if(count_next == 8'h07) begin
						
							if(MSB) begin
								next_state = F;
							end
						
							else begin
								next_state = G;
							end
						end
						
						else begin
							next_state = B;	//else out repeat
						end
						end	
				F: begin					//Sub		
					 next_state = G;
					end
					
				G :  begin				// Shift
					
					  next_state = H;
						end
						
				H:   begin	//Return to A
				
						if (~Execute) 
                       next_state = A;
						end	  
endcase
   
		  // Assign outputs based on ‘state’
		  // Assign outputs based on ‘state’
                case (curr_state) 
			A: 
			begin
				 Shift_En = 1'b0;
				 Ld_A = 1'b0;
				 Ld_Sub = 1'b0;
				 count_next = 8'h00;
				 Redo = 1'b0;

			end 
			Z: 
			begin
				 Shift_En = 1'b0;
				 Ld_A = 1'b0;
				 Ld_Sub = 1'b0;
				 count_next = 8'h00;
				 Redo = 1'b1;

			end 
			
			C: 				// Add State
			begin 
				 Shift_En = 1'b0;
				 Ld_A = 1'b1;
				 Ld_Sub = 1'b0;
				 count_next = count;
				 Redo = 1'b0;
			end
			
			D: 					//Shift
			begin 
				 Shift_En = 1'b1;
				 Ld_A = 1'b0;
				 Ld_Sub = 1'b0;
				 count_next = count + 1;
				 Redo = 1'b0;
			end
			
			F: 				//Subtract State
			begin 
				 Shift_En = 1'b0;
				 Ld_A = 1'b0;
				 Ld_Sub = 1'b1;
				 count_next = count;
				 Redo = 1'b0;
			end
			
			G: 				//Shift
			begin 
				 Shift_En = 1'b1;
				 Ld_A = 1'b0;
				 Ld_Sub = 1'b0;
				 count_next = count;
				 Redo = 1'b0;
			end			
			
	   	   default:  //default case, can also have default assignments for Ld_A and Ld_B before case
		      begin 
						
						Shift_En = 1'b0;
						Ld_A = 1'b0;
						Ld_Sub = 1'b0;
						count_next = count;
						Redo = 1'b0;

						
		      end
        endcase
    end

endmodule