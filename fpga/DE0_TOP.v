// --------------------------------------------------------------------
// Copyright (c) 2009 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	DE0 TOP
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:

// --------------------------------------------------------------------


module DE0_TOP
	(
		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_50,						//	50 MHz
		CLOCK_50_2,						//	50 MHz
		////////////////////	Push Button		////////////////////
		ORG_BUTTON,						//	Pushbutton[2:0]
		////////////////////	DPDT Switch		////////////////////
		SW,								//	Toggle Switch[9:0]
		////////////////////	7-SEG Dispaly	////////////////////
		HEX0_D,							//	Seven Segment Digit 0
		HEX0_DP,						//	Seven Segment Digit DP 0
		HEX1_D,							//	Seven Segment Digit 1
		HEX1_DP,						//	Seven Segment Digit DP 1
		HEX2_D,							//	Seven Segment Digit 2
		HEX2_DP,						//	Seven Segment Digit DP 2
		HEX3_D,							//	Seven Segment Digit 3
		HEX3_DP,						//	Seven Segment Digit DP 3
		////////////////////////	LED		////////////////////////
		LEDG,							//	LED Green[9:0]
		////////////////////////	UART	////////////////////////
		UART_TXD,						//	UART Transmitter
		UART_RXD,						//	UART Receiver
		UART_CTS,						//	UART Clear To Send
		UART_RTS,						//	UART Request To Send
		/////////////////////	SDRAM Interface		////////////////
		DRAM_DQ,						//	SDRAM Data bus 16 Bits
		DRAM_ADDR,						//	SDRAM Address bus 13 Bits
		DRAM_LDQM,						//	SDRAM Low-byte Data Mask 
		DRAM_UDQM,						//	SDRAM High-byte Data Mask
		DRAM_WE_N,						//	SDRAM Write Enable
		DRAM_CAS_N,						//	SDRAM Column Address Strobe
		DRAM_RAS_N,						//	SDRAM Row Address Strobe
		DRAM_CS_N,						//	SDRAM Chip Select
		DRAM_BA_0,						//	SDRAM Bank Address 0
		DRAM_BA_1,						//	SDRAM Bank Address 1
		DRAM_CLK,						//	SDRAM Clock
		DRAM_CKE,						//	SDRAM Clock Enable
		////////////////////	Flash Interface		////////////////
		FL_DQ,							//	FLASH Data bus 15 Bits
		FL_DQ15_AM1,					//	FLASH Data bus Bit 15 or Address A-1
		FL_ADDR,						//	FLASH Address bus 22 Bits
		FL_WE_N,						//	FLASH Write Enable
		FL_RST_N,						//	FLASH Reset
		FL_OE_N,						//	FLASH Output Enable
		FL_CE_N,						//	FLASH Chip Enable
		FL_WP_N,						//	FLASH Hardware Write Protect
		FL_BYTE_N,						//	FLASH Selects 8/16-bit mode
		FL_RY,							//	FLASH Ready/Busy
		////////////////////	LCD Module 16X2		////////////////
		LCD_BLON,						//	LCD Back Light ON/OFF
		LCD_RW,							//	LCD Read/Write Select, 0 = Write, 1 = Read
		LCD_EN,							//	LCD Enable
		LCD_RS,							//	LCD Command/Data Select, 0 = Command, 1 = Data
		LCD_DATA,						//	LCD Data bus 8 bits
		////////////////////	SD_Card Interface	////////////////
		SD_DAT0,						//	SD Card Data 0
		SD_DAT3,						//	SD Card Data 3
		SD_CMD,							//	SD Card Command Signal
		SD_CLK,							//	SD Card Clock
		SD_WP_N,						//	SD Card Write Protect
		////////////////////	PS2		////////////////////////////
		PS2_KBDAT,						//	PS2 Keyboard Data
		PS2_KBCLK,						//	PS2 Keyboard Clock
		PS2_MSDAT,						//	PS2 Mouse Data
		PS2_MSCLK,						//	PS2 Mouse Clock
		////////////////////	VGA		////////////////////////////
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_R,   						//	VGA Red[3:0]
		VGA_G,	 						//	VGA Green[3:0]
		VGA_B,  						//	VGA Blue[3:0]
		////////////////////	GPIO	////////////////////////////
		GPIO0_CLKIN,					//	GPIO Connection 0 Clock In Bus
		GPIO0_CLKOUT,					//	GPIO Connection 0 Clock Out Bus
		GPIO0_D,						//	GPIO Connection 0 Data Bus
		GPIO0_D8,						//	GPIO Connection 0 Data Bus
		GPIO0_D9,						//	GPIO Connection 0 Data Bus
		GPIO0_D10,						//	GPIO Connection 0 Data Bus
		GPIO0_D11,						//	GPIO Connection 0 Data Bus
		GPIO1_CLKIN,					//	GPIO Connection 1 Clock In Bus
		GPIO1_CLKOUT,					//	GPIO Connection 1 Clock Out Bus
		GPIO1_D							//	GPIO Connection 1 Data Bus
	);

