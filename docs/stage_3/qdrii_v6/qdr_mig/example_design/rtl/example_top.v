//*****************************************************************************
// (c) Copyright 2008  2009 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 3.92
//  \   \         Application        : MIG
//  /   /         Filename           : example_top.v
// /___/   /\     Date Last Modified : $Date: 2011/06/02 07:18:30 $
// \   \  /  \    Date Created       : Wed Nov 19 2008
//  \___\/\___\
//
// Device           : Virtex-6
// Design Name      : QDRII+ SRAM
// Purpose          :
//   Top-level module. This module serves both as an example,
//   and allows the user to synthesize a self-contained design,
//   which they can use to test their hardware.
//   In addition to the memory controller, the module instantiates:
//     1. Clock generation/distribution, reset logic
//     2. IDELAY control block
//     3. Synthesizable testbench - used to model user's backend logic
//
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps/1ps

(* X_CORE_INFO = "mig_v3_92_qdriip_V6, Coregen 14.2" , CORE_GENERATION_INFO = "qdriip_V6,mig_v3_92,{LANGUAGE=Verilog, SYNTHESIS_TOOL=ISE, AXI_ENABLE=0, LEVEL=CONTROLLER, NO_OF_CONTROLLERS=1, INTERFACE_TYPE=QDR_II+_SRAM, CLK_PERIOD=5000, MEMORY_TYPE=components, MEMORY_PART=cy7c1565v18-400bzxc, DQ_WIDTH=36, NUM_DEVICES=1, FIXED_LATENCY_MODE=0, PHY_LATENCY=0, REFCLK_FREQ=200, MMCM_ADV_BANDWIDTH=OPTIMIZED, CLKFBOUT_MULT_F=8, CLKOUT_DIVIDE=4, DEBUG_PORT=ON, IODELAY_HP_MODE=ON, INTERNAL_VREF=0, DCI_INOUTS=1, INPUT_CLK_TYPE=SINGLE_ENDED}" *)
module example_top #
  (
  parameter REFCLK_FREQ        = 200,        //Iodelay Clock Frequency
  parameter IODELAY_GRP             = "IODELAY_MIG",
                                       // It is associated to a set of IODELAYs with
                                       // an IDELAYCTRL that have same IODELAY CONTROLLER
                                       // clock frequency.
  parameter MMCM_ADV_BANDWIDTH      = "OPTIMIZED",
                                       // MMCM programming algorithm 
  parameter CLKFBOUT_MULT_F    = 8,           // write PLL VCO multiplier
  parameter CLKOUT_DIVIDE      = 4,           // VCO output divisor for fast (memory) clocks
  parameter DIVCLK_DIVIDE      = 2,           // write PLL VCO divisor
  parameter CLK_PERIOD         = 5000,      //Double the Memory Clk Period (in ps)
  parameter DEBUG_PORT         = "ON",       // Enable debug port
  parameter CLK_STABLE         = 2048,        //Cycles till CQ/CQ# is stable
  parameter ADDR_WIDTH         = 19,          //Address Width
  parameter DATA_WIDTH         = 36,          //Data Width
  parameter BW_WIDTH           = 4,//Byte Write Width
  parameter BURST_LEN          = 4,           //Burst Length
  parameter NUM_DEVICES        = 1,           //No. of Connected Memories
  parameter FIXED_LATENCY_MODE = 0,           //Enable Fixed Latency
  parameter PHY_LATENCY        = 0,            //Expected Latency
  parameter SIM_CAL_OPTION     = "NONE",      // Skip various calibration steps
  parameter SIM_INIT_OPTION    = "NONE",      //Simulation only. "NONE", "SIM_MODE"
  parameter PHASE_DETECT       = "ON",       //Enable Phase detector
  parameter IBUF_LPWR_MODE     = "OFF",       // Input buffer low power mode
  parameter IODELAY_HP_MODE    = "ON",        // IODELAY High Performance Mode
  parameter TCQ                = 100,
                                                   //Simulation Register Delay
  
  parameter INPUT_CLK_TYPE     = "SINGLE_ENDED",// # of clock type
  parameter RST_ACT_LOW        = 1           //Active Low Reset
  )
  (

  input                             sys_clk,    //single ended system clocks
  input                             clk_ref,     //single ended iodelayctrl clk
  input       [NUM_DEVICES-1:0]     qdriip_cq_p,     //Memory Interface
  input       [NUM_DEVICES-1:0]     qdriip_cq_n,
  input       [DATA_WIDTH-1:0]      qdriip_q,
  output wire [NUM_DEVICES-1:0]     qdriip_k_p,
  output wire [NUM_DEVICES-1:0]     qdriip_k_n,
  output wire [DATA_WIDTH-1:0]      qdriip_d,
  output wire [ADDR_WIDTH-1:0]      qdriip_sa,
  output wire                       qdriip_w_n,
  output wire                       qdriip_r_n,
  output wire [BW_WIDTH-1:0]        qdriip_bw_n,

  output wire                       compare_error,//Status signals
  output wire                       qdriip_dll_off_n,
  output wire                       cal_done,
  input                             sys_rst  //system reset
  );

  // clog2 function - ceiling of log base 2
  function integer clog2;
    input [31:0] width;
    integer ii;
    begin
      ii = width;
      if (ii == 0) begin
        clog2 = 1;
      end else begin
        for(clog2=0; ii>0; clog2=clog2+1)
          ii = ii >> 1;
      end
    end
  endfunction


  // Number of taps in target IDELAY
  localparam integer DEVICE_TAPS = 32;

  // Number of bits needed to represent DEVICE_TAPS
  localparam integer TAP_BITS = clog2(DEVICE_TAPS - 1);
  localparam integer CQ_BITS  = clog2(NUM_DEVICES - 1); // number of bits to represent number of cq/cq#'s
  localparam integer Q_BITS   = clog2(DATA_WIDTH - 1);  // number of bits needed to represent number of q's


  wire                                clk_ref_p;
  wire                                clk_ref_n;
  wire                                sys_clk_p;
  wire                                sys_clk_n;
  wire                                mmcm_clk;
  wire                            iodelay_ctrl_rdy;

  wire                            clk;
  wire                            rst_clk;
  wire                            clk_mem;
  wire                            clk_wr;
  wire                            mmcm_locked;
  wire                            user_wr_cmd0;
  wire                            user_wr_cmd1;
  wire [ADDR_WIDTH-1:0]           user_wr_addr0;
  wire [ADDR_WIDTH-1:0]           user_wr_addr1;
  wire                            user_rd_cmd0;
  wire                            user_rd_cmd1;
  wire [ADDR_WIDTH-1:0]           user_rd_addr0;
  wire [ADDR_WIDTH-1:0]           user_rd_addr1;
  wire [BURST_LEN*DATA_WIDTH-1:0] user_wr_data0;
  wire [DATA_WIDTH*2-1:0]         user_wr_data1;
  wire [BURST_LEN*BW_WIDTH-1:0]   user_wr_bw_n0;
  wire [BW_WIDTH*2-1:0]           user_wr_bw_n1;
  wire                            user_cal_done;
  wire                            user_rd_valid0;
  wire                            user_rd_valid1;
  wire [BURST_LEN*DATA_WIDTH-1:0] user_rd_data0;
  wire [DATA_WIDTH*2-1:0]         user_rd_data1;


  wire [1:0]                        dbg_phy_wr_cmd_n;
  wire [ADDR_WIDTH*BURST_LEN-1:0]   dbg_phy_addr;
  wire [1:0]                        dbg_phy_rd_cmd_n;
  wire [DATA_WIDTH*BURST_LEN-1:0]   dbg_phy_wr_data;
  wire                              dbg_inc_cq_all;         // increment all CQs
  wire                              dbg_inc_cqn_all;        // increment all CQ#s
  wire                              dbg_inc_q_all;          // increment all Qs
  wire                              dbg_dec_cq_all;         // decrement all CQs
  wire                              dbg_dec_cqn_all;        // decrement all CQ#s
  wire                              dbg_dec_q_all;          // decrement all Qs
  wire                              dbg_inc_cq;             // increment selected CQ
  wire                              dbg_inc_cqn;            // increment selected CQ#
  wire                              dbg_inc_q;              // increment selected Q
  wire                              dbg_dec_cq;             // decrement selected CQ
  wire                              dbg_dec_cqn;            // decrement selected CQ#
  wire                              dbg_dec_q;              // decrement selected Q
  wire [CQ_BITS-1:0]                dbg_sel_cq;             // selected CQ bit
  wire [CQ_BITS-1:0]                dbg_sel_cqn;            // selected CQ# bit
  wire [Q_BITS-1:0]                 dbg_sel_q;              // selected Q bit
  wire [TAP_BITS*NUM_DEVICES-1:0]   dbg_cq_tapcnt;          // tap count for each cq
  wire [TAP_BITS*NUM_DEVICES-1:0]   dbg_cqn_tapcnt;         // tap count for each cq#
  wire [TAP_BITS*DATA_WIDTH-1:0]    dbg_q_tapcnt;           // tap count for each q
  wire [NUM_DEVICES-1:0]            dbg_clk_rd;             // clk_rd in each domain
  wire [255:0]                      dbg_rd_stage1_cal;      // stage 1 cal debug
  wire [127:0]                      dbg_stage2_cal;         // stage 2 cal debug
  wire [CQ_BITS-1:0]                dbg_cq_num;             // current cq/cq# being calibrated
  wire [Q_BITS-1:0]                 dbg_q_bit;              // current q being calibrated
  wire [4:0]                        dbg_valid_lat;          // latency of the system
  wire [NUM_DEVICES-1:0]            dbg_phase;              // data align phase indication
  wire [NUM_DEVICES-1:0]            dbg_inc_latency;        // increase latency for dcb
  wire [5*NUM_DEVICES-1:0]          dbg_dcb_wr_ptr;         // dcb write pointers
  wire [5*NUM_DEVICES-1:0]          dbg_dcb_rd_ptr;         // dcb read pointers
  wire [4*DATA_WIDTH-1:0]           dbg_dcb_din;            // dcb data in
  wire [4*DATA_WIDTH-1:0]           dbg_dcb_dout;           // dcb data out
  wire [NUM_DEVICES-1:0]            dbg_error_max_latency;  // stage 2 cal max latency error
  wire                              dbg_error_adj_latency;  // stage 2 cal latency adjustment error
  wire [NUM_DEVICES-1:0]            dbg_pd_calib_start;     // indicates phase detector to start
  wire [NUM_DEVICES-1:0]            dbg_pd_calib_done;      // indicates phase detector is complete
  wire [7:0]                        dbg_phy_status;         // phy status
  wire                              cmp_err;
  wire                              dbg_clear_error;
  wire                              dbg_pd_off;
  wire [DATA_WIDTH-1:0]             dbg_align_rd0;
  wire [DATA_WIDTH-1:0]             dbg_align_rd1;
  wire [DATA_WIDTH-1:0]             dbg_align_fd0;
  wire [DATA_WIDTH-1:0]             dbg_align_fd1;
  wire                              qdriip_cs0_clk;
  wire [35:0]                       qdriip_cs0_control;
  wire [255:0]                      qdriip_cs0_data;
  wire [7:0]                        qdriip_cs0_trig;

  wire                              qdriip_cs1_clk;
  wire [35:0]                       qdriip_cs1_control;
  wire [255:0]                      qdriip_cs1_data;
  wire [7:0]                        qdriip_cs1_trig;

  wire [255:0]                      qdriip_cs2_async_in;
  wire                              qdriip_cs2_clk;
  wire [35:0]                       qdriip_cs2_control;
  wire [35:0]                       qdriip_cs2_sync_out;

  wire [15:0]                       qdriip_trigger;


  assign clk_ref_p = 1'b0;
  assign clk_ref_n = 1'b0;
  assign sys_clk_p = 1'b0;
  assign sys_clk_p = 1'b0;


  iodelay_ctrl #(
  .IODELAY_GRP        (IODELAY_GRP),
  .INPUT_CLK_TYPE     (INPUT_CLK_TYPE),
  .RST_ACT_LOW        (RST_ACT_LOW),
  .TCQ                (TCQ)
  ) u_iodelay_ctrl (
    .sys_rst          (sys_rst),
    .clk_ref_p        (clk_ref_p),
    .clk_ref_n        (clk_ref_n),
    .clk_ref          (clk_ref),
    .iodelay_ctrl_rdy (iodelay_ctrl_rdy)
  );
  clk_ibuf #
    (
     .INPUT_CLK_TYPE (INPUT_CLK_TYPE)
     )
    u_clk_ibuf
      (
       .sys_clk_p         (sys_clk_p),
       .sys_clk_n         (sys_clk_n),
       .sys_clk           (sys_clk),
       .mmcm_clk          (mmcm_clk)
       );
  qdr_rld_infrastructure #(
    .RST_ACT_LOW        (RST_ACT_LOW),
    .CLK_PERIOD         (CLK_PERIOD),
    .MMCM_ADV_BANDWIDTH (MMCM_ADV_BANDWIDTH),
    .CLKFBOUT_MULT_F    (CLKFBOUT_MULT_F),
    .CLKOUT_DIVIDE      (CLKOUT_DIVIDE),
    .DIVCLK_DIVIDE      (DIVCLK_DIVIDE)
  ) u_infrastructure (
    .mmcm_clk    (mmcm_clk),
    .sys_rst     (sys_rst),
    .clk0        (clk_mem),
    .clkdiv0     (clk),
    .clk_wr      (clk_wr),
    .mmcm_locked (mmcm_locked)
  );


  //Instantiate the User Interface Module (PHY)
  user_top #(
    .ADDR_WIDTH         (ADDR_WIDTH),
    .DATA_WIDTH         (DATA_WIDTH),
    .BW_WIDTH           (BW_WIDTH),
    .BURST_LEN          (BURST_LEN),
    .CLK_PERIOD         (CLK_PERIOD),
    .REFCLK_FREQ        (REFCLK_FREQ),
    .NUM_DEVICES        (NUM_DEVICES),
    .IODELAY_GRP        (IODELAY_GRP),
    .FIXED_LATENCY_MODE (FIXED_LATENCY_MODE),
    .PHY_LATENCY        (PHY_LATENCY),
    .CLK_STABLE         (CLK_STABLE),
    .MEM_TYPE           ("QDR2PLUS"),
    .DEVICE_ARCH        ("virtex6"),
    .RST_ACT_LOW        (RST_ACT_LOW),
    .PHASE_DETECT       (PHASE_DETECT),
    .SIM_CAL_OPTION     (SIM_CAL_OPTION),
    .SIM_INIT_OPTION    (SIM_INIT_OPTION),
    .IBUF_LPWR_MODE     (IBUF_LPWR_MODE),
    .IODELAY_HP_MODE    (IODELAY_HP_MODE),
    .CQ_BITS            (CQ_BITS),
    .Q_BITS             (Q_BITS),
    .DEVICE_TAPS        (DEVICE_TAPS),
    .TAP_BITS           (TAP_BITS),
    .DEBUG_PORT         (DEBUG_PORT),
    .TCQ                (TCQ)
  ) u_user_top (
    .clk                    (clk),
    .rst_clk                (rst_clk),
    .sys_rst                (sys_rst),
    .clk_mem                (clk_mem),
    .clk_wr                 (clk_wr),
    .mmcm_locked            (mmcm_locked),
    .iodelay_ctrl_rdy       (iodelay_ctrl_rdy),
    .user_wr_cmd0           (user_wr_cmd0),
    .user_wr_cmd1           (user_wr_cmd1),
    .user_wr_addr0          (user_wr_addr0),
    .user_wr_addr1          (user_wr_addr1),
    .user_rd_cmd0           (user_rd_cmd0),
    .user_rd_cmd1           (user_rd_cmd1),
    .user_rd_addr0          (user_rd_addr0),
    .user_rd_addr1          (user_rd_addr1),
    .user_wr_data0          (user_wr_data0),
    .user_wr_data1          (user_wr_data1),
    .user_wr_bw_n0          (user_wr_bw_n0),
    .user_wr_bw_n1          (user_wr_bw_n1),
    .user_cal_done          (cal_done),
    .user_rd_valid0         (user_rd_valid0),
    .user_rd_valid1         (user_rd_valid1),
    .user_rd_data0          (user_rd_data0),
    .user_rd_data1          (user_rd_data1),
    .qdr_dll_off_n          (qdriip_dll_off_n),
    .qdr_k_p                (qdriip_k_p),
    .qdr_k_n                (qdriip_k_n),
    .qdr_sa                 (qdriip_sa),
    .qdr_w_n                (qdriip_w_n),
    .qdr_r_n                (qdriip_r_n),
    .qdr_bw_n               (qdriip_bw_n),
    .qdr_d                  (qdriip_d),
    .qdr_q                  (qdriip_q),
    .qdr_cq_p               (qdriip_cq_p),
    .qdr_cq_n               (qdriip_cq_n),
    .dbg_phy_wr_cmd_n       (dbg_phy_wr_cmd_n),
    .dbg_phy_addr           (dbg_phy_addr),
    .dbg_phy_rd_cmd_n       (dbg_phy_rd_cmd_n),
    .dbg_phy_wr_data        (dbg_phy_wr_data),
    .dbg_inc_cq_all         (dbg_inc_cq_all),
    .dbg_inc_cqn_all        (dbg_inc_cqn_all),
    .dbg_inc_q_all          (dbg_inc_q_all),
    .dbg_dec_cq_all         (dbg_dec_cq_all),
    .dbg_dec_cqn_all        (dbg_dec_cqn_all),
    .dbg_dec_q_all          (dbg_dec_q_all),
    .dbg_inc_cq             (dbg_inc_cq),
    .dbg_inc_cqn            (dbg_inc_cqn),
    .dbg_inc_q              (dbg_inc_q),
    .dbg_dec_cq             (dbg_dec_cq),
    .dbg_dec_cqn            (dbg_dec_cqn),
    .dbg_dec_q              (dbg_dec_q),
    .dbg_sel_cq             (dbg_sel_cq),
    .dbg_sel_cqn            (dbg_sel_cqn),
    .dbg_sel_q              (dbg_sel_q),
    .dbg_cq_tapcnt          (dbg_cq_tapcnt),
    .dbg_cqn_tapcnt         (dbg_cqn_tapcnt),
    .dbg_q_tapcnt           (dbg_q_tapcnt),
    .dbg_clk_rd             (dbg_clk_rd),
    .dbg_rd_stage1_cal      (dbg_rd_stage1_cal),
    .dbg_stage2_cal         (dbg_stage2_cal),
    .dbg_cq_num             (dbg_cq_num),
    .dbg_q_bit              (dbg_q_bit),
    .dbg_valid_lat          (dbg_valid_lat),
    .dbg_phase              (dbg_phase),
    .dbg_inc_latency        (dbg_inc_latency),
    .dbg_dcb_wr_ptr         (dbg_dcb_wr_ptr),
    .dbg_dcb_rd_ptr         (dbg_dcb_rd_ptr),
    .dbg_dcb_din            (dbg_dcb_din),
    .dbg_dcb_dout           (dbg_dcb_dout),
    .dbg_error_max_latency  (dbg_error_max_latency),
    .dbg_error_adj_latency  (dbg_error_adj_latency),
    .dbg_pd_calib_start     (dbg_pd_calib_start),
    .dbg_pd_calib_done      (dbg_pd_calib_done),
    .dbg_pd_off             (dbg_pd_off),
    .dbg_phy_status         (dbg_phy_status),
    .dbg_align_rd0          (dbg_align_rd0),
    .dbg_align_rd1          (dbg_align_rd1),
    .dbg_align_fd0          (dbg_align_fd0),
    .dbg_align_fd1          (dbg_align_fd1)
  );


  tb_top #(
    .BURST_LEN     (BURST_LEN),
    .ADDR_WIDTH    (ADDR_WIDTH),
    .DATA_WIDTH    (DATA_WIDTH),
    .TCQ           (TCQ)
  ) u_tb_top (
    .clk           (clk),
    .rst_clk       (rst_clk),
    .wr_cmd0       (user_wr_cmd0),
    .wr_cmd1       (user_wr_cmd1),
    .wr_addr0      (user_wr_addr0),
    .wr_addr1      (user_wr_addr1),
    .rd_cmd0       (user_rd_cmd0),
    .rd_cmd1       (user_rd_cmd1),
    .rd_addr0      (user_rd_addr0),
    .rd_addr1      (user_rd_addr1),
    .wr_data0      (user_wr_data0),
    .wr_data1      (user_wr_data1),
    .wr_bw_n0      (user_wr_bw_n0),
    .wr_bw_n1      (user_wr_bw_n1),
    .rd_valid0     (user_rd_valid0),
    .rd_valid1     (user_rd_valid1),
    .rd_data0      (user_rd_data0),
    .rd_data1      (user_rd_data1),
    .cal_done      (cal_done),
    .compare_error (compare_error),
    .cmp_err       (cmp_err),
    .clear_error   (dbg_clear_error)
  );


  generate
    if (DEBUG_PORT == "OFF") begin: gen_dbg_tie_off
      assign dbg_inc_cq_all     = 1'b0;
      assign dbg_inc_cqn_all    = 1'b0;
      assign dbg_inc_q_all      = 1'b0;
      assign dbg_dec_cq_all     = 1'b0;
      assign dbg_dec_cqn_all    = 1'b0;
      assign dbg_dec_q_all      = 1'b0;
      assign dbg_inc_cq         = 1'b0;
      assign dbg_inc_cqn        = 1'b0;
      assign dbg_inc_q          = 1'b0;
      assign dbg_dec_cq         = 1'b0;
      assign dbg_dec_cqn        = 1'b0;
      assign dbg_dec_q          = 1'b0;
      assign dbg_sel_cq         = 'b0;
      assign dbg_sel_cqn        = 'b0;
      assign dbg_sel_q          = 'b0;
      assign dbg_clear_error    = 'b0;
      assign dbg_pd_off         = 'b0;
    end
  endgenerate
  generate
    if (DEBUG_PORT == "ON") begin: chipscope_inst
      assign dbg_inc_cq_all     =  qdriip_cs2_sync_out[1];
      assign dbg_inc_cqn_all    =  qdriip_cs2_sync_out[2];
      assign dbg_inc_q_all      =  qdriip_cs2_sync_out[3];
      assign dbg_dec_cq_all     =  qdriip_cs2_sync_out[4];
      assign dbg_dec_cqn_all    =  qdriip_cs2_sync_out[5];
      assign dbg_dec_q_all      =  qdriip_cs2_sync_out[6];
      assign dbg_inc_cq         =  qdriip_cs2_sync_out[7];
      assign dbg_inc_cqn        =  qdriip_cs2_sync_out[8];
      assign dbg_inc_q          =  qdriip_cs2_sync_out[9];
      assign dbg_dec_cq         =  qdriip_cs2_sync_out[10];
      assign dbg_dec_cqn        =  qdriip_cs2_sync_out[11];
      assign dbg_dec_q          =  qdriip_cs2_sync_out[12];
      assign dbg_sel_cq         =  qdriip_cs2_sync_out[13+CQ_BITS-1 : 13];
      assign dbg_sel_cqn        =  qdriip_cs2_sync_out[13+(2*CQ_BITS)-1 : 13+CQ_BITS];
      assign dbg_sel_q          =  qdriip_cs2_sync_out[13+(2*CQ_BITS)+Q_BITS-1  : 13+(2*CQ_BITS)];
      assign dbg_clear_error    =  qdriip_cs2_sync_out[13+(2*CQ_BITS)+Q_BITS];
      assign dbg_pd_off         =  qdriip_cs2_sync_out[13+(2*CQ_BITS)+Q_BITS+1];

      assign qdriip_trigger             = {8'b0, dbg_phy_status[7:1], cmp_err};

      assign qdriip_cs0_clk             =  clk;
      assign qdriip_cs0_trig            =  qdriip_trigger;
      assign qdriip_cs0_data[255:231]   = 'b0;
      assign qdriip_cs0_data[230:229]   = dbg_phy_rd_cmd_n;
      assign qdriip_cs0_data[228:227]   = dbg_phy_wr_cmd_n;
      assign qdriip_cs0_data[226:155]   = dbg_phy_wr_data;
      assign qdriip_cs0_data[154]       = user_rd_valid0;
      assign qdriip_cs0_data[153]       = user_rd_cmd0;
      assign qdriip_cs0_data[152]       = user_wr_cmd0;
      assign qdriip_cs0_data[151:148]   = user_rd_addr0[3:0];
      assign qdriip_cs0_data[147:144]   = user_wr_addr0[3:0];
      assign qdriip_cs0_data[143:72]    = user_wr_data0;
      assign qdriip_cs0_data[71:0]      = user_rd_data0;

      assign qdriip_cs1_clk  = dbg_clk_rd[0];
      assign qdriip_cs1_trig = qdriip_trigger;  // add bufr trigger

      assign qdriip_cs1_data[255:73]    =  'b0;
      assign qdriip_cs1_data[72]        =  dbg_phase;
      assign qdriip_cs1_data[71:54]     =  dbg_align_rd0[17:0];
      assign qdriip_cs1_data[53:36]     =  dbg_align_fd0[17:0];
      assign qdriip_cs1_data[35:18]     =  dbg_align_rd1[17:0];
      assign qdriip_cs1_data[17:0]      =  dbg_align_fd1[17:0];

      //vio outputs
      assign qdriip_cs2_clk             = clk;
      assign qdriip_cs2_async_in[4:0]   = dbg_cq_tapcnt[TAP_BITS-1:0];
      assign qdriip_cs2_async_in[9:5]   = dbg_cqn_tapcnt[TAP_BITS-1:0];
      assign qdriip_cs2_async_in[99:10] = dbg_q_tapcnt[89:0];

      icon u_icon
      (
       .CONTROL0 (qdriip_cs0_control),
       .CONTROL1 (qdriip_cs1_control),
       .CONTROL2 (qdriip_cs2_control)
       );

      ila u_cs0
      (
       .CLK     (qdriip_cs0_clk),
       .DATA    (qdriip_cs0_data),
       .TRIG0   (qdriip_cs0_trig),
       .CONTROL (qdriip_cs0_control)
       );

      ila u_cs1
      (
       .CLK     (qdriip_cs1_clk),
       .DATA    (qdriip_cs1_data),
       .TRIG0   (qdriip_cs1_trig),
       .CONTROL (qdriip_cs1_control)
       );

      vio u_cs2_asyncin256_syncout36
      (
       .ASYNC_IN (qdriip_cs2_async_in),
       .SYNC_OUT (qdriip_cs2_sync_out),
       .CLK      (qdriip_cs2_clk),
       .CONTROL  (qdriip_cs2_control)
       );

    end
  endgenerate


endmodule
