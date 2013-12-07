// k7_netfpga_test.v --- 
// 
// Filename: k7_netfpga_test.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Nov 15 15:55:16 2013 (-0800)
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

module k7_netfpga_test (/*AUTOARG*/
   // Outputs
   tg_compare_error, init_calib_complete, c2_qdriip_w_n, c2_qdriip_sa,
   c2_qdriip_r_n, c2_qdriip_k_p, c2_qdriip_k_n, c2_qdriip_dll_off_n,
   c2_qdriip_d, c2_qdriip_bw_n, c1_qdriip_w_n, c1_qdriip_sa,
   c1_qdriip_r_n, c1_qdriip_k_p, c1_qdriip_k_n, c1_qdriip_dll_off_n,
   c1_qdriip_d, c1_qdriip_bw_n, c0_ddr3_we_n, c0_ddr3_reset_n,
   c0_ddr3_ras_n, c0_ddr3_odt, c0_ddr3_dm, c0_ddr3_cs_n, c0_ddr3_cke,
   c0_ddr3_ck_p, c0_ddr3_ck_n, c0_ddr3_cas_n, c0_ddr3_ba,
   c0_ddr3_addr, X0Y9_TX_P_OPAD, X0Y9_TX_N_OPAD, X0Y8_TX_P_OPAD,
   X0Y8_TX_N_OPAD, X0Y7_TX_P_OPAD, X0Y7_TX_N_OPAD, X0Y6_TX_P_OPAD,
   X0Y6_TX_N_OPAD, X0Y5_TX_P_OPAD, X0Y5_TX_N_OPAD, X0Y4_TX_P_OPAD,
   X0Y4_TX_N_OPAD, X0Y3_TX_P_OPAD, X0Y3_TX_N_OPAD, X0Y2_TX_P_OPAD,
   X0Y2_TX_N_OPAD, X0Y1_TX_P_OPAD, X0Y1_TX_N_OPAD, X0Y15_TX_P_OPAD,
   X0Y15_TX_N_OPAD, X0Y14_TX_P_OPAD, X0Y14_TX_N_OPAD, X0Y13_TX_P_OPAD,
   X0Y13_TX_N_OPAD, X0Y12_TX_P_OPAD, X0Y12_TX_N_OPAD, X0Y11_TX_P_OPAD,
   X0Y11_TX_N_OPAD, X0Y10_TX_P_OPAD, X0Y10_TX_N_OPAD, X0Y0_TX_P_OPAD,
   X0Y0_TX_N_OPAD,
   // Inouts
   c0_ddr3_dqs_p, c0_ddr3_dqs_n, c0_ddr3_dq,
   // Inputs
   sys_rst, clk_ref_p, clk_ref_n, c2_sys_clk_p, c2_sys_clk_n,
   c2_qdriip_q, c2_qdriip_cq_p, c2_qdriip_cq_n, c1_sys_clk_p,
   c1_sys_clk_n, c1_qdriip_q, c1_qdriip_cq_p, c1_qdriip_cq_n,
   c0_sys_clk_p, c0_sys_clk_n, X0Y9_RX_P_IPAD, X0Y9_RX_N_IPAD,
   X0Y8_RX_P_IPAD, X0Y8_RX_N_IPAD, X0Y7_RX_P_IPAD, X0Y7_RX_N_IPAD,
   X0Y6_RX_P_IPAD, X0Y6_RX_N_IPAD, X0Y5_RX_P_IPAD, X0Y5_RX_N_IPAD,
   X0Y4_RX_P_IPAD, X0Y4_RX_N_IPAD, X0Y3_RX_P_IPAD, X0Y3_RX_N_IPAD,
   X0Y2_RX_P_IPAD, X0Y2_RX_N_IPAD, X0Y1_RX_P_IPAD, X0Y1_RX_N_IPAD,
   X0Y15_RX_P_IPAD, X0Y15_RX_N_IPAD, X0Y14_RX_P_IPAD, X0Y14_RX_N_IPAD,
   X0Y13_RX_P_IPAD, X0Y13_RX_N_IPAD, X0Y12_RX_P_IPAD, X0Y12_RX_N_IPAD,
   X0Y11_RX_P_IPAD, X0Y11_RX_N_IPAD, X0Y10_RX_P_IPAD, X0Y10_RX_N_IPAD,
   X0Y0_RX_P_IPAD, X0Y0_RX_N_IPAD, Q3_CLK1_MGTREFCLK_P_IPAD,
   Q3_CLK1_MGTREFCLK_N_IPAD, Q2_CLK1_MGTREFCLK_P_IPAD,
   Q2_CLK1_MGTREFCLK_N_IPAD, Q0_CLK1_MGTREFCLK_P_IPAD,
   Q0_CLK1_MGTREFCLK_N_IPAD, Q0_CLK0_MGTREFCLK_P_IPAD,
   Q0_CLK0_MGTREFCLK_N_IPAD, IBERT_SYSCLOCK_P_IPAD
   );
   parameter C0_DDR3_ROW_WIDTH     = 16;
   parameter C0_DDR3_BANK_WIDTH    = 3;
   parameter C0_DDR3_CK_WIDTH      = 1;
   parameter C0_DDR3_CKE_WIDTH     = 1;
   parameter C0_DDR3_CS_WIDTH      = 1;
   parameter C0_DDR3_nCS_PER_RANK  = 1;
   parameter C0_DDR3_DM_WIDTH      = 8;
   parameter C0_DDR3_ODT_WIDTH     = 1;
   parameter C0_DDR3_DQ_WIDTH      = 64;
   parameter C0_DDR3_DQS_WIDTH     = 8;
   
   parameter C1_QDRIIP_NUM_DEVICES = 2;
   parameter C1_QDRIIP_DATA_WIDTH  = 36;
   parameter C1_QDRIIP_ADDR_WIDTH  = 19;
   parameter C1_QDRIIP_BW_WIDTH    = 4;
   
   parameter C2_QDRIIP_NUM_DEVICES = 2;
   parameter C2_QDRIIP_DATA_WIDTH  = 36;
   parameter C2_QDRIIP_ADDR_WIDTH  = 19;
   parameter C2_QDRIIP_BW_WIDTH    = 4;
   
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		IBERT_SYSCLOCK_P_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		Q0_CLK0_MGTREFCLK_N_IPAD;// To example_chipscope_ibert of example_chipscope_ibert.v
   input		Q0_CLK0_MGTREFCLK_P_IPAD;// To example_chipscope_ibert of example_chipscope_ibert.v
   input		Q0_CLK1_MGTREFCLK_N_IPAD;// To example_chipscope_ibert of example_chipscope_ibert.v
   input		Q0_CLK1_MGTREFCLK_P_IPAD;// To example_chipscope_ibert of example_chipscope_ibert.v
   input		Q2_CLK1_MGTREFCLK_N_IPAD;// To example_chipscope_ibert of example_chipscope_ibert.v
   input		Q2_CLK1_MGTREFCLK_P_IPAD;// To example_chipscope_ibert of example_chipscope_ibert.v
   input		Q3_CLK1_MGTREFCLK_N_IPAD;// To example_chipscope_ibert of example_chipscope_ibert.v
   input		Q3_CLK1_MGTREFCLK_P_IPAD;// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y0_RX_N_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y0_RX_P_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y10_RX_N_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y10_RX_P_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y11_RX_N_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y11_RX_P_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y12_RX_N_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y12_RX_P_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y13_RX_N_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y13_RX_P_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y14_RX_N_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y14_RX_P_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y15_RX_N_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y15_RX_P_IPAD;	// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y1_RX_N_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y1_RX_P_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y2_RX_N_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y2_RX_P_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y3_RX_N_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y3_RX_P_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y4_RX_N_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y4_RX_P_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y5_RX_N_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y5_RX_P_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y6_RX_N_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y6_RX_P_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y7_RX_N_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y7_RX_P_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y8_RX_N_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y8_RX_P_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y9_RX_N_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		X0Y9_RX_P_IPAD;		// To example_chipscope_ibert of example_chipscope_ibert.v
   input		c0_sys_clk_n;		// To example_top of example_top.v
   input		c0_sys_clk_p;		// To example_top of example_top.v
   input [C1_QDRIIP_NUM_DEVICES-1:0] c1_qdriip_cq_n;// To example_top of example_top.v
   input [C1_QDRIIP_NUM_DEVICES-1:0] c1_qdriip_cq_p;// To example_top of example_top.v
   input [C1_QDRIIP_DATA_WIDTH-1:0] c1_qdriip_q;// To example_top of example_top.v
   input		c1_sys_clk_n;		// To example_top of example_top.v
   input		c1_sys_clk_p;		// To example_top of example_top.v
   input [C2_QDRIIP_NUM_DEVICES-1:0] c2_qdriip_cq_n;// To example_top of example_top.v
   input [C2_QDRIIP_NUM_DEVICES-1:0] c2_qdriip_cq_p;// To example_top of example_top.v
   input [C2_QDRIIP_DATA_WIDTH-1:0] c2_qdriip_q;// To example_top of example_top.v
   input		c2_sys_clk_n;		// To example_top of example_top.v
   input		c2_sys_clk_p;		// To example_top of example_top.v
   input		clk_ref_n;		// To example_top of example_top.v
   input		clk_ref_p;		// To example_top of example_top.v
   input		sys_rst;		// To example_top of example_top.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		X0Y0_TX_N_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y0_TX_P_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y10_TX_N_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y10_TX_P_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y11_TX_N_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y11_TX_P_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y12_TX_N_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y12_TX_P_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y13_TX_N_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y13_TX_P_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y14_TX_N_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y14_TX_P_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y15_TX_N_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y15_TX_P_OPAD;	// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y1_TX_N_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y1_TX_P_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y2_TX_N_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y2_TX_P_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y3_TX_N_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y3_TX_P_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y4_TX_N_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y4_TX_P_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y5_TX_N_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y5_TX_P_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y6_TX_N_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y6_TX_P_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y7_TX_N_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y7_TX_P_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y8_TX_N_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y8_TX_P_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y9_TX_N_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output		X0Y9_TX_P_OPAD;		// From example_chipscope_ibert of example_chipscope_ibert.v
   output [C0_DDR3_ROW_WIDTH-1:0] c0_ddr3_addr;	// From example_top of example_top.v
   output [C0_DDR3_BANK_WIDTH-1:0] c0_ddr3_ba;	// From example_top of example_top.v
   output		c0_ddr3_cas_n;		// From example_top of example_top.v
   output [C0_DDR3_CK_WIDTH-1:0] c0_ddr3_ck_n;	// From example_top of example_top.v
   output [C0_DDR3_CK_WIDTH-1:0] c0_ddr3_ck_p;	// From example_top of example_top.v
   output [C0_DDR3_CKE_WIDTH-1:0] c0_ddr3_cke;	// From example_top of example_top.v
   output [C0_DDR3_CS_WIDTH*C0_DDR3_nCS_PER_RANK-1:0] c0_ddr3_cs_n;// From example_top of example_top.v
   output [C0_DDR3_DM_WIDTH-1:0] c0_ddr3_dm;	// From example_top of example_top.v
   output [C0_DDR3_ODT_WIDTH-1:0] c0_ddr3_odt;	// From example_top of example_top.v
   output		c0_ddr3_ras_n;		// From example_top of example_top.v
   output		c0_ddr3_reset_n;	// From example_top of example_top.v
   output		c0_ddr3_we_n;		// From example_top of example_top.v
   output [C1_QDRIIP_BW_WIDTH-1:0] c1_qdriip_bw_n;// From example_top of example_top.v
   output [C1_QDRIIP_DATA_WIDTH-1:0] c1_qdriip_d;// From example_top of example_top.v
   output		c1_qdriip_dll_off_n;	// From example_top of example_top.v
   output [C1_QDRIIP_NUM_DEVICES-1:0] c1_qdriip_k_n;// From example_top of example_top.v
   output [C1_QDRIIP_NUM_DEVICES-1:0] c1_qdriip_k_p;// From example_top of example_top.v
   output		c1_qdriip_r_n;		// From example_top of example_top.v
   output [C1_QDRIIP_ADDR_WIDTH-1:0] c1_qdriip_sa;// From example_top of example_top.v
   output		c1_qdriip_w_n;		// From example_top of example_top.v
   output [C2_QDRIIP_BW_WIDTH-1:0] c2_qdriip_bw_n;// From example_top of example_top.v
   output [C2_QDRIIP_DATA_WIDTH-1:0] c2_qdriip_d;// From example_top of example_top.v
   output		c2_qdriip_dll_off_n;	// From example_top of example_top.v
   output [C2_QDRIIP_NUM_DEVICES-1:0] c2_qdriip_k_n;// From example_top of example_top.v
   output [C2_QDRIIP_NUM_DEVICES-1:0] c2_qdriip_k_p;// From example_top of example_top.v
   output		c2_qdriip_r_n;		// From example_top of example_top.v
   output [C2_QDRIIP_ADDR_WIDTH-1:0] c2_qdriip_sa;// From example_top of example_top.v
   output		c2_qdriip_w_n;		// From example_top of example_top.v
   output		init_calib_complete;	// From example_top of example_top.v
   output		tg_compare_error;	// From example_top of example_top.v
   // End of automatics
   /*AUTOINOUT*/
   // Beginning of automatic inouts (from unused autoinst inouts)
   inout [C0_DDR3_DQ_WIDTH-1:0] c0_ddr3_dq;	// To/From example_top of example_top.v
   inout [C0_DDR3_DQS_WIDTH-1:0] c0_ddr3_dqs_n;	// To/From example_top of example_top.v
   inout [C0_DDR3_DQS_WIDTH-1:0] c0_ddr3_dqs_p;	// To/From example_top of example_top.v
   // End of automatics
   
   example_top
     example_top (/*AUTOINST*/
		  // Outputs
		  .c0_ddr3_addr		(c0_ddr3_addr[C0_DDR3_ROW_WIDTH-1:0]),
		  .c0_ddr3_ba		(c0_ddr3_ba[C0_DDR3_BANK_WIDTH-1:0]),
		  .c0_ddr3_ras_n	(c0_ddr3_ras_n),
		  .c0_ddr3_cas_n	(c0_ddr3_cas_n),
		  .c0_ddr3_we_n		(c0_ddr3_we_n),
		  .c0_ddr3_reset_n	(c0_ddr3_reset_n),
		  .c0_ddr3_ck_p		(c0_ddr3_ck_p[C0_DDR3_CK_WIDTH-1:0]),
		  .c0_ddr3_ck_n		(c0_ddr3_ck_n[C0_DDR3_CK_WIDTH-1:0]),
		  .c0_ddr3_cke		(c0_ddr3_cke[C0_DDR3_CKE_WIDTH-1:0]),
		  .c0_ddr3_cs_n		(c0_ddr3_cs_n[C0_DDR3_CS_WIDTH*C0_DDR3_nCS_PER_RANK-1:0]),
		  .c0_ddr3_dm		(c0_ddr3_dm[C0_DDR3_DM_WIDTH-1:0]),
		  .c0_ddr3_odt		(c0_ddr3_odt[C0_DDR3_ODT_WIDTH-1:0]),
		  .tg_compare_error	(tg_compare_error),
		  .init_calib_complete	(init_calib_complete),
		  .c1_qdriip_k_p	(c1_qdriip_k_p[C1_QDRIIP_NUM_DEVICES-1:0]),
		  .c1_qdriip_k_n	(c1_qdriip_k_n[C1_QDRIIP_NUM_DEVICES-1:0]),
		  .c1_qdriip_d		(c1_qdriip_d[C1_QDRIIP_DATA_WIDTH-1:0]),
		  .c1_qdriip_sa		(c1_qdriip_sa[C1_QDRIIP_ADDR_WIDTH-1:0]),
		  .c1_qdriip_w_n	(c1_qdriip_w_n),
		  .c1_qdriip_r_n	(c1_qdriip_r_n),
		  .c1_qdriip_bw_n	(c1_qdriip_bw_n[C1_QDRIIP_BW_WIDTH-1:0]),
		  .c1_qdriip_dll_off_n	(c1_qdriip_dll_off_n),
		  .c2_qdriip_k_p	(c2_qdriip_k_p[C2_QDRIIP_NUM_DEVICES-1:0]),
		  .c2_qdriip_k_n	(c2_qdriip_k_n[C2_QDRIIP_NUM_DEVICES-1:0]),
		  .c2_qdriip_d		(c2_qdriip_d[C2_QDRIIP_DATA_WIDTH-1:0]),
		  .c2_qdriip_sa		(c2_qdriip_sa[C2_QDRIIP_ADDR_WIDTH-1:0]),
		  .c2_qdriip_w_n	(c2_qdriip_w_n),
		  .c2_qdriip_r_n	(c2_qdriip_r_n),
		  .c2_qdriip_bw_n	(c2_qdriip_bw_n[C2_QDRIIP_BW_WIDTH-1:0]),
		  .c2_qdriip_dll_off_n	(c2_qdriip_dll_off_n),
		  // Inouts
		  .c0_ddr3_dq		(c0_ddr3_dq[C0_DDR3_DQ_WIDTH-1:0]),
		  .c0_ddr3_dqs_n	(c0_ddr3_dqs_n[C0_DDR3_DQS_WIDTH-1:0]),
		  .c0_ddr3_dqs_p	(c0_ddr3_dqs_p[C0_DDR3_DQS_WIDTH-1:0]),
		  // Inputs
		  .c0_sys_clk_p		(c0_sys_clk_p),
		  .c0_sys_clk_n		(c0_sys_clk_n),
		  .clk_ref_p		(clk_ref_p),
		  .clk_ref_n		(clk_ref_n),
		  .c1_sys_clk_p		(c1_sys_clk_p),
		  .c1_sys_clk_n		(c1_sys_clk_n),
		  .c1_qdriip_cq_p	(c1_qdriip_cq_p[C1_QDRIIP_NUM_DEVICES-1:0]),
		  .c1_qdriip_cq_n	(c1_qdriip_cq_n[C1_QDRIIP_NUM_DEVICES-1:0]),
		  .c1_qdriip_q		(c1_qdriip_q[C1_QDRIIP_DATA_WIDTH-1:0]),
		  .c2_sys_clk_p		(c2_sys_clk_p),
		  .c2_sys_clk_n		(c2_sys_clk_n),
		  .c2_qdriip_cq_p	(c2_qdriip_cq_p[C2_QDRIIP_NUM_DEVICES-1:0]),
		  .c2_qdriip_cq_n	(c2_qdriip_cq_n[C2_QDRIIP_NUM_DEVICES-1:0]),
		  .c2_qdriip_q		(c2_qdriip_q[C2_QDRIIP_DATA_WIDTH-1:0]),
		  .sys_rst		(sys_rst));

   example_chipscope_ibert
     example_chipscope_ibert (/*AUTOINST*/
			      // Outputs
			      .X0Y0_TX_P_OPAD	(X0Y0_TX_P_OPAD),
			      .X0Y0_TX_N_OPAD	(X0Y0_TX_N_OPAD),
			      .X0Y1_TX_P_OPAD	(X0Y1_TX_P_OPAD),
			      .X0Y1_TX_N_OPAD	(X0Y1_TX_N_OPAD),
			      .X0Y2_TX_P_OPAD	(X0Y2_TX_P_OPAD),
			      .X0Y2_TX_N_OPAD	(X0Y2_TX_N_OPAD),
			      .X0Y3_TX_P_OPAD	(X0Y3_TX_P_OPAD),
			      .X0Y3_TX_N_OPAD	(X0Y3_TX_N_OPAD),
			      .X0Y4_TX_P_OPAD	(X0Y4_TX_P_OPAD),
			      .X0Y4_TX_N_OPAD	(X0Y4_TX_N_OPAD),
			      .X0Y5_TX_P_OPAD	(X0Y5_TX_P_OPAD),
			      .X0Y5_TX_N_OPAD	(X0Y5_TX_N_OPAD),
			      .X0Y6_TX_P_OPAD	(X0Y6_TX_P_OPAD),
			      .X0Y6_TX_N_OPAD	(X0Y6_TX_N_OPAD),
			      .X0Y7_TX_P_OPAD	(X0Y7_TX_P_OPAD),
			      .X0Y7_TX_N_OPAD	(X0Y7_TX_N_OPAD),
			      .X0Y8_TX_P_OPAD	(X0Y8_TX_P_OPAD),
			      .X0Y8_TX_N_OPAD	(X0Y8_TX_N_OPAD),
			      .X0Y9_TX_P_OPAD	(X0Y9_TX_P_OPAD),
			      .X0Y9_TX_N_OPAD	(X0Y9_TX_N_OPAD),
			      .X0Y10_TX_P_OPAD	(X0Y10_TX_P_OPAD),
			      .X0Y10_TX_N_OPAD	(X0Y10_TX_N_OPAD),
			      .X0Y11_TX_P_OPAD	(X0Y11_TX_P_OPAD),
			      .X0Y11_TX_N_OPAD	(X0Y11_TX_N_OPAD),
			      .X0Y12_TX_P_OPAD	(X0Y12_TX_P_OPAD),
			      .X0Y12_TX_N_OPAD	(X0Y12_TX_N_OPAD),
			      .X0Y13_TX_P_OPAD	(X0Y13_TX_P_OPAD),
			      .X0Y13_TX_N_OPAD	(X0Y13_TX_N_OPAD),
			      .X0Y14_TX_P_OPAD	(X0Y14_TX_P_OPAD),
			      .X0Y14_TX_N_OPAD	(X0Y14_TX_N_OPAD),
			      .X0Y15_TX_P_OPAD	(X0Y15_TX_P_OPAD),
			      .X0Y15_TX_N_OPAD	(X0Y15_TX_N_OPAD),
			      // Inputs
			      .IBERT_SYSCLOCK_P_IPAD(IBERT_SYSCLOCK_P_IPAD),
			      .X0Y0_RX_P_IPAD	(X0Y0_RX_P_IPAD),
			      .X0Y0_RX_N_IPAD	(X0Y0_RX_N_IPAD),
			      .X0Y1_RX_P_IPAD	(X0Y1_RX_P_IPAD),
			      .X0Y1_RX_N_IPAD	(X0Y1_RX_N_IPAD),
			      .X0Y2_RX_P_IPAD	(X0Y2_RX_P_IPAD),
			      .X0Y2_RX_N_IPAD	(X0Y2_RX_N_IPAD),
			      .X0Y3_RX_P_IPAD	(X0Y3_RX_P_IPAD),
			      .X0Y3_RX_N_IPAD	(X0Y3_RX_N_IPAD),
			      .X0Y4_RX_P_IPAD	(X0Y4_RX_P_IPAD),
			      .X0Y4_RX_N_IPAD	(X0Y4_RX_N_IPAD),
			      .X0Y5_RX_P_IPAD	(X0Y5_RX_P_IPAD),
			      .X0Y5_RX_N_IPAD	(X0Y5_RX_N_IPAD),
			      .X0Y6_RX_P_IPAD	(X0Y6_RX_P_IPAD),
			      .X0Y6_RX_N_IPAD	(X0Y6_RX_N_IPAD),
			      .X0Y7_RX_P_IPAD	(X0Y7_RX_P_IPAD),
			      .X0Y7_RX_N_IPAD	(X0Y7_RX_N_IPAD),
			      .X0Y8_RX_P_IPAD	(X0Y8_RX_P_IPAD),
			      .X0Y8_RX_N_IPAD	(X0Y8_RX_N_IPAD),
			      .X0Y9_RX_P_IPAD	(X0Y9_RX_P_IPAD),
			      .X0Y9_RX_N_IPAD	(X0Y9_RX_N_IPAD),
			      .X0Y10_RX_P_IPAD	(X0Y10_RX_P_IPAD),
			      .X0Y10_RX_N_IPAD	(X0Y10_RX_N_IPAD),
			      .X0Y11_RX_P_IPAD	(X0Y11_RX_P_IPAD),
			      .X0Y11_RX_N_IPAD	(X0Y11_RX_N_IPAD),
			      .X0Y12_RX_P_IPAD	(X0Y12_RX_P_IPAD),
			      .X0Y12_RX_N_IPAD	(X0Y12_RX_N_IPAD),
			      .X0Y13_RX_P_IPAD	(X0Y13_RX_P_IPAD),
			      .X0Y13_RX_N_IPAD	(X0Y13_RX_N_IPAD),
			      .X0Y14_RX_P_IPAD	(X0Y14_RX_P_IPAD),
			      .X0Y14_RX_N_IPAD	(X0Y14_RX_N_IPAD),
			      .X0Y15_RX_P_IPAD	(X0Y15_RX_P_IPAD),
			      .X0Y15_RX_N_IPAD	(X0Y15_RX_N_IPAD),
			      .Q0_CLK0_MGTREFCLK_P_IPAD(Q0_CLK0_MGTREFCLK_P_IPAD),
			      .Q0_CLK0_MGTREFCLK_N_IPAD(Q0_CLK0_MGTREFCLK_N_IPAD),
			      .Q0_CLK1_MGTREFCLK_P_IPAD(Q0_CLK1_MGTREFCLK_P_IPAD),
			      .Q0_CLK1_MGTREFCLK_N_IPAD(Q0_CLK1_MGTREFCLK_N_IPAD),
			      .Q2_CLK1_MGTREFCLK_P_IPAD(Q2_CLK1_MGTREFCLK_P_IPAD),
			      .Q2_CLK1_MGTREFCLK_N_IPAD(Q2_CLK1_MGTREFCLK_N_IPAD),
			      .Q3_CLK1_MGTREFCLK_P_IPAD(Q3_CLK1_MGTREFCLK_P_IPAD),
			      .Q3_CLK1_MGTREFCLK_N_IPAD(Q3_CLK1_MGTREFCLK_N_IPAD));
   
endmodule // k7_netfpga_test
// Local Variables:
// verilog-library-directories:("." "../mig/mig_7series_v1_9/example_design/rtl/" "")
// verilog-library-files:(".""sata_phy")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// k7_netfpga_test.v ends here
