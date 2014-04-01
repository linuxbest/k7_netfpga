//*****************************************************************************
//(c) Copyright 2009 - 2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is noot a license and does not grant any
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

////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : %version 
//  \   \         Application        : MIG
//  /   /         Filename           : qdr_phy_write_init_sm.v
// /___/   /\     Date Last Modified : $date$
// \   \  /  \    Date Created       : Nov 12, 2008 
//  \___\/\___\
//
//Device: 7 Series
//Design: QDRII+ SRAM
//
//Purpose:
//    This module
//  1. Is the initialization state machine for delay calibration before regular
//     memory transactions begin.
//  2. This sm generates control, address, and data.
//
//Revision History: 6/8/2012  Added SIM_BYPASS for OCLK_Delay Calibration logic.
//                                      8/10/2012 Added write path deskew logic.
//                  12/12/2012 Fixed Vivado warnings
////////////////////////////////////////////////////////////////////////////////


`timescale 1ps/1ps

module mig_7series_v1_9_qdr_phy_write_init_sm #
(
  parameter CLK_PERIOD      = 2500,   //Memory Clk Period (in ps)  
  parameter CLK_STABLE      = 2048,   //Cycles till CQ/CQ# are stable 
  parameter BYTE_LANE_WITH_DK = 4'h00,// BYTE vector that shows which byte lane has K clock.
                                      // "1000" : byte group 3
                                      // "0001" : byte group 0
  parameter N_DATA_LANES    = 4,
  parameter RST_ACT_LOW     = 1,      //sys reset is active low   
  parameter BURST_LEN       = 4,    //Burst Length
  parameter CK_WIDTH        = 1,
  parameter ADDR_WIDTH      = 19,   //Address Width
  parameter DATA_WIDTH      = 72,   //Data Width  
  parameter BW_WIDTH        = 8,     
  parameter SIMULATION      = "TRUE",
  parameter SIM_BYPASS_INIT_CAL = "OFF",
  parameter PO_ADJ_GAP     = 7,    //Time to wait between PO adj
  parameter TCQ            = 100   //Register Delay
)
(
  input                          clk,              //main system half freq clk
  input                          sys_rst,
  input                          rst_wr_clk,       //main write path reset  
  input                          ck_addr_cmd_delay_done,  // 90 degree offset on address/cmd done     
  input                          edge_adv_cal_done,//phase alignment done, proceed to latency calibration.
  input                          rdlvl_stg1_done,  // first stage centering done
  input                          read_cal_done,    // Read calibration done 

  output reg                     init_cal_done,    // Init calibration done 
  output wire                    edge_adv_cal_start,
  output reg                     rdlvl_stg1_start,
  output reg                     cal_stage2_start,
  
  input [N_DATA_LANES-1:0]       phase_valid,
  
  //  
  output                         rst_clk,
  
  //Initialization signals
  
  output reg                     init_done,        //init done, cal can begin
  output reg  [DATA_WIDTH*2-1:0] init_wr_data0,    //init sm write data 0
  output reg  [DATA_WIDTH*2-1:0] init_wr_data1,    //init sm write data 1
  output reg  [ADDR_WIDTH-1:0]   init_wr_addr0,    //init sm write addr 0
  output reg  [ADDR_WIDTH-1:0]   init_wr_addr1,    //init sm write addr 1
  output reg  [ADDR_WIDTH-1:0]   init_rd_addr0,    //init sm read addr 0
  output reg  [ADDR_WIDTH-1:0]   init_rd_addr1,    //init sma read addr 1
  output reg  [1:0]              init_rd_cmd,      //init sm read command
  output reg  [1:0]              init_wr_cmd,      //init sm write command
  output reg                    mem_dll_off_n,

  //write calibration signals to adjust PO's stage 2 and stage 3 delays 
  input [8:0]                    po_counter_read_val,  
  output reg                     cal1_rdlvl_restart,
  output reg                     wrcal_en,
  output reg                     wrlvl_po_f_inc,
  output reg                        wrlvl_po_f_dec,
  output reg                     wrlvl_calib_in_common,
  output wire [1:0]              wrcal_byte_sel,
  output reg                     po_sel_fine_oclk_delay,
  
  //Debug Signals
  input [2:0]                    dbg_MIN_STABLE_EDGE_CNT,
  output wire [255:0]            dbg_wr_init,
  input                          dbg_phy_init_wr_only,
  input                          dbg_phy_init_rd_only ,    
  input                          dbg_SM_No_Pause,

  input                          dbg_SM_en


);

// need to bring out initialization command, data, mem_dll_off_n,

  //Local Parameter Declarations
  //Four states in the init sm, one-hot encoded
  localparam CAL_INIT                  =  15'b000000000000001;
  localparam CAL1_WRITE                =  15'b000000000000010;  
  localparam CAL1_READ                 =  15'b000000000000100;  //0x004
  localparam CAL2_WRITE                =  15'b000000000001000;  //0x008
  localparam CAL2_READ_CONT            =  15'b000000000010000;  //0x010
  
  localparam CAL2_READ                 =  15'b000000000100000;  //0x020
  localparam OCLK_RECAL                =  15'b000000001000000;  //0x040
  localparam PO_ADJ                    =  15'b000000010000000;  //0x080
  localparam CAL2_READ_WAIT            =  15'b000000100000000;  //0x100
  localparam CAL_DONE                  =  15'b000001000000000;  //0x200
  localparam CAL_DONE_WAIT             =  15'b000010000000000;  // 0x400
  localparam PO_ADJ_WAIT               =  15'b000100000000000;  //0x800
  localparam PO_STG3_DEC_TO_FIRST_EDGE =  15'b001000000000000;  //0x1000
  localparam NEXT_BYTE_DESKEW          =  15'b010000000000000;  //0x2000
  localparam FINAL_OCLK_ADJ            =  15'b100000000000000;  //0x4000

  //Stage 1 Calibration Pattern
  //00FF_FF00
  //00FF_00FF
  // Based on Timing analysis, stage1 data can use PRBS similar to DDR3 or the same pattern in V6
  localparam [DATA_WIDTH*8-1:0] DATA_STAGE1 = 
                                {{DATA_WIDTH{1'b0}}, {DATA_WIDTH{1'b1}},
                                 {DATA_WIDTH{1'b0}}, {DATA_WIDTH{1'b1}},
                                 {DATA_WIDTH{1'b1}}, {DATA_WIDTH{1'b0}},
                                 {DATA_WIDTH{1'b0}}, {DATA_WIDTH{1'b1}}};
                                 

  //Stage 2 Calibration Pattern 
  //AAAA_AAAA
  localparam  PATTERN_5 = 9'h155;
  localparam  PATTERN_A = 9'h0AA;
  
  // stage2 - F-0-5_A pattern
  
  // R0_F0_R1_F1 data pattern                                            
  localparam [DATA_WIDTH*4-1:0] DATA_STAGE2 = { {BW_WIDTH{PATTERN_A}},{BW_WIDTH{PATTERN_5}},
                                                {DATA_WIDTH{1'b0}},{DATA_WIDTH{1'b1}}};  
                                                
  
  // # of clock cycles to delay deassertion of reset. Needs to be a fairly
  // high number not so much for metastability protection, but to give time
  // for reset (i.e. stable clock cycles) to propagate through all state
  // machines and to all control signals (i.e. not all control signals have
  // resets, instead they rely on base state logic being reset, and the effect
  // of that reset propagating through the logic). Need this because we may not
  // be getting stable clock cycles while reset asserted (i.e. since reset
  // depends on DCM lock status)
  localparam RST_SYNC_NUM = 5;  //*FIXME*
   
  //Calculate the number of cycles needed for 200 us.  This is used to
  //initialize the memory device and turn off the dll signal to it.
  localparam INIT_DONE_CNT = (SIM_BYPASS_INIT_CAL != "OFF") 
                          ? (4*1000*1000/(CLK_PERIOD*2)) : (200*1000*1000/(CLK_PERIOD*2));
 
  localparam INIT_DATA_PATTERN = "CLK_PATTERN" ; // PRBS_PATTERN      
  localparam INIT_ADDR_WIDTH = 3;                  
  localparam INIT_WR_ADDR_CNT = (INIT_DATA_PATTERN == "CLK_PATTERN" )? 9'h002 : 9'h100;

  //Wire Declarations
  reg   [14:0]              phy_init_cs;
  reg   [14:0]              phy_init_ns;
  reg   [19:0]              rst_delayed = 0;
  reg                      cal_stage2_start_r;
  reg   [2:0]              addr_cntr; 
  reg   [1:0]              init_wr_cmd_d;
  reg   [1:0]              init_rd_cmd_d;
  reg                      incr_addr;
                           
  wire                     sys_rst_act_hi;
  
  // initialization signals
  reg                     init_cnt_done;
  reg                     init_cnt_done_r;
  reg                     cq_stable;
  reg     [14:0]          cq_cnt;
  reg     [16:0]          init_cnt;
  (* shreg_extract = "no" *)
  (* max_fanout = "50" *)
  reg [RST_SYNC_NUM-1:0]  rst_clk_sync_r     = -1;
  reg                     rdlvl_stg1_done_r;
  reg                     found_an_edge;
  wire [DATA_WIDTH-1 :0]  prbs_o;
  reg [DATA_WIDTH-1:0] prbs_r1;
  reg [DATA_WIDTH-1:0] prbs_r2;
  reg [DATA_WIDTH-1:0] prbs_r3;
  reg [11:0]           rdlvl_timeout_counter;
  reg                  cal2_rdwait_cnt_done;
  reg [4:0]            cal2_rdwait_cnt;
  reg                  rdlvl_timeout_error;
  wire prbs_en;
  reg wrlvl_po_f_counter_en;
  reg [8:0] wrlvl_po_f_inc_counter;
  reg       fisrt_edge_found;
  reg [8:0] last_po_counter_rd_value;
  reg [8:0] found_edge_po_rdvalue,oclk_found_edge_value;
  reg [8:0] lost_edge_po_rdvalue;
  reg [8:0] inc_dec_po_counter_value;
  wire [8:0] calibrated_po_value;
  wire oclk_window_found_status;
  reg [8:0] tmpcalibrated_po_value;
  reg       wrlvl_po_f_counter_en_r;
  reg found_an_edge_r;
  reg       oclk_window_found;
  reg       finished_po_adjust;
  reg       po_oclk_dly_adjust_direction;
  reg       oclk_window_found_r;
  reg       found_an_edge_rising;
  reg [5:0] found_edge_counts;
  reg       edge_adv_cal_done_r;
  reg       inc_byte_lane_cnt;
  reg       first_deskew_attempt;
  reg       push_until_fail;
  reg       current_byte_deskewed;
  reg [5:0] deskew_counts;
  reg [N_DATA_LANES-1:0] phase_valid_r;
  reg [1:0] byte_lane_cnt;
  reg [1:0] wrcal_stg;
  wire [1:0] lane_with_K;
  reg [2:0] bytes_deskewed;
  reg [8:0]      final_oclk_delta_tap_value;
  reg       oclk_final_adjusted;
  reg       byte_lane0_valid_at_stg0_found_edge;
  reg       byte_lane1_valid_at_stg0_found_edge;
  reg       byte_lane2_valid_at_stg0_found_edge;
  reg       byte_lane3_valid_at_stg0_found_edge;
  reg       po_dec_first_edge_done;
  reg [8:0] po_dec_value;
  reg [3:0] phase_valid_cnt;
  reg dbg_SM_en_r3,dbg_SM_en_r2,dbg_SM_en_r1;
  reg cal_stage2_PO_ADJ,cal_stage2_PO_ADJ_r;
  reg SM_Run_enable;
reg [8:0] po_dec_counter;
  reg oclk_final_adjusted_r;
  reg [1:0] k_clk_adjusted_counts;
  reg  [3:0] po_gap_enforcer;   
  wire     po_adjust_rdy;


// Signals start here
  assign dbg_wr_init[255:162]  = 'b0;
  assign  dbg_wr_init[161:153] = po_dec_counter;
  assign dbg_wr_init[152]  = oclk_final_adjusted;
  assign  dbg_wr_init[151:149] = bytes_deskewed;
  
  assign dbg_wr_init[148:140]  = final_oclk_delta_tap_value;
  assign dbg_wr_init[136]  = byte_lane0_valid_at_stg0_found_edge;
  assign dbg_wr_init[137]  = byte_lane1_valid_at_stg0_found_edge;
  assign dbg_wr_init[138]  = byte_lane2_valid_at_stg0_found_edge;
  assign dbg_wr_init[139]  = byte_lane3_valid_at_stg0_found_edge;
  assign dbg_wr_init[135:132]  = phase_valid_cnt;
  assign dbg_wr_init[131:126]  = found_edge_counts;
  assign dbg_wr_init[125:122]  = phase_valid;
  
   assign dbg_wr_init[120]  = po_dec_first_edge_done;
  assign dbg_wr_init[119:111]  = inc_dec_po_counter_value;
  assign dbg_wr_init[110:102]  = wrlvl_po_f_inc_counter;
   assign dbg_wr_init[101:100]  = lane_with_K;
  assign dbg_wr_init[99:98]  = wrcal_byte_sel;
  assign dbg_wr_init[97]  = po_sel_fine_oclk_delay;
  assign dbg_wr_init[96]  = wrlvl_calib_in_common;
  assign dbg_wr_init[95]  = wrlvl_po_f_dec;
  
  assign dbg_wr_init[94]  = wrlvl_po_f_inc;
  
  assign dbg_wr_init[93]  = wrcal_en;
  assign dbg_wr_init[84 +:9]  =po_counter_read_val;
  assign dbg_wr_init[75 +:9]  = last_po_counter_rd_value;
  assign dbg_wr_init[65] = SM_Run_enable;
  
  assign dbg_wr_init[64] = cal_stage2_start;
  assign dbg_wr_init[63] = edge_adv_cal_done;
  
  assign dbg_wr_init[62] = finished_po_adjust;
  assign dbg_wr_init[50 +: 12]  = rdlvl_timeout_counter;
  assign dbg_wr_init[49]  =   found_an_edge;
  assign dbg_wr_init[48]  =   po_sel_fine_oclk_delay;
  assign dbg_wr_init[47]  = wrlvl_po_f_counter_en_r;   

  assign dbg_wr_init[45]  = rdlvl_timeout_error;   
  assign dbg_wr_init[44]  = oclk_window_found; 
  
  assign dbg_wr_init[35+:9]    = found_edge_po_rdvalue;
  assign dbg_wr_init[26+:9]    = lost_edge_po_rdvalue;
  
  assign dbg_wr_init[66+:9]    = calibrated_po_value;
  assign dbg_wr_init[18:4]    = phy_init_cs[14:0];   //254:240        // initialization state machine  308   :298
  assign dbg_wr_init[3]       = rdlvl_stg1_start;          // stage1 calibration start
  assign dbg_wr_init[2]       = rdlvl_stg1_done;    // 90 degree shift on address/commands done
  assign dbg_wr_init[1]       = cq_stable;                 // cq clocks from memory are stable, can start issuing commands
  assign dbg_wr_init[0]       = init_cnt_done;             // initialization count done   //294
  
  
  assign prbs_en = (phy_init_cs == CAL1_WRITE )? 1'b1 : 1'b0;

  
  always @(posedge clk) begin
    phase_valid_r <= phase_valid;
    prbs_r1 <= #TCQ prbs_o;
    prbs_r2 <= #TCQ prbs_r1;
    prbs_r3 <= #TCQ prbs_r2;
    found_an_edge_r <= found_an_edge;
    wrlvl_po_f_counter_en_r <= wrlvl_po_f_counter_en;
    oclk_window_found_r <= oclk_window_found;
  end
  
  //Start edge adv cal after stage 1 is done with calibration
  assign edge_adv_cal_start = rdlvl_stg1_done;
  
  //---------------------------------------------------------------------------
  //Initialization Logic for Memory
  //The counters below are used to determine when the CQ/CQ# clocks are stable
  //and memory initialization is complete.
  //This logic operates on the same clock and rst_wr_clk to
  //ensure the counters are in sync to that of driving the K/K# clocks.  They
  //should remain in sync as CQ/CQ# are echos of K/K#
  //---------------------------------------------------------------------------

  //De-activate mem_dll_off_n signal to SRAM after stable K/K# clock
  always @ (posedge clk)
    begin
      if (rst_wr_clk)
        mem_dll_off_n <=#TCQ 0;
      else
        mem_dll_off_n <=#TCQ 1'b1;
     end

  // Count CLK_STABLE cycles to determine that CQ/CQ# clocks are stable.  When
  // ready, both RST_CLK and RST_CLK_RD can come out of reset.  
  always @(posedge clk)
    begin
      if (rst_wr_clk)
        cq_cnt <= 0;
      else if (cq_cnt != CLK_STABLE)
        cq_cnt <= cq_cnt + 1;
    end

  always @(posedge clk)
    begin
      if (rst_wr_clk) 
        cq_stable   <=#TCQ 1'b0;
      else if (SIM_BYPASS_INIT_CAL != "OFF"  ||  SIMULATION == "TRUE") 
         cq_stable   <=#TCQ 1'b1;
      else if (cq_cnt == CLK_STABLE) 
        cq_stable   <=#TCQ 1'b1;
      
    end
      
  // RST_CLK - This reset is sync. to CLK and should be held as long as
  // clocks CQ/CQ# coming back from the memory device is not yet stable.  
  // It is assumed stable based on the parameter CLK_STABLE taken from the
  // memory spec.    
     
  assign sys_rst_act_hi   = RST_ACT_LOW ? ~sys_rst: sys_rst;  
  assign rst_clk_tmp      = ~cq_stable   | sys_rst_act_hi;
  
  always @(posedge clk or posedge rst_clk_tmp)
    if (rst_clk_tmp)
      rst_clk_sync_r <= #TCQ {RST_SYNC_NUM{1'b1}};
    else
      rst_clk_sync_r <= #TCQ rst_clk_sync_r << 1;
  
  assign rst_clk = rst_clk_sync_r[RST_SYNC_NUM-1]; 
  
   always @ (posedge clk) 
    begin
      rst_delayed[0] <=#TCQ rst_clk;
      rst_delayed[1] <=#TCQ rst_delayed[0];
      rst_delayed[2] <=#TCQ rst_delayed[1];
      rst_delayed[3] <=#TCQ rst_delayed[2];
      rst_delayed[4] <=#TCQ rst_delayed[3];
      rst_delayed[5] <=#TCQ rst_delayed[4];
      rst_delayed[6] <=#TCQ rst_delayed[5];
      rst_delayed[7] <=#TCQ rst_delayed[6];
      rst_delayed[8] <=#TCQ rst_delayed[7];
      rst_delayed[9] <=#TCQ rst_delayed[8];
      rst_delayed[10]<=#TCQ rst_delayed[9];
      rst_delayed[11]<=#TCQ rst_delayed[10];
      rst_delayed[12]<=#TCQ rst_delayed[11];
      rst_delayed[13]<=#TCQ rst_delayed[12];
      rst_delayed[14]<=#TCQ rst_delayed[13];
      rst_delayed[15]<=#TCQ rst_delayed[14];
      rst_delayed[16]<=#TCQ rst_delayed[15];              
    end 

//  //Signals to the read path that initialization can begin 

// init_done could also be tied to rst_clk
// signals the init_wait time as well as cq stable count has been met, so calibration can begin

  always @ (posedge clk)
    begin
      if (rst_clk) begin
        init_done <=#TCQ 1'b0;
      end else if (rst_delayed[16] & ~rst_delayed[15]) begin 
        init_done <=#TCQ 1'b1;
      end
    end 
    
  always @ (posedge clk)
    begin
      if (rst_clk)
         rdlvl_stg1_start <= #TCQ 1'b0;
      else if (( phy_init_cs == CAL1_READ)   || (SIM_BYPASS_INIT_CAL != "OFF" && ck_addr_cmd_delay_done))
         rdlvl_stg1_start <= #TCQ 1'b1;               
    end
    
  always @ (posedge clk)
    begin
      if (rst_clk)
         cal_stage2_start <= #TCQ 1'b0;
      else if ( phy_init_cs == CAL2_READ)   
         cal_stage2_start <= #TCQ 1'b1;               
    end
  always @ (posedge clk)
    begin
       dbg_SM_en_r1 <= dbg_SM_en;
       dbg_SM_en_r2 <= dbg_SM_en_r1;
       dbg_SM_en_r3 <= dbg_SM_en_r2;
       
    end
    
  always @ (posedge clk)
    begin
      if (rst_clk)
         cal_stage2_PO_ADJ <= #TCQ 1'b0;
      else if ( phy_init_cs == PO_ADJ)   
         cal_stage2_PO_ADJ <= #TCQ 1'b1; 
     else
         cal_stage2_PO_ADJ <= #TCQ 1'b0;
    end
  always @ (posedge clk)
    begin
         cal_stage2_PO_ADJ_r <= cal_stage2_PO_ADJ;
    end
  always @ (posedge clk)
    begin
      if (rst_clk)
         SM_Run_enable <= #TCQ 1'b1;
      else if (phy_init_cs == PO_ADJ)   
         SM_Run_enable <= #TCQ 1'b0; 
     else if (dbg_SM_en_r2 && ~dbg_SM_en_r3)
         SM_Run_enable <= #TCQ 1'b1;
         
     else
         SM_Run_enable <= SM_Run_enable;
    end
    
 // Adjusting a new either OCLKD Delay / FINE_DELAY tap position .
 // Need to reset the read_calibration with the new settings.
 always @ (posedge clk)
    begin
      if (rst_clk)
         cal1_rdlvl_restart <= 1'b0;
      else if  (phy_init_cs == NEXT_BYTE_DESKEW  || phy_init_cs == PO_ADJ_WAIT  )
         cal1_rdlvl_restart <= 1'b1;
      
      else if ((phy_init_cs == PO_ADJ || phy_init_cs == PO_STG3_DEC_TO_FIRST_EDGE ) &&  wrlvl_po_f_counter_en_r && ~wrlvl_po_f_counter_en )//|| phy_init_cs == CAL_INIT_WAIT)
         cal1_rdlvl_restart <= 1'b1;
      else
         cal1_rdlvl_restart <= 1'b0;
    end
    
    

  always @ (posedge clk)
    begin
      if (rst_clk || (phy_init_cs == OCLK_RECAL))
         rdlvl_timeout_counter <= #TCQ 'b0;
      else if ( phy_init_cs == CAL2_READ_CONT)   
         if (rdlvl_timeout_counter == 512)
 //        if (rdlvl_timeout_counter == 2048)
            rdlvl_timeout_counter <= #TCQ rdlvl_timeout_counter;
         else
            rdlvl_timeout_counter <= #TCQ rdlvl_timeout_counter + 1'b1;               
    end
  always @ (posedge clk)
    begin
      if (rst_clk)
         last_po_counter_rd_value <= #TCQ 'b0;
      else if (phy_init_cs == CAL_INIT  )
         last_po_counter_rd_value <= #TCQ po_counter_read_val;      
    end
  always @ (posedge clk)
    begin
      if (rst_clk)
         found_an_edge_rising <= #TCQ 1'd0;
      else if (found_an_edge && ~found_an_edge_r)
         found_an_edge_rising <= #TCQ 1'b1;      
      else if (~wrlvl_po_f_counter_en && wrlvl_po_f_counter_en_r)
         found_an_edge_rising <= #TCQ 1'b0;      
    end
  always @ (posedge clk)
    begin
      if (rst_clk)
         found_edge_po_rdvalue <= #TCQ 8'd0;
      else if (CK_WIDTH == 2 && bytes_deskewed == 1 && phy_init_cs ==  NEXT_BYTE_DESKEW)
      begin
         //case for CK_WIDTh == 2
      
         found_edge_po_rdvalue <= #TCQ 8'd0;
      
      end
      else if (found_an_edge_rising && ~wrlvl_po_f_counter_en && wrlvl_po_f_counter_en_r && ~oclk_window_found)
         found_edge_po_rdvalue <= #TCQ po_counter_read_val;     
    end
  always @ (posedge clk)
    begin
       edge_adv_cal_done_r <= edge_adv_cal_done;
    end    
  always @ (posedge clk)
    begin
      if (rst_clk)
         found_edge_counts <= #TCQ 'b0;
      else if (~found_an_edge && found_an_edge_r )//&& found_edge_counts < 1 )
         found_edge_counts <= #TCQ 'b0;      
      else if ( ~edge_adv_cal_done_r && edge_adv_cal_done)
//         found_edge_po_rdvalue <= #TCQ 8'h023;//last_po_counter_rd_value;      
         found_edge_counts <= #TCQ found_edge_counts + 1;      
    end
    
  
   always @ (posedge clk)
     begin
       if (rst_clk)
             phase_valid_cnt <= 'b0;
       else if (phy_init_cs == OCLK_RECAL)       
          if (phase_valid[byte_lane_cnt] && phase_valid_r[byte_lane_cnt]) 
            if ( phase_valid_cnt == dbg_MIN_STABLE_EDGE_CNT)
                phase_valid_cnt <= phase_valid_cnt;
            else 
                phase_valid_cnt <= phase_valid_cnt + 1;
          else
             phase_valid_cnt <= 'b0;
    end
     
   always @ (posedge clk)
     begin
       if (rst_clk)
             found_an_edge <= 1'b0;
      else if (CK_WIDTH == 2 && bytes_deskewed == 1 && phy_init_cs ==  NEXT_BYTE_DESKEW)
             found_an_edge <= 1'b0;
             
       else if (phy_init_cs == OCLK_RECAL)       
//          if (phase_valid[lane_with_K]  ) 
          if (phase_valid[lane_with_K] )//&& phase_valid_cnt >= dbg_MIN_STABLE_EDGE_CNT  ) 

             found_an_edge <= 1'b1;
          else
             found_an_edge <= 1'b0;
    end
 
  assign  oclk_window_found_status = (SIM_BYPASS_INIT_CAL == "FAST" || SIM_BYPASS_INIT_CAL == "SKIP") ?  1'b1 : 1'b0;
    
    
  always @ (posedge clk)
    begin
      if (rst_clk)
      begin
         oclk_window_found    <= #TCQ oclk_window_found_status;
         lost_edge_po_rdvalue <= #TCQ 'b0;
      end
      else if (CK_WIDTH == 2 && bytes_deskewed == 1 && phy_init_cs ==  NEXT_BYTE_DESKEW)
      begin
          oclk_window_found    <= #TCQ 1'b0;
         lost_edge_po_rdvalue <= #TCQ 'b0;
      end
      else if (~found_an_edge && found_an_edge_r && found_edge_counts >= 4  
              // the following condition is possible if stg3 tap resolution is small and no second
              // edge is found. 
              || (found_an_edge && last_po_counter_rd_value == 63 && bytes_deskewed > 0))
      begin
          oclk_window_found    <= #TCQ 1'b1;
         lost_edge_po_rdvalue <= #TCQ last_po_counter_rd_value - 1;   
      end
    end
  always @ (posedge clk)
    begin
      if (rst_clk)
          tmpcalibrated_po_value <= 'b0;
      else if (oclk_window_found  && wrcal_byte_sel == lane_with_K && phy_init_cs == PO_STG3_DEC_TO_FIRST_EDGE)
          tmpcalibrated_po_value <= lost_edge_po_rdvalue + found_edge_po_rdvalue ;
    end
  assign calibrated_po_value = {1'b0,tmpcalibrated_po_value[8:1]};
  always @ (posedge clk)
    begin
      if (rst_clk)
         rdlvl_timeout_error <= #TCQ 'b0;
      else if (phy_init_cs == OCLK_RECAL)
         rdlvl_timeout_error <= #TCQ 'b0;      
      else if ( phy_init_cs == CAL2_READ_CONT)   
         if ( rdlvl_timeout_counter >= 512)
       //  if ( rdlvl_timeout_counter >= 2048)
           rdlvl_timeout_error <= #TCQ  1'b1; 
    end
  always @ (posedge clk)
    begin
      if (rst_clk)
         po_sel_fine_oclk_delay <= #TCQ 'b0;
      else if (phy_init_cs == CAL_INIT)
         po_sel_fine_oclk_delay <= #TCQ 'b0;      
      else if ( phy_init_cs == OCLK_RECAL && wrcal_stg == 0  ||  phy_init_cs == FINAL_OCLK_ADJ)   
           po_sel_fine_oclk_delay <= #TCQ  1'b1; 
    end
  always @ (posedge clk)
    begin
      if (rst_clk)
         wrlvl_calib_in_common <= #TCQ 1'b0;
      else if ( phy_init_cs == OCLK_RECAL)   
         wrlvl_calib_in_common <= #TCQ  1'b1;     
      else if ( phy_init_cs == CAL_INIT)
         wrlvl_calib_in_common <= #TCQ 1'b0;
    end
 always @ (posedge clk)
 begin
   if (rst_clk)
     po_oclk_dly_adjust_direction <= 1'b0;
   else if (oclk_window_found  & ~oclk_window_found_r)
   begin
      if (calibrated_po_value > last_po_counter_rd_value)
         po_oclk_dly_adjust_direction <= 1'b1;  // need to do fine_dec
      else
         po_oclk_dly_adjust_direction <= 1'b0; // need to do fine_inc
   end
 end
 

 
  // -------------------------------------------------------------------------
  // Simple inc/dec of the PO
  // Two options, either the simple state for doing a single inc/dec or the last
  // setting where the final value is computed and we need to hit that value
  // -------------------------------------------------------------------------
  //Counter used to adjust the time between decrements
  always @ (posedge clk) begin
    if (rst_clk || wrlvl_po_f_dec || wrlvl_po_f_inc) begin
          po_gap_enforcer <= #TCQ PO_ADJ_GAP; //8 clocks between adjustments for HW
        end else if (po_gap_enforcer != 'b0 && phy_init_cs != CAL_INIT && ~init_cal_done) begin
          po_gap_enforcer <= #TCQ po_gap_enforcer - 1;
        end else begin
          po_gap_enforcer <= #TCQ po_gap_enforcer; //hold value
        end
  end
   
  assign po_adjust_rdy = (po_gap_enforcer == 'b0) ? 1'b1 : 1'b0;
 
 
  always @ (posedge clk)
    begin
      if (rst_clk) begin
         wrlvl_po_f_dec <= 1'b0;
         wrlvl_po_f_inc <= 1'b0;
      end
      else if (wrcal_byte_sel != lane_with_K &&  wrlvl_po_f_counter_en  && po_adjust_rdy )
         begin
         
         if (wrlvl_po_f_inc_counter >0 )
                  begin
                  wrlvl_po_f_dec <= 1'b0;
                  wrlvl_po_f_inc <= 1'b0;
                  
              end
                  
         else if ( wrcal_byte_sel == 0)
             if (~byte_lane0_valid_at_stg0_found_edge ||   ~phase_valid[byte_lane_cnt] && push_until_fail)
                begin
                  wrlvl_po_f_inc <= 1'b0;
                  wrlvl_po_f_dec <= 1'b1;
                  
                end
             else
                begin
                  wrlvl_po_f_inc <= 1'b1;
                  wrlvl_po_f_dec <= 1'b0;
                  
                end
         else if ( wrcal_byte_sel == 1)
             if (~byte_lane1_valid_at_stg0_found_edge ||   ~phase_valid[byte_lane_cnt] && push_until_fail)
                begin
                  wrlvl_po_f_inc <= 1'b0;
                  wrlvl_po_f_dec <=  1'b1;
                end
             else
                begin
                  wrlvl_po_f_inc <= 1'b1;
                  wrlvl_po_f_dec <= 1'b0;
                  
                end
         else if ( wrcal_byte_sel == 2)
             if (~byte_lane2_valid_at_stg0_found_edge ||   ~phase_valid[byte_lane_cnt] && push_until_fail)
                begin
                  wrlvl_po_f_inc <= 1'b0;
                  wrlvl_po_f_dec <= 1'b1;
                  
                end
             else
                begin
                  wrlvl_po_f_inc <= 1'b1;
                  wrlvl_po_f_dec <= 1'b0;
                end
             
         else if ( wrcal_byte_sel == 3)
             if (~byte_lane3_valid_at_stg0_found_edge ||   ~phase_valid[byte_lane_cnt] && push_until_fail)
                begin
                  wrlvl_po_f_inc <= 1'b0;
                  wrlvl_po_f_dec <= 1'b1;
                  
                end
             else
                begin
                  wrlvl_po_f_inc <= 1'b1;
                  wrlvl_po_f_dec <= 1'b0;
                  
                end
             


         end
     else if (phy_init_cs == PO_STG3_DEC_TO_FIRST_EDGE && oclk_window_found && ~po_dec_first_edge_done && po_adjust_rdy)
         begin
         wrlvl_po_f_dec <=  ~wrlvl_po_f_dec;// 1'b1;
         wrlvl_po_f_inc <= 1'b0;
         
         end
     else if (phy_init_cs == FINAL_OCLK_ADJ && oclk_window_found &&  po_adjust_rdy)
         begin
         wrlvl_po_f_dec <= 1'b0;
         wrlvl_po_f_inc <= ~wrlvl_po_f_inc;
         
         
         end
     
     
     else if ((wrlvl_po_f_inc_counter >0 )|| (oclk_window_found && po_dec_value >= inc_dec_po_counter_value))
         begin
         wrlvl_po_f_dec <= 1'b0;
         wrlvl_po_f_inc <= 1'b0;
         
         end
      else if (phy_init_cs == PO_ADJ && wrlvl_po_f_counter_en && ~oclk_window_found )//|| ( oclk_window_found && po_oclk_dly_adjust_direction && wrlvl_po_f_counter_en) ) //0x80
         begin
         // CALSTATE 0
         wrlvl_po_f_inc <= 1'b1;
         wrlvl_po_f_dec <= 1'b0;
         
         end
     // else if ((oclk_window_found && ~po_oclk_dly_adjust_direction && wrlvl_po_f_counter_en )) 
     //    begin
     //    //CALSTAGE 0
     //    wrlvl_po_f_inc <=  1'b0; //bug
     //    wrlvl_po_f_dec <=  1'b1;
     //    end
      else 
         begin
         wrlvl_po_f_inc <= 1'b0;
         wrlvl_po_f_dec <= 1'b0;
         
         end
    end


  always @ (posedge clk)
    begin
    
      if (rst_clk) 
         po_dec_value   <= 9'b0;
      else if ((oclk_window_found && ~po_oclk_dly_adjust_direction && wrlvl_po_f_counter_en)) 
         po_dec_value   <= po_dec_value + 1 ;
         
      end
    
 always @ (posedge clk)
  begin
  if (rst_clk  || phy_init_cs == CAL_INIT)
    
      po_dec_counter     <= 1'b0;
  else if (wrlvl_po_f_dec && phy_init_cs == PO_STG3_DEC_TO_FIRST_EDGE )
      po_dec_counter     <= po_dec_counter + 1;
  else if (wrlvl_po_f_inc && phy_init_cs == FINAL_OCLK_ADJ )
      po_dec_counter     <= po_dec_counter + 1;
        
    end

    
 always @ (posedge clk)
  begin
  if (rst_clk)
    
      po_dec_first_edge_done     <= 1'b0;
  else if (phy_init_cs == PO_STG3_DEC_TO_FIRST_EDGE   &&
                   (po_dec_counter == inc_dec_po_counter_value ))

      po_dec_first_edge_done     <= 1'b1;
  else if (phy_init_cs == CAL_INIT)
      po_dec_first_edge_done     <= 1'b0;
  end   
 
 
 
 always @ (posedge clk)
 begin
 if (rst_clk)
     oclk_final_adjusted <= 1'b0;
 else if (phy_init_cs == FINAL_OCLK_ADJ)
     oclk_final_adjusted <= 1'b1;
    else if (k_clk_adjusted_counts == 1 && phy_init_cs == CAL_INIT  && CK_WIDTH == 2)
     oclk_final_adjusted <= 1'b0;
    
 end     

 always @ (posedge clk)
 begin
 if (rst_clk)
     oclk_final_adjusted_r <= 1'b0;
 else 
     oclk_final_adjusted_r <= oclk_final_adjusted;
 end     
 
 always @ (posedge clk)
 begin
 if (rst_clk)
     k_clk_adjusted_counts <= 'b0;
 else if (oclk_final_adjusted && ~oclk_final_adjusted_r)
     k_clk_adjusted_counts <= k_clk_adjusted_counts + 1'b1;
 end     
 
 
 always @ (posedge clk)
  begin
    if (rst_clk)
       finished_po_adjust <= 1'b0;
    else if (phy_init_cs == FINAL_OCLK_ADJ &&  (po_dec_counter == final_oclk_delta_tap_value))
       if (CK_WIDTH == 1  || (CK_WIDTH == 2 && k_clk_adjusted_counts == 2))
       finished_po_adjust <= 1'b1;
  //  else
  //     finished_po_adjust <= 1'b0;
  end    
  
 // assign inc_dec_po_counter_value = found_edge_po_value so that we can line up the rest of the byte lanes(without K clock lane)
 // to the left side of k clock at first found_edge tap position.
// assign inc_dec_po_counter_value =     last_po_counter_rd_value - calibrated_po_value;
always @ (posedge clk) 
begin   
   inc_dec_po_counter_value <= lost_edge_po_rdvalue - found_edge_po_rdvalue + 1;
   final_oclk_delta_tap_value <= calibrated_po_value - found_edge_po_rdvalue;
end   
   
  always @ (posedge clk)
    begin
      if (rst_clk)
         wrlvl_po_f_counter_en <= 'b0;
      else if (phy_init_cs == FINAL_OCLK_ADJ && wrlvl_po_f_inc_counter == final_oclk_delta_tap_value) 
         wrlvl_po_f_counter_en <= 'b0;
         
      else if ((wrlvl_po_f_inc_counter >=2 && (!oclk_window_found || wrcal_byte_sel != lane_with_K)) || 
               ((wrlvl_po_f_inc_counter >= inc_dec_po_counter_value) && (oclk_window_found && wrcal_byte_sel == lane_with_K)) )
         wrlvl_po_f_counter_en <= 1'b0;
      else if (phy_init_cs == PO_ADJ || phy_init_cs == PO_STG3_DEC_TO_FIRST_EDGE || phy_init_cs == FINAL_OCLK_ADJ)  //0x80
         wrlvl_po_f_counter_en <= 1'b1;
      else
         wrlvl_po_f_counter_en <= wrlvl_po_f_counter_en;
    end
    
    
  always @ (posedge clk)
    begin
      if (rst_clk)
         wrlvl_po_f_inc_counter <= 'b0;
      else if (phy_init_cs == CAL_INIT ||  (~wrlvl_po_f_counter_en && wrlvl_po_f_counter_en_r))
         wrlvl_po_f_inc_counter <= 'b0;
      else if (wrlvl_po_f_counter_en && po_adjust_rdy)
         wrlvl_po_f_inc_counter <= wrlvl_po_f_inc_counter + 1;
      else 
         wrlvl_po_f_inc_counter <= wrlvl_po_f_inc_counter;
    end

  always @ (posedge clk) 
    begin
      if (rst_wr_clk) begin
        cal_stage2_start_r <=#TCQ 1'b0;
        rdlvl_stg1_done_r  <=#TCQ 1'b0;
      end else begin
        cal_stage2_start_r <=#TCQ edge_adv_cal_done;
        rdlvl_stg1_done_r  <=#TCQ rdlvl_stg1_done;
      end
    end
    
 // rewrite incr_addr to avoid combinational logic to drive gated clock	.  12/2012

   always @ (posedge clk)
    begin
      if (rst_wr_clk ) 
        incr_addr <=#TCQ 1'b0;
      else if (phy_init_cs == CAL_INIT && ck_addr_cmd_delay_done)
        incr_addr <=#TCQ 1'b1;
      else if (phy_init_cs == PO_ADJ && wrlvl_po_f_counter_en_r && ~wrlvl_po_f_counter_en ||
               phy_init_cs == CAL_DONE_WAIT)
        incr_addr <=#TCQ 1'b0;
    end

  //addr_cntr is used to select the data for initalization writes and
  //addressing.  The LSB is used to index data while [ADDR_WIDTH-1:1] is used
  //as the address therefore it is incremented by 2.
  always @ (posedge clk) 
    begin
      if (rst_wr_clk | cal1_rdlvl_restart) begin
        addr_cntr <=#TCQ 3'b000;

      end else if ( ( rdlvl_stg1_done && (BURST_LEN == 4))||
                    ( ~rdlvl_stg1_done_r & rdlvl_stg1_done && (BURST_LEN ==2))
                    && !dbg_phy_init_wr_only && !dbg_phy_init_rd_only)  begin
      //end else if (rdlvl_stg1_done) begin
          addr_cntr <= #TCQ 3'b000;

      end else if (incr_addr) begin
        addr_cntr[1:0] <=#TCQ addr_cntr + 2;
        addr_cntr[2]   <=#TCQ 1'b0;

      end
    end
    
  always @ (posedge clk)
    begin
      if (rst_wr_clk  || cal1_rdlvl_restart) begin
         cal2_rdwait_cnt <=  5'b11111;  //for debug 5'b00011;
      end else if (edge_adv_cal_done && cal2_rdwait_cnt != 0) begin
         cal2_rdwait_cnt <= cal2_rdwait_cnt -1;
      end
    end
    
  always @ (posedge clk)
    begin
      if (rst_wr_clk || cal1_rdlvl_restart) begin
         cal2_rdwait_cnt_done <= 1'b0;
      end else if (edge_adv_cal_done && cal2_rdwait_cnt == 0) begin
         cal2_rdwait_cnt_done <= 1'b1;
      end
    end
  
    

  //Register the State Machine Outputs
  always @(posedge clk)
    begin
      if (rst_wr_clk) begin
        init_wr_cmd   <=#TCQ 2'b00;
        init_rd_cmd   <=#TCQ 2'b00;
        init_wr_addr0 <=#TCQ 0;
        init_wr_addr1 <=#TCQ 0;
        init_rd_addr0 <=#TCQ 0;
        init_rd_addr1 <=#TCQ 0;        
        
        init_wr_data0 <=#TCQ 0;
        init_wr_data1 <=#TCQ 0;
        phy_init_cs   <=#TCQ CAL_INIT;


      end else begin
        init_wr_cmd   <=#TCQ init_wr_cmd_d;
        init_rd_cmd   <=#TCQ init_rd_cmd_d;

        //init_wr_addr0/init_rd_addr1 are only used in BL2 mode.  Because of
        //this, we use all the address bits to maintain using even numbers for
        //the address' on the rising edge.  For BL2 the rising edge address 
        //should cycle through values 0,2,4, and 6.  On the falling edge where
        //'*addr1' is used the address should be rising edge +1 ('*addr0' +1).  
        //To save resources, instead of adding a +1, a 1 is concatinated
        //onto the rising edge address.
        //In BL4 mode, since reads only occur on the rising edge, and writes
        //on the falling edge, we uses everything but the LSB of addr_cntr 
        //since the LSB is only used to index the data register.  For BL4, 
        //the address should access 0x0 - 0x3 in stage one and 0x0 in stage 2.
        
        init_wr_addr0 <=#TCQ addr_cntr[1:0];          //Not used in BL4 - X
        init_wr_addr1 <=#TCQ (BURST_LEN == 4) ? addr_cntr[2:1] : 
                                                {addr_cntr[1:1], 1'b1};
        init_rd_addr0 <=#TCQ (BURST_LEN == 4) ? addr_cntr[2:1] : 
                                                addr_cntr[1:0];
        init_rd_addr1 <=#TCQ {addr_cntr[1:1], 1'b1};  //Not used in BL4 - X
                

        if (INIT_DATA_PATTERN == "CLK_PATTERN") begin
                 //based on the address a bit-select is used to select 2 Data Words for
                 //the pre-defined arrary of data for read calibration.
                 init_wr_data0 <=#TCQ ((rdlvl_stg1_done) || ((SIM_BYPASS_INIT_CAL == "SKIP"  )  & ~edge_adv_cal_done)) ?
                              // R0_F0 pattern
                              DATA_STAGE2[(DATA_WIDTH*4)-1:(DATA_WIDTH*2)]:  
                             // DATA_STAGE2[(DATA_WIDTH*2)-1:0] :
                              DATA_STAGE1[(addr_cntr*DATA_WIDTH*2)+:(DATA_WIDTH*2)];
                 
                 init_wr_data1 <=#TCQ ((rdlvl_stg1_done) || ((SIM_BYPASS_INIT_CAL == "SKIP") & ~edge_adv_cal_done)) ? 
                                  //DATA_STAGE2[(DATA_WIDTH*4)-1:(DATA_WIDTH*2)]:
                                  // R1_F1 pattern
                                  DATA_STAGE2[(DATA_WIDTH*2)-1:0] :
                 DATA_STAGE1[((addr_cntr+1)*DATA_WIDTH*2)+:(DATA_WIDTH*2)];
 
                                      
        end else begin
        
                 init_wr_data0 <=#TCQ (edge_adv_cal_done) ?
                              DATA_STAGE2[(DATA_WIDTH*2)-1:0] :
                              
                              {prbs_o[DATA_WIDTH-1:0],prbs_r1[DATA_WIDTH-1:0]};
                 
                 init_wr_data1 <=#TCQ (edge_adv_cal_done) ? 
                              DATA_STAGE2[(DATA_WIDTH*4)-1:(DATA_WIDTH*2)]:
                              {prbs_r2[DATA_WIDTH-1:0],prbs_r3[DATA_WIDTH-1:0]};
                     
        end

        phy_init_cs   <=#TCQ phy_init_ns;
      end
    end

  //Initialization State Machine
  always @ *
    begin
      case (phy_init_cs)
        //In the init state, wait for ck_addr_cmd_delay_done to be asserted from the
        //read path to begin read/write transactions
        //Throughout this state machine, all outputs are registered except for 
        //incr_addr.  This is because that signal is used to set the address
        //which should be in line with the rest of the signals so it is used
        //immediately.
        CAL_INIT : begin
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = 2'b00;
          init_cal_done   = 0;
          wrcal_en        = 0;
          fisrt_edge_found = 1'b0;

          if (ck_addr_cmd_delay_done) begin
             if ((SIM_BYPASS_INIT_CAL == "SKIP" )) begin
                 phy_init_ns = CAL2_WRITE;
                                             
             end else begin
               phy_init_ns = CAL1_WRITE;
             end
          end else begin
            phy_init_ns = CAL_INIT;
          end
        end

        //Send a write command.  For BL2 mode two writes are issued to write
        //4 Data Words, in BL4 mode, only write on the falling edge by using
        //bit [1] of init_wr_cmd.
        CAL1_WRITE  :  begin
          init_wr_cmd_d   = (BURST_LEN == 4) ? 2'b10 : 2'b11;
          init_rd_cmd_d   = 2'b00;
          init_cal_done   = 0;
          wrcal_en        = 0;
          
          //On the last two data words we are done writing in stage1
          //For stage two only one write is necessary
          //if ((cal_stage2_start_r & cal_stage2_start) || 
          //    (addr_cntr == 4'b0010))
          if (addr_cntr == INIT_WR_ADDR_CNT && !dbg_phy_init_wr_only)
            phy_init_ns = CAL1_READ;
           else
            phy_init_ns =  CAL1_WRITE; 
          
        end

        //Send a write command.  For BL2 mode two reads are issued to read
        //back 4 Data Words, in BL4 mode, only read on the rising edge by using
        //bit [0] of init_rd_cmd.
        CAL1_READ   : begin
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = (BURST_LEN == 4) ? 2'b01 : 2'b11;
          init_cal_done   = 0;
          wrcal_en        = 0;

          //In stage 1 calibration, continuously read back data until stage 2 is
          //ready to begin.  in stage 2 read once then calibration is complete.
          //Only exit the read state when an entire sequence is complete (ie
          //on the last address of a sequence)
          
          // stage1 calibration complete.
          //if (~rdlvl_stg1_done_r & rdlvl_stg1_done & addr_cntr[2:0] == 3'b010)
           
          //if ( (BURST_LEN == 4) &&  ~rdlvl_stg1_done_r & rdlvl_stg1_done )
           if ( ~rdlvl_stg1_done_r & rdlvl_stg1_done && ~dbg_phy_init_rd_only )
            phy_init_ns = CAL2_WRITE;
           else
            phy_init_ns =  CAL1_READ;    
                  

        end
        
        //Send a write command.  For BL2 mode two writes are issued to write
        //4 Data Words, in BL4 mode, only write on the falling edge by using
        //bit [1] of init_wr_cmd.
        CAL2_WRITE  :  begin
          init_wr_cmd_d   = (BURST_LEN == 4) ? 2'b10 : 2'b11;
          init_rd_cmd_d   = 2'b00;
          init_cal_done   = 0;
          wrcal_en        = 0;
           
          if ((BURST_LEN == 4) || (BURST_LEN == 2 && addr_cntr[2:0] == 3'b010)) begin
             //incr_addr = 1;
             phy_init_ns = CAL2_READ_CONT;
          end else begin               
             phy_init_ns =  CAL2_WRITE;
          end
          
         end
         
         CAL2_READ_CONT: begin  //0x0010
          // continuous reads for phase alignment
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = (BURST_LEN == 4) ? 2'b01 : 2'b11;
          init_cal_done   = 0;
          wrcal_en        = 0;
         
          if ((SIM_BYPASS_INIT_CAL == "SKIP" || SIM_BYPASS_INIT_CAL == "FAST") && edge_adv_cal_done)
                phy_init_ns =  CAL2_READ_WAIT;    //0x100
          
          else if (CLK_PERIOD <= 2500)
            if ( oclk_final_adjusted && edge_adv_cal_done)
                    phy_init_ns =  CAL2_READ_WAIT;    //0x100
               
            else if ((rdlvl_timeout_error || (~oclk_window_found && edge_adv_cal_done)) )  //*** for fast SIMULATION and HW
               begin
                wrcal_en        = 1;
                phy_init_ns =  OCLK_RECAL;        //0x40
               end
            else
                phy_init_ns =  CAL2_READ_CONT;

          else if (CLK_PERIOD > 2500)
            if (edge_adv_cal_done)
                phy_init_ns =  CAL2_READ_WAIT;    //0x100
            else
                phy_init_ns =  CAL2_READ_CONT;
         end
       
         OCLK_RECAL  : begin //0x40
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = 2'b00;
         
          init_cal_done   = 0;
          wrcal_en        = 1;
          
          //phy_init_ns = PO_ADJ_WAIT;  // debug pause push_until_fail
          if (current_byte_deskewed && push_until_fail && wrcal_byte_sel !=  lane_with_K && ~first_deskew_attempt)
          // the byte has less skew delay compare to the byte with K clock.
              if ((bytes_deskewed == N_DATA_LANES - 1  && CK_WIDTH == 1) || (CK_WIDTH == 2 &&  (bytes_deskewed == 1 || bytes_deskewed == 3)))
                   phy_init_ns = FINAL_OCLK_ADJ;              
             
              else
                  phy_init_ns = NEXT_BYTE_DESKEW;              
          
          else if (phase_valid[byte_lane_cnt] && ~push_until_fail && wrcal_byte_sel !=  lane_with_K && ~first_deskew_attempt)
          // the byte has more skew delay than the byte with K Clock.
              if (bytes_deskewed == N_DATA_LANES - 1 && CK_WIDTH == 1  || (CK_WIDTH == 2 &&  (bytes_deskewed == 1 || bytes_deskewed == 3)))
                   phy_init_ns = FINAL_OCLK_ADJ;              
             
              else
                  phy_init_ns = NEXT_BYTE_DESKEW;              
          else     
              if (dbg_SM_No_Pause)
            phy_init_ns = PO_ADJ;
          else
           phy_init_ns = PO_ADJ_WAIT;
           
         end       

         PO_ADJ_WAIT : begin
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = 2'b00;
         
          init_cal_done   = 0;
          wrcal_en        = 0;
          if (SM_Run_enable)
           phy_init_ns = PO_ADJ;
          else 
           phy_init_ns = PO_ADJ_WAIT;
         end

         PO_ADJ : begin  //0x080
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = 2'b00;
         
          init_cal_done   = 0;
          wrcal_en        = 1;

          if ( wrlvl_po_f_counter_en_r && ~wrlvl_po_f_counter_en)

            if (oclk_window_found && wrcal_byte_sel ==  lane_with_K)
               phy_init_ns = PO_STG3_DEC_TO_FIRST_EDGE;//_WAIT;
            
            else
           phy_init_ns = CAL_INIT;//_WAIT;
          else
            phy_init_ns = PO_ADJ;
         end

         NEXT_BYTE_DESKEW: begin  //0x2000
            wrcal_en        = 1;
              init_cal_done   = 0;
         
            init_wr_cmd_d   = 2'b00;
            init_rd_cmd_d   = 2'b00;
            phy_init_ns = CAL_INIT;//_WAIT;
         
         
         end
         
         
         PO_STG3_DEC_TO_FIRST_EDGE : begin  //0x100
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = 2'b00;
         
            init_cal_done   = 0;
            wrcal_en        = 1;
            if (po_dec_first_edge_done)
               phy_init_ns = NEXT_BYTE_DESKEW;//CAL_INIT;//_WAIT;
            else
               phy_init_ns = PO_STG3_DEC_TO_FIRST_EDGE;//_WAIT;


         end
         CAL2_READ_WAIT: begin //0x100
          // wait time, before a single read is issued for latency calculation and read valid signal generation
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = 2'b00;
          init_cal_done   = 0;
          wrcal_en        = 0;


           if (cal2_rdwait_cnt_done && ((BURST_LEN == 4) || (BURST_LEN ==2 && addr_cntr[2:0] == 3'b010))) 
                 phy_init_ns = CAL2_READ;
           else
             phy_init_ns =  CAL2_READ_WAIT;    
         end
         
         CAL2_READ: begin
          // one read command for valid & latency determination
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = (BURST_LEN == 4) ? 2'b01 : 2'b11;
          init_cal_done   = 0;
          wrcal_en        = 0;
         
          if ((SIM_BYPASS_INIT_CAL == "SKIP" || SIM_BYPASS_INIT_CAL == "FAST") && edge_adv_cal_done)
                phy_init_ns =  CAL_DONE_WAIT;    //0x100
          
          else if (addr_cntr == 'b0) begin
             if (CLK_PERIOD > 2500)
                phy_init_ns = CAL_DONE_WAIT;
             else if (finished_po_adjust == 1 )
                phy_init_ns = CAL_DONE_WAIT;
             else
                phy_init_ns = CAL_INIT;
          end else begin
             phy_init_ns = CAL2_READ;
          end               
         end  


        FINAL_OCLK_ADJ: begin
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = 2'b00;
        
          init_cal_done   = 0;
          wrcal_en        = 1;

          // new algorhtim here ******************
          // when oclk_window found on the first round, branch to a new state to do stage 2 PO adjust on 
          // byte without DK
          
          if ( po_dec_counter >= final_oclk_delta_tap_value )//&& wrlvl_po_f_counter_en_r && ~wrlvl_po_f_counter_en)
               phy_init_ns = NEXT_BYTE_DESKEW;//_WAIT;
          else
               phy_init_ns = FINAL_OCLK_ADJ;
        
        end

        CAL_DONE_WAIT: begin
          // Stays here if all conditions met except read_cal_done
          // before asserting calibration complete
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = 2'b00;
          init_cal_done   = 0;
          wrcal_en        = 0;
         
          if (read_cal_done) begin
             phy_init_ns = CAL_DONE; 
          end else begin
             phy_init_ns = CAL_DONE_WAIT; 
          end               
        end
  
        //Calibration Complete
        CAL_DONE : begin
          init_wr_cmd_d   = 2'b00;
          init_rd_cmd_d   = 2'b00;
          init_cal_done   = 1;
          phy_init_ns     = CAL_DONE;
          wrcal_en        = 0;
        end
           
        default:   begin
          init_wr_cmd_d   = 2'bXX;
          init_rd_cmd_d   = 2'bXX;
          init_cal_done   = 0;
          phy_init_ns     = CAL_INIT;
          wrcal_en        = 0;
        end
      endcase

    end //end init sm
    
reg first_found_edge;

// flags to track the byte lane status when the phase_valid of the byte with K clock is valid.


reg first_found_edge0, first_found_edge1, first_found_edge2, first_found_edge3;

  always @ (posedge clk)
  begin
     if (rst_wr_clk)
       first_found_edge0 <= 'b1;
     else if (phase_valid[0] && ~phase_valid_r[0]  && wrcal_byte_sel == lane_with_K )
       first_found_edge0 <= 'b0;
  end

  always @ (posedge clk)
  begin
     if (rst_wr_clk)
       first_found_edge1 <= 'b1;
     else if (phase_valid[1] && ~phase_valid_r[1]  && wrcal_byte_sel == lane_with_K )
       first_found_edge1 <= 'b0;
  end
  
  generate 
  if (N_DATA_LANES > 2) begin: fnd_edge2
    always @ (posedge clk)
    begin
       if (rst_wr_clk)
         first_found_edge2 <= 'b1;
       else if (phase_valid[2] && ~phase_valid_r[2]  && wrcal_byte_sel == lane_with_K )
         first_found_edge2 <= 'b0;
    end
  
    always @ (posedge clk)
    begin
       if (rst_wr_clk)
         first_found_edge3 <= 'b1;
       else if (phase_valid[3] && ~phase_valid_r[3]  && wrcal_byte_sel == lane_with_K )
         first_found_edge3 <= 'b0;
    end
  end
  endgenerate
  
  always @ (posedge clk)
  begin
     if (rst_wr_clk)
       byte_lane0_valid_at_stg0_found_edge <= 'b0;
     else if ( first_found_edge0 && phase_valid[0] && ~phase_valid_r[0]  && wrcal_byte_sel == lane_with_K )
        if (~phase_valid[lane_with_K])
          byte_lane0_valid_at_stg0_found_edge <= 1'b1;
        else
          byte_lane0_valid_at_stg0_found_edge <= 1'b0;
  end  

  always @ (posedge clk)
  begin
     if (rst_wr_clk)
       byte_lane1_valid_at_stg0_found_edge <= 'b0;
     else if ( first_found_edge1 && phase_valid[1] && ~phase_valid_r[1]  && wrcal_byte_sel == lane_with_K )
        if (~phase_valid[lane_with_K])
          byte_lane1_valid_at_stg0_found_edge <= 1'b1;
        else
          byte_lane1_valid_at_stg0_found_edge <= 1'b0;
  end  

  generate 
  if (N_DATA_LANES > 2) begin: fnd_edge2_3

    always @ (posedge clk)
    begin
       if (rst_wr_clk)
         byte_lane2_valid_at_stg0_found_edge <= 'b0;
       else if ( first_found_edge2 && phase_valid[2] && ~phase_valid_r[2]  && wrcal_byte_sel == lane_with_K )
          if (~phase_valid[lane_with_K])
            byte_lane2_valid_at_stg0_found_edge <= 1'b1;
          else
            byte_lane2_valid_at_stg0_found_edge <= 1'b0;
    end  

    always @ (posedge clk)
    begin
       if (rst_wr_clk)
         byte_lane3_valid_at_stg0_found_edge <= 'b0;
       else if ( first_found_edge3 && phase_valid[3] && ~phase_valid_r[3]  && wrcal_byte_sel == lane_with_K )
          if (~phase_valid[lane_with_K])
            byte_lane3_valid_at_stg0_found_edge <= 1'b1;
          else
            byte_lane3_valid_at_stg0_found_edge <= 1'b0;
    end  
  end
  endgenerate

// set up deskew conditions for bytes without K clock
  always @ (posedge clk)
  begin
  if (rst_wr_clk || phy_init_cs == NEXT_BYTE_DESKEW)
     push_until_fail <= 1'b0;     
  else begin
     case(wrcal_byte_sel) 
       0 : push_until_fail <= byte_lane0_valid_at_stg0_found_edge;
       1 : push_until_fail <= byte_lane1_valid_at_stg0_found_edge;
       2 : push_until_fail <= byte_lane2_valid_at_stg0_found_edge;
       3 : push_until_fail <= byte_lane3_valid_at_stg0_found_edge;
       
       default:push_until_fail <= 1'b0;  
     endcase
    end
  end  

  always @ (posedge clk)
  begin
     if (rst_wr_clk)
           bytes_deskewed <= 'b0;
     else if (phy_init_cs == NEXT_BYTE_DESKEW   )
           bytes_deskewed <= bytes_deskewed + 1;
     else
           bytes_deskewed <= bytes_deskewed;
  end

  always @ (posedge clk)
  begin
     if (rst_wr_clk)
           current_byte_deskewed <= 1'b0;
     else if (phy_init_cs == NEXT_BYTE_DESKEW )
           current_byte_deskewed <= 1'b0;
     else if (phy_init_cs == OCLK_RECAL && ~push_until_fail && phase_valid[wrcal_byte_sel] && wrcal_byte_sel !=  lane_with_K)        
           current_byte_deskewed <= 1'b1;
           
     else if (phy_init_cs == PO_ADJ && push_until_fail && ~phase_valid[wrcal_byte_sel] && wrcal_byte_sel !=  lane_with_K)        
           current_byte_deskewed <= 1'b1;
     else
           current_byte_deskewed <= current_byte_deskewed;
     
  end
  
  
  
  always @ (posedge clk)
  begin
  if (rst_wr_clk)
     first_deskew_attempt <= 1'b1;
  else if (phy_init_cs == NEXT_BYTE_DESKEW )
     first_deskew_attempt <= 1'b1;
     
  else if (deskew_counts > 0)
     first_deskew_attempt <= 1'b0;
  else
     first_deskew_attempt <= first_deskew_attempt;
  end
  
  
  always @ (posedge clk)
  begin
  if (rst_wr_clk)

     deskew_counts <= 'b0;
  else if (phy_init_cs == NEXT_BYTE_DESKEW )
     deskew_counts <= 0;
     
  else if (phy_init_cs == OCLK_RECAL)
     deskew_counts <= deskew_counts + 1;
  else
     deskew_counts <= deskew_counts ;
  
  end


  //counter to keep track of what byte lane we are calibrating
  //Also used to adjust calib_sel
  //This counter is reset also at the start of a new mode
  
  
  always @ (posedge clk)
  begin
     if (rst_wr_clk)
        inc_byte_lane_cnt <= 1'b0;
//     else if (phy_init_cs == PO_STG3_DEC_TO_FIRST_EDGE && oclk_window_found && wrcal_byte_sel == lane_with_K && wrlvl_po_f_counter_en_r && ~wrlvl_po_f_counter_en)
//        inc_byte_lane_cnt <= 1'b1;
     else if (phy_init_cs == NEXT_BYTE_DESKEW  && ~oclk_final_adjusted)
        inc_byte_lane_cnt <= 1'b1;
     
     else
        inc_byte_lane_cnt <= 1'b0;
  end  
  
  
  always @ (posedge clk)
  begin
    if (rst_wr_clk )
        if (BYTE_LANE_WITH_DK[0])
          byte_lane_cnt <= #TCQ 'b0;
        else if (BYTE_LANE_WITH_DK[1])
          byte_lane_cnt <= #TCQ 1;
        else if (BYTE_LANE_WITH_DK[2] && N_DATA_LANES > 2)
          byte_lane_cnt <= #TCQ 2;
        else if (BYTE_LANE_WITH_DK[3] && N_DATA_LANES > 2)
          byte_lane_cnt <= #TCQ 3;
        else
          byte_lane_cnt <= #TCQ 0;
    else if (phy_init_cs == NEXT_BYTE_DESKEW && k_clk_adjusted_counts == 1)
        // get the  K byte lane value for the second K clock adjustment
        if (BYTE_LANE_WITH_DK[2] && N_DATA_LANES > 2)
          byte_lane_cnt <= #TCQ 2;
        else if (BYTE_LANE_WITH_DK[3] && N_DATA_LANES > 2)
          byte_lane_cnt <= #TCQ 3;
        else
          byte_lane_cnt <= #TCQ 0;
        
    else if (phy_init_cs == FINAL_OCLK_ADJ)
           byte_lane_cnt <= #TCQ lane_with_K;
   
    else if (inc_byte_lane_cnt)
       if (byte_lane_cnt == N_DATA_LANES - 1)
            byte_lane_cnt <= #TCQ 0;
       else
       byte_lane_cnt <= #TCQ byte_lane_cnt + 1;
    else
       byte_lane_cnt <= #TCQ byte_lane_cnt;
  end
  assign wrcal_byte_sel = byte_lane_cnt[1:0];

  // translate the  K vector to scalar value.
  assign lane_with_K = BYTE_LANE_WITH_DK[0] && CK_WIDTH == 1 ? 0 :
                       BYTE_LANE_WITH_DK[1] && CK_WIDTH == 1 ? 1 :
                       (BYTE_LANE_WITH_DK[2] && N_DATA_LANES > 2 && CK_WIDTH == 1) ? 2 :
                       (BYTE_LANE_WITH_DK[3] && N_DATA_LANES > 2 && CK_WIDTH == 1) ? 3 : 

                       (BYTE_LANE_WITH_DK[0] && CK_WIDTH == 2 && bytes_deskewed  < 1) ? 0 :
                       (BYTE_LANE_WITH_DK[1] && CK_WIDTH == 2 && bytes_deskewed  < 1) ? 1 :
                       (BYTE_LANE_WITH_DK[2] && N_DATA_LANES > 2 && CK_WIDTH == 2 && bytes_deskewed  > 1 ) ? 2 :
                       (BYTE_LANE_WITH_DK[3] && N_DATA_LANES > 2 && CK_WIDTH == 2 && bytes_deskewed  >  1) ? 3 :                        
                        0;

  // -------------------------------------------------------------------------
  // Keep track of what mode we are in
  // For now just support the first mode (CK-to-DK)
  // -------------------------------------------------------------------------
  always @ (posedge clk)
  begin
    if (rst_wr_clk) begin
          wrcal_stg <= #TCQ 'b0;
        end else if (CK_WIDTH == 2 && phy_init_cs == CAL_INIT && bytes_deskewed == 2)
          wrcal_stg <= #TCQ 'b0;
        
        else if (phy_init_cs == CAL_INIT && oclk_window_found) begin
          if (wrcal_stg < 1)
             wrcal_stg <= #TCQ wrcal_stg + 1;
          else
             wrcal_stg <= #TCQ wrcal_stg;
          
        end else begin
          wrcal_stg <= #TCQ wrcal_stg;
        end
  end
    
    //***************************************************************************
  // PRBS Generator for Read Leveling Stage 1 - read window detection and 
  // DQS Centering
  //***************************************************************************
  
  mig_7series_v1_9_qdr_rld_prbs_gen #
    (
     .PRBS_WIDTH  (DATA_WIDTH)
    )
    u_qdr_rld_prbs_gen
      (
       .clk              (clk),
       .clk_en           (1'b0),
       .rst              (rst_clk),
       .prbs_o           (prbs_o)
      );
    


// following is for simulation purpose
// not syntehsizable
    reg [8*50:0] phy_init_sm;
    always @(phy_init_cs)begin
       casex(phy_init_cs)
        15'b000000000000001  : begin phy_init_sm = "CAL_INIT"     ; end
        15'b000000000000010  : begin phy_init_sm = "CAL1_WRITE"    ; end
        15'b000000000000100  : begin phy_init_sm = "CAL1_READ"    ; end     
        15'b000000000001000  : begin phy_init_sm = "CAL2_WRITE"; end    
        15'b000000000010000  : begin phy_init_sm = "CAL2_READ_CONT" ; end    
        15'b000000000100000  : begin phy_init_sm = "CAL2_READ"      ; end
        15'b000000001000000  : begin phy_init_sm = "OCLK_RECAL"     ; end
        15'b000000010000000  : begin phy_init_sm = "PO_ADJ"         ; end
        15'b000000100000000  : begin phy_init_sm = "CAL2_READ_WAIT" ; end
        15'b000001000000000  : begin phy_init_sm = "CAL_DONE "  ; end
        15'b000010000000000  : begin phy_init_sm = "CAL_DONE_WAIT"  ; end 
        15'b000100000000000  : begin phy_init_sm = "PO_ADJ_WAIT"    ; end  //
        15'b001000000000000  : begin phy_init_sm = "PO_STG3_DEC_TO_FIRST_EDGE"    ; end  //NEXT_BYTE_DESKEW
        15'b010000000000000  : begin phy_init_sm = "NEXT_BYTE_DESKEW"    ; end  //NEXT_BYTE_DESKEW
        15'b100000000000000  : begin phy_init_sm = "FINAL_OCLK_ADJ"    ; end   
       endcase
    end
          

endmodule

