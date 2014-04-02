// qdr_top.v --- 
// 
// Filename: qdr_top.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Apr  1 17:42:43 2014 (-0700)
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
module qdr_top (/*AUTOARG*/
   // Outputs
   qdriip_w_n, qdriip_sa, qdriip_r_n, qdriip_k_p, qdriip_k_n,
   qdriip_dll_off_n, qdriip_d, qdriip_bw_n, compare_error, cal_done,
   // Inputs
   sys_rst_i, sys_clk_i, qdriip_q, qdriip_cq_p, qdriip_cq_n
   );

   parameter NUM_DEVICES = 1;
   parameter DATA_WIDTH  = 36;
   parameter BW_WIDTH    = 4;
   parameter ADDR_WIDTH  = 18;

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [NUM_DEVICES-1:0] qdriip_cq_n;		// To example_top of example_top.v
   input [NUM_DEVICES-1:0] qdriip_cq_p;		// To example_top of example_top.v
   input [DATA_WIDTH-1:0] qdriip_q;		// To example_top of example_top.v
   input		sys_clk_i;		// To example_inf of example_inf.v
   input		sys_rst_i;		// To example_inf of example_inf.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		cal_done;		// From example_top of example_top.v
   output		compare_error;		// From example_top of example_top.v
   output [BW_WIDTH-1:0] qdriip_bw_n;		// From example_top of example_top.v
   output [DATA_WIDTH-1:0] qdriip_d;		// From example_top of example_top.v
   output		qdriip_dll_off_n;	// From example_top of example_top.v
   output [NUM_DEVICES-1:0] qdriip_k_n;		// From example_top of example_top.v
   output [NUM_DEVICES-1:0] qdriip_k_p;		// From example_top of example_top.v
   output		qdriip_r_n;		// From example_top of example_top.v
   output [ADDR_WIDTH-1:0] qdriip_sa;		// From example_top of example_top.v
   output		qdriip_w_n;		// From example_top of example_top.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			CLK_IN1;		// From example_inf of example_inf.v
   wire			CLK_OUT1;		// From clk_qdr of clk_qdr.v
   wire			CLK_OUT2;		// From clk_qdr of clk_qdr.v
   wire			LOCKED;			// From clk_qdr of clk_qdr.v
   wire			RESET;			// From example_inf of example_inf.v
   wire			clk_ref;		// From example_inf of example_inf.v
   wire			sys_clk;		// From example_inf of example_inf.v
   wire			sys_rst;		// From example_inf of example_inf.v
   // End of automatics
   
   example_top
     example_top (/*AUTOINST*/
		  // Outputs
		  .qdriip_k_p		(qdriip_k_p[NUM_DEVICES-1:0]),
		  .qdriip_k_n		(qdriip_k_n[NUM_DEVICES-1:0]),
		  .qdriip_d		(qdriip_d[DATA_WIDTH-1:0]),
		  .qdriip_sa		(qdriip_sa[ADDR_WIDTH-1:0]),
		  .qdriip_w_n		(qdriip_w_n),
		  .qdriip_r_n		(qdriip_r_n),
		  .qdriip_bw_n		(qdriip_bw_n[BW_WIDTH-1:0]),
		  .compare_error	(compare_error),
		  .qdriip_dll_off_n	(qdriip_dll_off_n),
		  .cal_done		(cal_done),
		  // Inputs
		  .sys_clk		(sys_clk),
		  .clk_ref		(clk_ref),
		  .qdriip_cq_p		(qdriip_cq_p[NUM_DEVICES-1:0]),
		  .qdriip_cq_n		(qdriip_cq_n[NUM_DEVICES-1:0]),
		  .qdriip_q		(qdriip_q[DATA_WIDTH-1:0]),
		  .sys_rst		(sys_rst));

   defparam example_top.INPUT_CLK_TYPE = "NO_BUFFER";

   clk_qdr
     clk_qdr (/*AUTOINST*/
	      // Outputs
	      .CLK_OUT1			(CLK_OUT1),
	      .CLK_OUT2			(CLK_OUT2),
	      .LOCKED			(LOCKED),
	      // Inputs
	      .CLK_IN1			(CLK_IN1),
	      .RESET			(RESET));

   example_inf
     example_inf (/*AUTOINST*/
		  // Outputs
		  .CLK_IN1		(CLK_IN1),
		  .RESET		(RESET),
		  .sys_clk		(sys_clk),
		  .sys_rst		(sys_rst),
		  .clk_ref		(clk_ref),
		  // Inputs
		  .CLK_OUT1		(CLK_OUT1),
		  .CLK_OUT2		(CLK_OUT2),
		  .LOCKED		(LOCKED),
		  .sys_clk_i		(sys_clk_i),
		  .sys_rst_i		(sys_rst_i));
   
endmodule
// 
// qdr_top.v ends here
