// example_inf.v --- 
// 
// Filename: example_inf.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Apr  1 17:47:01 2014 (-0700)
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
   CLK_IN1, RESET, sys_clk, sys_rst, clk_ref,
   // Inputs
   CLK_OUT1, CLK_OUT2, LOCKED, sys_clk_i, sys_rst_i, cal_done,
   compare_error
   );
   input CLK_OUT1;
   input CLK_OUT2;
   input LOCKED;

   output CLK_IN1;
   output RESET;

   input  sys_clk_i;
   input  sys_rst_i;

   output sys_clk;
   output sys_rst;
   output clk_ref;

   input  cal_done;
   input  compare_error;
   
   assign CLK_IN1 = sys_clk_i;
   assign RESET   = ~sys_rst_i;
   
   assign sys_clk = CLK_OUT1;
   assign clk_ref = CLK_OUT2;
   assign sys_rst = ~LOCKED;
   
endmodule
// 
// example_inf.v ends here
