	/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [9:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

logic [31:0] LOCAL_REG [`NUM_REGS]; // Registers

//put other local variables here
logic blank, sync, VGA_Clk;
logic [9:0] drawxsig, drawysig;
logic [31:0] word;
logic [31:0] word_data;
logic [7:0] char, font_data_char;
//logic bit_idk, inverse;
//logic [31:0] control_reg;
logic [10:0] font_addr;


//Declare submodules..e.g. VGA controller, ROMS, etc

vga_controller vgacontrol(.Reset(RESET), .Clk(CLK), .hs(hs), .vs(vs), .pixel_clk(VGA_Clk), .blank(blank), .sync(sync), .DrawX(drawxsig), .DrawY(drawysig));

font_rom fonty (.addr(font_addr), .data(font_data_char)); 

//color_mapper colormap(.DrawX(drawxsig), .DrawY(drawysig), .Red(red), .Green(green), .Blue(blue));
   
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
always_ff @(posedge CLK) begin

if (RESET)
begin
end

if(AVL_CS)
	begin
	
	if (AVL_READ)
		begin
		
		AVL_READDATA <= LOCAL_REG[AVL_ADDR];
		
		end

	else if (AVL_WRITE)	
		begin
		
			case (AVL_BYTE_EN)
				4'b0001 : LOCAL_REG[AVL_ADDR][7:0] <= AVL_WRITEDATA[7:0];  
				4'b0010 : LOCAL_REG[AVL_ADDR][15:8] <= AVL_WRITEDATA[15:8];
				4'b0100 : LOCAL_REG[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
				4'b1000 : LOCAL_REG[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
				4'b0011 : LOCAL_REG[AVL_ADDR][15:0] <= AVL_WRITEDATA[15:0];
				4'b1100 : LOCAL_REG[AVL_ADDR][31:16] <= AVL_WRITEDATA[31:16];
				4'b1111 : LOCAL_REG[AVL_ADDR][31:0] <= AVL_WRITEDATA[31:0];
	
				default: ;
			endcase
		end
		
	end
	
end


//handle drawing (may either be combinational or sequential - or both).



always_comb 
	begin
	word = drawysig[9:4] * 80 + drawxsig[9:3];		//MATH
	word_data = LOCAL_REG[word[11:2]];					//MATH
	
	//case(word[1:0])
	if(word[1:0] == 2'b00)
		begin
			
			char = word_data[7:0];
		end
	else if(word[1:0] == 2'b01)
		begin
			
			char = word_data[15:8];
		end
	else if(word[1:0] == 2'b10)
		begin
			
			char = word_data[23:16];
		end
	else if(word[1:0] == 2'b11)
		begin
		
			char = word_data[31:24];
		end
	else
		begin
		end
	
	//default: ;
	//endcase
	//inverse = char[7];
	font_addr = ((char[6:0]*16) + drawysig[3:0]);	//MATH
//	control_reg = LOCAL_REG[`CTRL_REG];
	//bit_idk = font_data_char[7 - drawxsig[2:0]];

end 


always_ff @(posedge CLK) begin	

	
	
	if(blank) 
		begin
		
		if(font_data_char[7 - drawxsig[2:0]] ^ char[7])
			begin
			//FGD
			red = LOCAL_REG[`CTRL_REG][24:21];
			blue = LOCAL_REG[`CTRL_REG][16:13];
			green = LOCAL_REG[`CTRL_REG][20:17];
			end
		else
			begin
			//BGD
			red = LOCAL_REG[`CTRL_REG][12:9];
			blue = LOCAL_REG[`CTRL_REG][4:1];
			green = LOCAL_REG[`CTRL_REG][8:5];
			end
		end
	else 
		begin
		red = 4'h0;
		blue = 4'h0;
		green = 4'h0;
		end

	end

endmodule
