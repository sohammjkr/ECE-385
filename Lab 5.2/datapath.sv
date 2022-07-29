module datapath (
	input logic	Clk, Reset,
	input logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED,
	input logic SR2MUX, ADDR1MUX, MARMUX,
	input logic GatePC, GateMDR, GateALU, GateMARMUX,
	input logic  MIO_EN, DRMUX, SR1MUX,
	input logic [1:0] PCMUX, ADDR2MUX, ALUK,
	input logic [15:0]MDR_In, PC_in, bus_temp,
	output logic [9:0] LED,
	output logic [15:0] MAR, MDR, IR, PC, PC_Now, BUS, 
	output logic BEN
	);
	
	logic [15:0] PC_temp, adder_val,SR1OUT, SR2OUT, R0, R1, R2, R3, R4, R5, R6, R7;
	assign adder_val = 16'b0000000000000000;
	logic [15:0] PC_out, MDR_out, IR_out, MAR_out; 
	logic [15:0] MDR_temp, bus_temp2, SR2MUXOUT, ALUOUT, ADDR2MUXOUT, ADDR1MUXOUT, ADDROUT, EVALADDR, MARMUXOUT;
	logic [2:0] SR1MUXOUT, DRMUXOUT;
	logic BEN_out ;
	assign PC_Now = PC_out;
	assign bus_temp2 = BUS;

	SR2MUX_MUX MUXSR2(.*, .select(SR2MUX));		//SR2MUX TO GO TO ALU
	
	SR1MUX_MUX MUXSR1(.*, .select(SR1MUX));		//SR1MUX FOR REG FILE

	DRMUX_MUX MUXDR(.*, .select(DRMUX));		//DRMUX FOR REG FILE
	
	PCMUX MUX_PC(.PC0(PC_Now), .PC1(bus_temp2), .PC2(EVALADDR), .Select(PCMUX), .PC(PC_temp));
	
	
	reg_16 pc_reg(.Clk(Clk), .Reset(Reset), .Load(LD_PC), .Reg_In(PC_temp), .Reg_Out(PC_out));
	
	
	MUX2 #(16) MUX_MDR(.d0(MDR_In), .d1(BUS), .select(MIO_EN), .y(MDR_temp));
	
	reg_16 mdr_reg(.Clk(Clk), .Reset(Reset), .Load(LD_MDR), .Reg_In(MDR_temp), .Reg_Out(MDR_out));
	
	
	
	reg_16 mar_reg(.Clk(Clk), .Reset(Reset), .Load(LD_MAR), .Reg_In(BUS), .Reg_Out(MAR_out));
	
	reg_16 ir_reg(.Clk(Clk), .Reset(Reset), .Load(LD_IR), .Reg_In(BUS), .Reg_Out(IR_out));
	

						
	regfile reg_file(.*);			// REG FILE OUTPUT SR1OUT GOES TO ALU, SR2OUT GOES TO SR2MUX
	
	ALU ALU_D(.*, .select(ALUK)); // ALU SR1OUT AND SR2OUT, OUTPUT OF ALU IS ALUOUT	--------GATEALU

	ADDR2MUX_MUX MUXADDR2(.*, .select(ADDR2MUX));
	
	ADDR1MUX_MUX MUXADDR1(.*, .select(ADDR1MUX));
	
	assign EVALADDR = ADDR2MUXOUT + ADDR1MUXOUT;			
	
	MARMUX_MUX MUXMARMUX(.*, .select(MARMUX));		//MARMUx EVALADDR AND ZEXT [7:0] IR, OUTPUT IS GATEMARMUX
	
	Branch_En BR_Enable(.*, .BEN_out(BEN));
	
	BUSMUX set_bus(.*, .PC(PC_out), .MDR(MDR_out), .BUS_in(bus_temp2));
	
	always_comb
		begin
			MAR = MAR_out;
			MDR = MDR_out;
			IR = IR_out;
			PC = PC_out;
		end
	
	always_ff @ (posedge Clk)
		begin
			
			if(LD_LED)
				begin
					LED <= IR [9:0];
				end
			else
			  begin
					LED <= 10'b0000000000;
				end
		end
endmodule 