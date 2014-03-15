// k7netfpga_ibert_1g.v --- 
// 
// Filename: k7netfpga_ibert_1g.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Mar 15 12:04:18 2014 (-0700)
// Version: 
// Last-Updated: 
//           By: 
//     Update #: 0
// URL: 
// Keywords: 
// Compatibility: 
// 
// 

// Commentary: 
// 
// 
// 
// 

// Change log:
// 
// 
// 

// -------------------------------------
// Naming Conventions:
// 	active low signals                 : "*_n"
// 	clock signals                      : "clk", "clk_div#", "clk_#x"
// 	reset signals                      : "rst", "rst_n"
// 	generics                           : "C_*"
// 	user defined types                 : "*_TYPE"
// 	state machine next state           : "*_ns"
// 	state machine current state        : "*_cs"
// 	combinatorial signals              : "*_com"
// 	pipelined or register delay signals: "*_d#"
// 	counter signals                    : "*cnt*"
// 	clock enable signals               : "*_ce"
// 	internal version of output port    : "*_i"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:
module k7netfpga_ibert_1g (/*AUTOARG*/
   // Outputs
   X0Y15_TX_P_OPAD, X0Y15_TX_N_OPAD, X0Y14_TX_P_OPAD, X0Y14_TX_N_OPAD,
   X0Y13_TX_P_OPAD, X0Y13_TX_N_OPAD, X0Y12_TX_P_OPAD, X0Y12_TX_N_OPAD,
   TX_DISABLE,
   // Inputs
   X0Y15_RX_P_IPAD, X0Y15_RX_N_IPAD, X0Y14_RX_P_IPAD, X0Y14_RX_N_IPAD,
   X0Y13_RX_P_IPAD, X0Y13_RX_N_IPAD, X0Y12_RX_P_IPAD, X0Y12_RX_N_IPAD,
   Q3_CLK1_MGTREFCLK_P_IPAD, Q3_CLK1_MGTREFCLK_N_IPAD,
   IBERT_SYSCLOCK_P_IPAD
   );

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		IBERT_SYSCLOCK_P_IPAD;	// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   input		Q3_CLK1_MGTREFCLK_N_IPAD;// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   input		Q3_CLK1_MGTREFCLK_P_IPAD;// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   input		X0Y12_RX_N_IPAD;	// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   input		X0Y12_RX_P_IPAD;	// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   input		X0Y13_RX_N_IPAD;	// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   input		X0Y13_RX_P_IPAD;	// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   input		X0Y14_RX_N_IPAD;	// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   input		X0Y14_RX_P_IPAD;	// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   input		X0Y15_RX_N_IPAD;	// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   input		X0Y15_RX_P_IPAD;	// To example_chipscope_ibert1g of example_chipscope_ibert1g.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		X0Y12_TX_N_OPAD;	// From example_chipscope_ibert1g of example_chipscope_ibert1g.v
   output		X0Y12_TX_P_OPAD;	// From example_chipscope_ibert1g of example_chipscope_ibert1g.v
   output		X0Y13_TX_N_OPAD;	// From example_chipscope_ibert1g of example_chipscope_ibert1g.v
   output		X0Y13_TX_P_OPAD;	// From example_chipscope_ibert1g of example_chipscope_ibert1g.v
   output		X0Y14_TX_N_OPAD;	// From example_chipscope_ibert1g of example_chipscope_ibert1g.v
   output		X0Y14_TX_P_OPAD;	// From example_chipscope_ibert1g of example_chipscope_ibert1g.v
   output		X0Y15_TX_N_OPAD;	// From example_chipscope_ibert1g of example_chipscope_ibert1g.v
   output		X0Y15_TX_P_OPAD;	// From example_chipscope_ibert1g of example_chipscope_ibert1g.v
   // End of automatics

   output [3:0] 	TX_DISABLE;
   assign TX_DISABLE = 4'h0;
   
   example_chipscope_ibert1g
     example_chipscope_ibert1g (/*AUTOINST*/
				// Outputs
				.X0Y12_TX_P_OPAD(X0Y12_TX_P_OPAD),
				.X0Y12_TX_N_OPAD(X0Y12_TX_N_OPAD),
				.X0Y13_TX_P_OPAD(X0Y13_TX_P_OPAD),
				.X0Y13_TX_N_OPAD(X0Y13_TX_N_OPAD),
				.X0Y14_TX_P_OPAD(X0Y14_TX_P_OPAD),
				.X0Y14_TX_N_OPAD(X0Y14_TX_N_OPAD),
				.X0Y15_TX_P_OPAD(X0Y15_TX_P_OPAD),
				.X0Y15_TX_N_OPAD(X0Y15_TX_N_OPAD),
				// Inputs
				.IBERT_SYSCLOCK_P_IPAD(IBERT_SYSCLOCK_P_IPAD),
				.X0Y12_RX_P_IPAD(X0Y12_RX_P_IPAD),
				.X0Y12_RX_N_IPAD(X0Y12_RX_N_IPAD),
				.X0Y13_RX_P_IPAD(X0Y13_RX_P_IPAD),
				.X0Y13_RX_N_IPAD(X0Y13_RX_N_IPAD),
				.X0Y14_RX_P_IPAD(X0Y14_RX_P_IPAD),
				.X0Y14_RX_N_IPAD(X0Y14_RX_N_IPAD),
				.X0Y15_RX_P_IPAD(X0Y15_RX_P_IPAD),
				.X0Y15_RX_N_IPAD(X0Y15_RX_N_IPAD),
				.Q3_CLK1_MGTREFCLK_P_IPAD(Q3_CLK1_MGTREFCLK_P_IPAD),
				.Q3_CLK1_MGTREFCLK_N_IPAD(Q3_CLK1_MGTREFCLK_N_IPAD));

endmodule
// 
// k7netfpga_ibert_10g.v ends here
