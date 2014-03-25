// tb.v --- 
// 
// Filename: tb.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Wed Mar 19 22:07:41 2014 (-0700)
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
`timescale 1ps/100fs

module tb;

   parameter NUM_DEVICES = 1;
   parameter DATA_WIDTH  = 36;
   parameter BW_WIDTH    = 4;
   parameter ADDR_WIDTH  = 18;

   wire [0:0] qdriip_cq_n;
   wire [0:0] qdriip_cq_p;
   wire [35:0] qdriip_q;
   wire        sys_clk;
   wire        sys_rst;

   wire        init_calib_complete;
   wire [3:0]  qdriip_bw_n;
   wire        qdriip_dll_off_n;
   wire [0:0]  qdriip_k_p;
   wire [0:0]  qdriip_k_n;
   wire        qdriip_r_n;
   wire        qdriip_w_n;
   wire [35:0] qdriip_d;
   wire [17:0] qdriip_sa;
   wire        tg_compare_error;
   wire        qdriip_qvld;
   
   qdr_tb qdr_tb (/*AUTOINST*/
		  // Outputs
		  .init_calib_complete	(init_calib_complete),
		  .qdriip_bw_n		(qdriip_bw_n[BW_WIDTH-1:0]),
		  .qdriip_d		(qdriip_d[DATA_WIDTH-1:0]),
		  .qdriip_dll_off_n	(qdriip_dll_off_n),
		  .qdriip_k_n		(qdriip_k_n[NUM_DEVICES-1:0]),
		  .qdriip_k_p		(qdriip_k_p[NUM_DEVICES-1:0]),
		  .qdriip_r_n		(qdriip_r_n),
		  .qdriip_sa		(qdriip_sa[ADDR_WIDTH-1:0]),
		  .qdriip_w_n		(qdriip_w_n),
		  .tg_compare_error	(tg_compare_error),
		  // Inputs
		  .qdriip_cq_n		(qdriip_cq_n[NUM_DEVICES-1:0]),
		  .qdriip_cq_p		(qdriip_cq_p[NUM_DEVICES-1:0]),
		  .qdriip_q		(qdriip_q[DATA_WIDTH-1:0]),
		  .sys_clk		(sys_clk),
		  .sys_rst		(sys_rst));

   //defparam qdr_tb.example_top.SIM_BYPASS_INIT_CAL = "FAST";
   defparam qdr_tb.example_top.SIMULATION          = "TRUE";

   cyqdr2_b4 
     cyqdr2_b4  (
		 // Outputs
		 .TDO			(),
		 .QVLD			(qdriip_qvld),
		 // Inouts
		 .CQ			(qdriip_cq_p),
		 .CQb			(qdriip_cq_n),
		 .Q			(qdriip_q),
		 // Inputs
		 .TCK			(1'b0),
		 .TMS			(1'b1),
		 .TDI			(1'b0),
		 .D			(qdriip_d),
		 .K			(qdriip_k_p),
		 .Kb			(qdriip_k_n),
		 .RPSb			(qdriip_r_n),
		 .WPSb			(qdriip_w_n),
		 .BWS0b			(qdriip_bw_n[0]),
		 .BWS1b			(qdriip_bw_n[1]),
		 .BWS2b			(qdriip_bw_n[2]),
		 .BWS3b			(qdriip_bw_n[3]),
		 .ZQ			(1'b0),
		 .ODT			(1'b0),
		 .DOFF			(qdriip_dll_off_n),
		 .A			(qdriip_sa[17:0]));
   
   reg 	       reset_n;
   reg 	       clock;
   initial begin
      reset_n = 1'b0; 
      #80000 reset_n = 1'b1;
   end
   assign sys_rst = reset_n;

   initial 
      clock = 1'b0;
   always 
     clock = #(10000/2) ~clock;

   assign sys_clk = clock;
   
endmodule // tb

// Local Variables:
// verilog-library-directories:("../" ".")
// verilog-library-files:(".")
// verilog-library-extensions:(".v" ".h")
// End:

// 
// tb.v ends here
