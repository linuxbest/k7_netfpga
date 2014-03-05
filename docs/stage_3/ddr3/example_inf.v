// example_inf.v --- 
// 
// Filename: example_inf.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Mar  4 20:39:38 2014 (-0800)
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
module example_inf (/*AUTOARG*/
   // Outputs
   sys_clk_i, clk_ref_i,
   // Inputs
   sys_clk, sys_rst
   );
   input sys_clk;
   input sys_rst;

   output sys_clk_i;
   output clk_ref_i;


   assign sys_clk_i = sys_clk;
   assign clk_ref_i = sys_clk;
endmodule
// 
// example_inf.v ends here