////////////////////////	Clock Input	 	////////////////////////
input			CLOCK_50;				//	50 MHz
input			CLOCK_50_2;				//	50 MHz
////////////////////////	Push Button		////////////////////////
input	[2:0]	ORG_BUTTON;				//	Pushbutton[2:0]
////////////////////////	DPDT Switch		////////////////////////
input	[9:0]	SW;						//	Toggle Switch[9:0]
////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0_D;					//	Seven Segment Digit 0
output			HEX0_DP;				//	Seven Segment Digit DP 0
output	[6:0]	HEX1_D;					//	Seven Segment Digit 1
output			HEX1_DP;				//	Seven Segment Digit DP 1
output	[6:0]	HEX2_D;					//	Seven Segment Digit 2
output			HEX2_DP;				//	Seven Segment Digit DP 2
output	[6:0]	HEX3_D;					//	Seven Segment Digit 3
output			HEX3_DP;				//	Seven Segment Digit DP 3
////////////////////////////	LED		////////////////////////////
output	[9:0]	LEDG;					//	LED Green[9:0]
////////////////////////////	UART	////////////////////////////
output			UART_TXD;				//	UART Transmitter
input			UART_RXD;				//	UART Receiver
output			UART_CTS;				//	UART Clear To Send
input			UART_RTS;				//	UART Request To Send
///////////////////////		SDRAM Interface	////////////////////////
inout	[15:0]	DRAM_DQ;				//	SDRAM Data bus 16 Bits
output	[12:0]	DRAM_ADDR;				//	SDRAM Address bus 13 Bits
output			DRAM_LDQM;				//	SDRAM Low-byte Data Mask
output			DRAM_UDQM;				//	SDRAM High-byte Data Mask
output			DRAM_WE_N;				//	SDRAM Write Enable
output			DRAM_CAS_N;				//	SDRAM Column Address Strobe
output			DRAM_RAS_N;				//	SDRAM Row Address Strobe
output			DRAM_CS_N;				//	SDRAM Chip Select
output			DRAM_BA_0;				//	SDRAM Bank Address 0
output			DRAM_BA_1;				//	SDRAM Bank Address 1
output			DRAM_CLK;				//	SDRAM Clock
output			DRAM_CKE;				//	SDRAM Clock Enable
////////////////////////	Flash Interface	////////////////////////
inout	[14:0]	FL_DQ;					//	FLASH Data bus 15 Bits
inout			FL_DQ15_AM1;			//	FLASH Data bus Bit 15 or Address A-1
output	[21:0]	FL_ADDR;				//	FLASH Address bus 22 Bits
output			FL_WE_N;				//	FLASH Write Enable
output			FL_RST_N;				//	FLASH Reset
output			FL_OE_N;				//	FLASH Output Enable
output			FL_CE_N;				//	FLASH Chip Enable
output			FL_WP_N;				//	FLASH Hardware Write Protect
output			FL_BYTE_N;				//	FLASH Selects 8/16-bit mode
input			FL_RY;					//	FLASH Ready/Busy
////////////////////	LCD Module 16X2	////////////////////////////
inout	[7:0]	LCD_DATA;				//	LCD Data bus 8 bits
output			LCD_BLON;				//	LCD Back Light ON/OFF
output			LCD_RW;					//	LCD Read/Write Select, 0 = Write, 1 = Read
output			LCD_EN;					//	LCD Enable
output			LCD_RS;					//	LCD Command/Data Select, 0 = Command, 1 = Data
////////////////////	SD Card Interface	////////////////////////
inout			SD_DAT0;				//	SD Card Data 0
inout			SD_DAT3;				//	SD Card Data 3
inout			SD_CMD;					//	SD Card Command Signal
output			SD_CLK;					//	SD Card Clock
input			SD_WP_N;				//	SD Card Write Protect
////////////////////////	PS2		////////////////////////////////
inout		 	PS2_KBDAT;				//	PS2 Keyboard Data
inout			PS2_KBCLK;				//	PS2 Keyboard Clock
inout		 	PS2_MSDAT;				//	PS2 Mouse Data
inout			PS2_MSCLK;				//	PS2 Mouse Clock
////////////////////////	VGA			////////////////////////////
output			VGA_HS;					//	VGA H_SYNC
output			VGA_VS;					//	VGA V_SYNC
output	[3:0]	VGA_R;   				//	VGA Red[3:0]
output	[3:0]	VGA_G;	 				//	VGA Green[3:0]
output	[3:0]	VGA_B;   				//	VGA Blue[3:0]
////////////////////////	GPIO	////////////////////////////////
input	[1:0]	GPIO0_CLKIN;			//	GPIO Connection 0 Clock In Bus
output	[1:0]	GPIO0_CLKOUT;			//	GPIO Connection 0 Clock Out Bus
//inout	[31:0]	GPIO0_D;				//	GPIO Connection 0 Data Bus
inout	[7:0]	GPIO0_D;				//	GPIO Connection 0 Data Bus
input       	GPIO0_D8;				//	GPIO Connection 0 Data Bus
output       	GPIO0_D9;				//	GPIO Connection 0 Data Bus
input       	GPIO0_D10;				//	GPIO Connection 0 Data Bus
output       	GPIO0_D11;				//	GPIO Connection 0 Data Bus

