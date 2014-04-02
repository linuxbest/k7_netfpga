//*****************************************************************************
// (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
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
//  /   /         Filename           : sim_tb_top.v
// /___/   /\     Date Last Modified : $Date: 2011/06/02 07:18:19 $
// \   \  /  \    Date Created       : Thu Apr 02 2009
//  \___\/\___\
//
// Device           : Virtex-6
// Design Name      : QDRII+ SRAM
// Purpose          :
//                   Top-level testbench for testing QDRII+.
//                   Instantiates:
//                     1. IP_TOP (top-level representing FPGA, contains core,
//                        clocking, built-in testbench/memory checker and other
//                        support structures)
//                     2. QDRII+ Memory Instantiations (Samsung only)
//                     3. Miscellaneous clock generation and reset logic
// Reference        :
// Revision History :
//******************************************************************************

`timescale  1 ps / 100 fs

module sim_tb_top();

  //============================================================================
  //                        Design Specific Parameters
  //============================================================================
  localparam DATA_WIDTH            = 36;           //# of data bits
  localparam ADDR_WIDTH            = 19;           //# of memory addr bits
  localparam BURST_LEN             = 4;            //Burst Length type
  localparam BW_WIDTH              = DATA_WIDTH/9; //# of Byte Write bits
  localparam REFCLK_FREQ           = 200;          //Iodelay clock freq (MHz)
  localparam IODELAY_GRP           = "IODELAY_MIG";
  localparam NUM_DEVICES           = 1;            //# of clock outputs
  localparam FIXED_LATENCY_MODE    = 0;            //Fixed latency disabled
  localparam PHY_LATENCY           = 0;            //Fixed Latency of 10
  localparam CLK_STABLE            = 2048;         //Cycles until CQ is stable
  localparam SIM_CAL_OPTION        = "FAST_CAL";   //Skip various calib steps
  localparam PHASE_DETECT          = "ON";        //Disable Phase detector
  localparam DEBUG_PORT            = "OFF";        //Disable debug port
  localparam IBUF_LPWR_MODE        = "OFF";        //Input buffer low power mode
  localparam IODELAY_HP_MODE       = "ON";         //IODELAY High Performance Mode
  localparam HIGH_PERFORMANCE_MODE = "TRUE";       //Performance mode for IODELAYs
  localparam MEMORY_WIDTH          = (DATA_WIDTH/NUM_DEVICES); //# of memory
                                                               //component's
                                                               //data width
  localparam DLL_FREQ_MODE         = "HIGH";        //DCM's DLL Frequency mode
  localparam RST_ACT_LOW           = 1;             //Reset Active Low
  localparam INPUT_CLK_TYPE        = "SINGLE_ENDED";//Differential or Single Ended
                                                    //system clocks
  localparam CLKFBOUT_MULT_F       = 8;             // write PLL VCO multiplier
  localparam CLKOUT_DIVIDE         = 4;             // VCO output divisor for fast (memory) clocks
  localparam DIVCLK_DIVIDE         = 2;             // write PLL VCO divisor
  localparam TCQ                   = 100;            //Simulation Register Delay
  localparam SIM_INIT_OPTION       = "NONE";    //Simulation only. "NONE", "SIM_MODE"

  localparam BW_COMP = MEMORY_WIDTH/9;

  localparam SYSCLK_PERIOD      = 2500; //System Clock period (ps) for clock generation
  localparam CLK_PERIOD         = SYSCLK_PERIOD*2; //Internal Clock period (ps) - 200 MHz memory
  localparam REFCLK_PERIOD      = 1000000.0/REFCLK_FREQ;//Idelay Reference clock period (ps)

  localparam TPROP_PCB_CTRL     = 0.00;             //Board delay value
  localparam TPROP_PCB_CQ       = (SIM_CAL_OPTION == "SKIP_CAL") ?
                                  CLK_PERIOD / 4 : 0.00; //CQ delay to center of Q
  localparam TPROP_PCB_DATA     = 0.00;             //DQ delay value
  localparam TPROP_PCB_DATA_RD  = 0.00;             //READ DQ delay value
  localparam RESET_PERIOD       = 200000;           //in pSec

  //===========================================================================
  //                        Test Bench Signal declaration
  //===========================================================================

   reg                      sys_clk;
   reg                      sys_rst_n;
   reg                      clkref;
   //Simulation Wave Signals With Board Delay Parameters
   reg                      qdriip_w_n_delay;
   reg                      qdriip_r_n_delay;
   reg [NUM_DEVICES-1:0]    qdriip_k_p_delay;
   reg [NUM_DEVICES-1:0]    qdriip_k_n_delay;
   reg [ADDR_WIDTH-1:0]     qdriip_sa_delay;
   reg [BW_WIDTH-1:0]       qdriip_bw_n_delay;
   reg [DATA_WIDTH-1:0]     qdriip_d_delay;
   reg [DATA_WIDTH-1:0]     qdriip_q_delay;
   reg [NUM_DEVICES-1:0]    qdriip_cq_p_delay;
   reg [NUM_DEVICES-1:0]    qdriip_cq_n_delay;
   reg                      qdriip_dll_off_n_delay;

   //System Signals

   wire                     sys_rst;
   wire                     qdriip_w_n;
   wire                     qdriip_r_n;
   wire                     qdriip_dll_off_n;
   //Memory Interface
   wire [NUM_DEVICES-1:0]   qdriip_k_p;
   wire [NUM_DEVICES-1:0]   qdriip_k_n;
   wire [ADDR_WIDTH-1:0]    qdriip_sa;
   wire [BW_WIDTH-1:0]      qdriip_bw_n;
   wire [DATA_WIDTH-1:0]    qdriip_d;
   wire [DATA_WIDTH-1:0]    qdriip_q;
   wire [NUM_DEVICES-1:0]   qdriip_cq_p;
   wire [NUM_DEVICES-1:0]   qdriip_cq_n;
   wire                     compare_error;
   wire                     cal_done;



  //============================================================================
  //                        CLOCKS and RESET Generation
  //============================================================================

   initial begin
     sys_clk    = 0;
     sys_rst_n  = 0;
     clkref     = 0;
   end

   // Generate 200MHz reference clock
   always #(REFCLK_PERIOD/2) clkref = ~clkref;

   // Generate design clock
   always #(SYSCLK_PERIOD/2) sys_clk = ~sys_clk;



   // Generate Reset. The active low reset is generated.
   initial begin
     #(RESET_PERIOD) sys_rst_n = 1;
   end

   assign sys_rst = RST_ACT_LOW? sys_rst_n : ~sys_rst_n;

  //===========================================================================
  //                            BOARD Parameters
  //===========================================================================
  //These parameter values can be changed to model varying board delays
  //between the Virtex-6 device and the QDR II memory model
  // always @(qdriip_k_p or qdriip_k_n or qdriip_sa or qdriip_bw_n or qdriip_w_n or
  //          qdriip_d or qdriip_r_n or qdriip_q or qdriip_cq_p or
  //          qdriip_cq_n or qdriip_dll_off_n)
   always @*
   begin
     qdriip_k_p_delay       <= #TPROP_PCB_CTRL    qdriip_k_p;
     qdriip_k_n_delay       <= #TPROP_PCB_CTRL    qdriip_k_n;
     qdriip_sa_delay        <= #TPROP_PCB_CTRL    qdriip_sa;
     qdriip_bw_n_delay      <= #TPROP_PCB_CTRL    qdriip_bw_n;
     qdriip_w_n_delay       <= #TPROP_PCB_CTRL    qdriip_w_n;
     qdriip_d_delay         <= #TPROP_PCB_DATA    qdriip_d;
     qdriip_r_n_delay       <= #TPROP_PCB_CTRL    qdriip_r_n;
     qdriip_q_delay         <= #TPROP_PCB_DATA_RD qdriip_q;
     qdriip_cq_p_delay      <= #TPROP_PCB_CQ      qdriip_cq_p;
     qdriip_cq_n_delay      <= #TPROP_PCB_CQ      qdriip_cq_n;
     qdriip_dll_off_n_delay <= #TPROP_PCB_CTRL    qdriip_dll_off_n;
   end

  //===========================================================================
  //                         FPGA Memory Controller
  //===========================================================================

  example_top #(
    .ADDR_WIDTH         (ADDR_WIDTH),
    .DATA_WIDTH         (DATA_WIDTH),
    .BURST_LEN          (BURST_LEN),
    .BW_WIDTH           (BW_WIDTH),
    .CLK_PERIOD         (CLK_PERIOD),
    .REFCLK_FREQ        (REFCLK_FREQ),
    .IODELAY_GRP        (IODELAY_GRP),
    .NUM_DEVICES        (NUM_DEVICES),
    .FIXED_LATENCY_MODE (FIXED_LATENCY_MODE),
    .PHY_LATENCY        (PHY_LATENCY),
    .CLK_STABLE         (CLK_STABLE),
    .RST_ACT_LOW        (RST_ACT_LOW),
    .PHASE_DETECT       (PHASE_DETECT),
    .DEBUG_PORT         (DEBUG_PORT),
    .SIM_CAL_OPTION     (SIM_CAL_OPTION),
    .SIM_INIT_OPTION    (SIM_INIT_OPTION),
    .IBUF_LPWR_MODE     (IBUF_LPWR_MODE),
    .IODELAY_HP_MODE    (IODELAY_HP_MODE),
    .INPUT_CLK_TYPE     (INPUT_CLK_TYPE),
    .CLKFBOUT_MULT_F    (CLKFBOUT_MULT_F),
    .CLKOUT_DIVIDE      (CLKOUT_DIVIDE),
    .DIVCLK_DIVIDE      (DIVCLK_DIVIDE),
    .TCQ                (TCQ)
  ) u_ip_top (
    .sys_rst            (sys_rst),
    .sys_clk            (sys_clk),
    .clk_ref            (clkref),
    .qdriip_dll_off_n   (qdriip_dll_off_n),
    .qdriip_cq_p        (qdriip_cq_p_delay),
    .qdriip_cq_n        (qdriip_cq_n_delay),
    .qdriip_q           (qdriip_q_delay),
    .qdriip_k_p         (qdriip_k_p),
    .qdriip_k_n         (qdriip_k_n),
    .qdriip_d           (qdriip_d),
    .qdriip_sa          (qdriip_sa),
    .qdriip_w_n         (qdriip_w_n),
    .qdriip_r_n         (qdriip_r_n),
    .qdriip_bw_n        (qdriip_bw_n),

    .compare_error      (compare_error),
    .cal_done           (cal_done)
    );



  //=============================================================================
  //                             Memory Model
  //=============================================================================
  //Instantiate the QDRII+ Memory Modules - Cypress Verilog model              
  // MIG does not output Cypress memory models. You have to instantiate the
  // appropriate Cypress memory model for the cypress controller designs
  // generated from MIG. Memory model instance name must be modified as per 
  // the model downloaded from the memory vendor website
  genvar i;                                                                    
  generate                                                                     
    for(i=0; i<NUM_DEVICES; i=i+1)begin : COMP_INST                         
      if (BURST_LEN == 4) begin : QDR2PLUS_BL4_INST                            
        // Cypress QDRII+ SRAM Burst Length Four memory model instantiation for
        // X36 controller design                                               
        if (MEMORY_WIDTH == 36) begin : COMP_36                                
          /* BURST LENGTH 4 */                                                 
          cyqdr2_b4 QDR2PLUS_MEM
            (
             .TCK   ( 1'b0 ),
             .TMS   ( 1'b1 ),
             .TDI   ( 1'b1 ),
             .TDO   (),
             .D     ( qdriip_d_delay[(MEMORY_WIDTH*i)+:MEMORY_WIDTH] ),
             .Q     ( qdriip_q [(MEMORY_WIDTH*i)+:MEMORY_WIDTH] ),
             .A     ( qdriip_sa_delay ),
             .K     ( qdriip_k_p_delay[i] ),
             .Kb    ( qdriip_k_n_delay[i] ),
             .RPSb  ( qdriip_r_n_delay ),
             .WPSb  ( qdriip_w_n_delay ),
             .BWS0b ( qdriip_bw_n_delay[(i*BW_COMP)] ),
             .BWS1b ( qdriip_bw_n_delay[(i*BW_COMP)+1] ),
             .BWS2b ( qdriip_bw_n_delay[(i*BW_COMP)+2] ),
             .BWS3b ( qdriip_bw_n_delay[(i*BW_COMP)+3] ),
             .CQ    ( qdriip_cq_p[i] ),
             .CQb   ( qdriip_cq_n[i] ),
             .ZQ    ( 1'b1 ),
             .DOFF  ( qdriip_dll_off_n_delay ),
             .QVLD  ()
             );
        end //end - QDR2 - BL4 - x36                                           
        // Cypress QDRII+ SRAM Burst Length Four memory model instantiation for
        // X18 controller design                                               
        else begin : COMP_18                                                 
          /* BURST LENGTH 4 */                                                 
          cyqdr2_b4_18 QDR2PLUS_MEM
            (
             .TCK   ( 1'b0 ),
             .TMS   ( 1'b1 ),
             .TDI   ( 1'b1 ),
             .TDO   (),
             .D     ( qdriip_d_delay[(MEMORY_WIDTH*i)+:MEMORY_WIDTH] ),
             .Q     ( qdriip_q [(MEMORY_WIDTH*i)+:MEMORY_WIDTH] ),
             .A     ( qdriip_sa_delay ),
             .K     ( qdriip_k_p_delay[i] ),
             .Kb    ( qdriip_k_n_delay[i] ),
             .RPSb  ( qdriip_r_n_delay ),
             .WPSb  ( qdriip_w_n_delay ),
             .BWS0b ( qdriip_bw_n_delay[(i*BW_COMP)] ),
             .BWS1b ( qdriip_bw_n_delay[(i*BW_COMP)+1] ),
             .CQ    ( qdriip_cq_p[i] ),
             .CQb   ( qdriip_cq_n[i] ),
             .ZQ    ( 1'b1 ),
             .DOFF  ( qdriip_dll_off_n_delay ),
             .QVLD  ()
             );
        end //end - QDR2 - BL4 - x18                                           
      end //end - QDR2PLUS_BL4_INST                                            
    end //end - COMP_INST                                                      
  endgenerate

  //***************************************************************************
  // Reporting the test case status
  //***************************************************************************
/*
  initial
  begin : Logging
     fork
        begin : calibration_done
           wait (cal_done);
           $display("Calibration Done");
           #50000000;
           if (!compare_error) begin
              $display("TEST PASSED");
           end
           else begin
              $display("TEST FAILED: DATA ERROR");
           end
           disable calib_not_done;
            $finish;
        end

        begin : calib_not_done
           #550000000;
           if (!cal_done) begin
              $display("TEST FAILED: INITIALIZATION DID NOT COMPLETE");
           end
           disable calibration_done;
            $finish;
        end
     join
  end
*/
  
endmodule
