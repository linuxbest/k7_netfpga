// ddr3_tb.v --- 
// 
// Filename: ddr3_tb.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Mar  4 20:22:50 2014 (-0800)
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
module ddr3_tb (/*AUTOARG*/
   // Outputs
   tg_compare_error, init_calib_complete, ddr3_we_n, ddr3_reset_n,
   ddr3_ras_n, ddr3_odt, ddr3_dm, ddr3_cs_n, ddr3_cke, ddr3_ck_p,
   ddr3_ck_n, ddr3_cas_n, ddr3_ba, ddr3_addr,
   // Inouts
   ddr3_dqs_p, ddr3_dqs_n, ddr3_dq,
   // Inputs
   sys_rst, sys_clk
   );

   parameter DQ_WIDTH   = 64;
   parameter DQS_WIDTH  = 8;
   parameter ROW_WIDTH  = 16;
   parameter BANK_WIDTH = 3;
   parameter DM_WIDTH   = 8;
   parameter CK_WIDTH   = 2;
   parameter CKE_WIDTH  = 2;
   parameter CS_WIDTH   = 1;
   parameter ODT_WIDTH  = 2;
   parameter nCS_PER_RANK = 1;

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		sys_clk;		// To example_inf of example_inf.v
   input		sys_rst;		// To example_top of example_top.v, ...
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [ROW_WIDTH-1:0] ddr3_addr;		// From example_top of example_top.v
   output [BANK_WIDTH-1:0] ddr3_ba;		// From example_top of example_top.v
   output		ddr3_cas_n;		// From example_top of example_top.v
   output [CK_WIDTH-1:0] ddr3_ck_n;		// From example_top of example_top.v
   output [CK_WIDTH-1:0] ddr3_ck_p;		// From example_top of example_top.v
   output [CKE_WIDTH-1:0] ddr3_cke;		// From example_top of example_top.v
   output [CS_WIDTH*nCS_PER_RANK-1:0] ddr3_cs_n;// From example_top of example_top.v
   output [DM_WIDTH-1:0] ddr3_dm;		// From example_top of example_top.v
   output [ODT_WIDTH-1:0] ddr3_odt;		// From example_top of example_top.v
   output		ddr3_ras_n;		// From example_top of example_top.v
   output		ddr3_reset_n;		// From example_top of example_top.v
   output		ddr3_we_n;		// From example_top of example_top.v
   output		init_calib_complete;	// From example_top of example_top.v
   output		tg_compare_error;	// From example_top of example_top.v
   // End of automatics
   /*AUTOINOUT*/
   // Beginning of automatic inouts (from unused autoinst inouts)
   inout [DQ_WIDTH-1:0]	ddr3_dq;		// To/From example_top of example_top.v
   inout [DQS_WIDTH-1:0] ddr3_dqs_n;		// To/From example_top of example_top.v
   inout [DQS_WIDTH-1:0] ddr3_dqs_p;		// To/From example_top of example_top.v
   // End of automatics


   wire		clk_ref_i;		// From example_inf of example_inf.v
   wire		sys_clk_i;		// From example_inf of example_inf.v


   example_top
     example_top (/*AUTOINST*/
		  // Outputs
		  .ddr3_addr		(ddr3_addr[ROW_WIDTH-1:0]),
		  .ddr3_ba		(ddr3_ba[BANK_WIDTH-1:0]),
		  .ddr3_ras_n		(ddr3_ras_n),
		  .ddr3_cas_n		(ddr3_cas_n),
		  .ddr3_we_n		(ddr3_we_n),
		  .ddr3_reset_n		(ddr3_reset_n),
		  .ddr3_ck_p		(ddr3_ck_p[CK_WIDTH-1:0]),
		  .ddr3_ck_n		(ddr3_ck_n[CK_WIDTH-1:0]),
		  .ddr3_cke		(ddr3_cke[CKE_WIDTH-1:0]),
		  .ddr3_cs_n		(ddr3_cs_n[CS_WIDTH*nCS_PER_RANK-1:0]),
		  .ddr3_dm		(ddr3_dm[DM_WIDTH-1:0]),
		  .ddr3_odt		(ddr3_odt[ODT_WIDTH-1:0]),
		  .tg_compare_error	(tg_compare_error),
		  .init_calib_complete	(init_calib_complete),
		  // Inouts
		  .ddr3_dq		(ddr3_dq[DQ_WIDTH-1:0]),
		  .ddr3_dqs_n		(ddr3_dqs_n[DQS_WIDTH-1:0]),
		  .ddr3_dqs_p		(ddr3_dqs_p[DQS_WIDTH-1:0]),
		  // Inputs
		  .sys_clk_i		(sys_clk_i),
		  .clk_ref_i		(clk_ref_i),
		  .sys_rst		(sys_rst));

  defparam example_top.SYSCLK_TYPE  = "NO_BUFFER";
  defparam example_top.REFCLK_TYPE  = "NO_BUFFER";
  defparam example_top.DQ_WIDTH     = DQ_WIDTH;
  defparam example_top.DQS_WIDTH    = DQS_WIDTH;
  defparam example_top.ROW_WIDTH    = ROW_WIDTH;
  defparam example_top.BANK_WIDTH   = BANK_WIDTH;
  defparam example_top.DM_WIDTH     = DM_WIDTH;
  defparam example_top.CK_WIDTH     = CK_WIDTH;
  defparam example_top.CKE_WIDTH    = CKE_WIDTH;
  defparam example_top.CS_WIDTH     = CS_WIDTH;
  defparam example_top.ODT_WIDTH    = ODT_WIDTH;
  defparam example_top.nCS_PER_RANK = nCS_PER_RANK;

   example_inf
     example_inf (/*AUTOINST*/
		  // Outputs
		  .sys_clk_i		(sys_clk_i),
		  .clk_ref_i		(clk_ref_i),
		  // Inputs
		  .sys_clk		(sys_clk),
		  .sys_rst		(sys_rst));
   
endmodule
// 
// ddr3_tb.v ends here