input	[1:0]	GPIO1_CLKIN;			//	GPIO Connection 1 Clock In Bus
output	[1:0]	GPIO1_CLKOUT;			//	GPIO Connection 1 Clock Out Bus
inout	[31:0]	GPIO1_D;				//	GPIO Connection 1 Data Bus


//=======================================================
//  FTDI FIFO
//=======================================================

wire [7:0]  fifo_rd_data;   // read data from fifo
wire        fifo_rd_n;      // rd to fifo
reg         fifo_rxf_n;     // rxf from fifo

wire [7:0]  fifo_wr_data;   // write data to fifo
wire        fifo_wr_n;      // wr to fifo
reg         fifo_txe_n;     // txe from fifo
wire        fifo_oe_n;      // output enable for inout buf

wire        rd_verify_ng;   // verify NG then 1'b1;


ftdi_fifo ftdi_fifo(
    // Connect to FTDI FIFO Module
    .iFIFO_RXF_n(fifo_rxf_n),
    .oFIFO_RD_n(fifo_rd_n),
    .iFIFO_DATA(fifo_rd_data),
    
    .iFIFO_TXE_n(fifo_txe_n),
    .oFIFO_WR_n(fifo_wr_n),
    .oFIFO_DATA(fifo_wr_data),
    .oFIFO_OE_n(fifo_oe_n),
    
    .oRD_VERIFY_NG(rd_verify_ng),
    // Connect to System Signals
    .clk(CLOCK_50),
    .rst(ORG_BUTTON[2])
);

always@(posedge CLOCK_50) begin
    fifo_rxf_n  <= GPIO0_D8;
    fifo_txe_n  <= GPIO0_D10;
end

reg         GPIO0_D9;
reg         GPIO0_D11;
reg [9:0]   LEDG;

always@(posedge CLOCK_50) begin
    GPIO0_D9    <= fifo_rd_n;
    GPIO0_D11   <= fifo_wr_n;
    LEDG[0]     <= rd_verify_ng;
end

param_inout_buf #(.DATA_WIDTH(8))
 iobuf( .ioDATA(GPIO0_D[7:0]),
        .iOE_n(fifo_oe_n),
        .iDATA(fifo_rd_data),
        .oDATA(fifo_wr_data),
        .clk(CLOCK_50));
        
endmodule