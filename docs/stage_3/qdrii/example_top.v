//*****************************************************************************
// (c) Copyright 2009 - 2013 Xilinx, Inc. All rights reserved.
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
// \   \   \/     Version            : 1.9
//  \   \         Application        : MIG
//  /   /         Filename           : example_top.v
// /___/   /\     Date Last Modified : $Date: 2011/06/02 08:36:27 $
// \   \  /  \    Date Created       : Fri Jan 14 2011
//  \___\/\___\
//
// Device           : 7 Series
// Design Name      : QDRII+ SDRAM
// Purpose          :
//   Top-level  module. This module serves both as an example,
//   and allows the user to synthesize a self-contained design,
//   which they can be used to test their hardware.
//   In addition to the memory controller, the module instantiates:
//     1. Synthesizable testbench - used to model user's backend logic
//        and generate different traffic patterns
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps/1ps

module example_top #
  (

   parameter MEM_TYPE              = "QDR2PLUS",
                                     // # of CK/CK# outputs to memory.
   parameter DATA_WIDTH            = 36,
                                     // # of DQ (data)
   parameter BW_WIDTH              = 4,
                                     // # of byte writes (data_width/9)
   parameter ADDR_WIDTH            = 18,
                                     // Address Width
   parameter NUM_DEVICES           = 1,
                                     // # of memory components connected
   parameter MEM_RD_LATENCY        = 2.5,
                                     // Value of Memory part read latency
   parameter CPT_CLK_CQ_ONLY       = "TRUE",
                                     // whether CQ and its inverse are used for the data capture
   parameter INTER_BANK_SKEW       = 0,
                                     // Clock skew between two adjacent banks
   parameter PHY_CONTROL_MASTER_BANK = 2,
                                     // The bank index where master PHY_CONTROL resides,
                                     // equal to the PLL residing bank

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   parameter BURST_LEN             = 4,
                                     // Burst Length of the design (4 or 2).
   parameter FIXED_LATENCY_MODE    = 0,
                                     // Enable Fixed Latency
   parameter PHY_LATENCY           = 0,
                                     // Value for Fixed Latency Mode
                                     // Expected Latency
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for MMCM.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   parameter CLKIN_PERIOD          = 10000,
                                     // Input Clock Period
   parameter CLKFBOUT_MULT         = 10,
                                     // write PLL VCO multiplier
   parameter DIVCLK_DIVIDE         = 1,
                                     // write PLL VCO divisor
   parameter CLKOUT0_DIVIDE        = 2,
                                     // VCO output divisor for PLL output clock (CLKOUT0)
   parameter CLKOUT1_DIVIDE        = 2,
                                     // VCO output divisor for PLL output clock (CLKOUT1)
   parameter CLKOUT2_DIVIDE        = 32,
                                     // VCO output divisor for PLL output clock (CLKOUT2)
   parameter CLKOUT3_DIVIDE        = 4,
                                     // VCO output divisor for PLL output clock (CLKOUT3)

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   parameter SIM_BYPASS_INIT_CAL   = "OFF",
                                     // # = "OFF" -  Complete memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Skip memory init &
                                     //              calibration sequence
                                     // # = "FAST" - Skip memory init & use
                                     //              abbreviated calib sequence
   parameter SIMULATION            = "FALSE",
                                     // Should be TRUE during design simulations and
                                     // FALSE during implementations

   //***************************************************************************
   // The following parameters varies based on the pin out entered in MIG GUI.
   // Do not change any of these parameters directly by editing the RTL.
   // Any changes required should be done through GUI and the design regenerated.
   //***************************************************************************
   parameter BYTE_LANES_B0         = 4'b1111,
                                     // Byte lanes used in an IO column.
   parameter BYTE_LANES_B1         = 4'b1011,
                                     // Byte lanes used in an IO column.
   parameter BYTE_LANES_B2         = 4'b1111,
                                     // Byte lanes used in an IO column.
   parameter BYTE_LANES_B3         = 4'b0000,
                                     // Byte lanes used in an IO column.
   parameter BYTE_LANES_B4         = 4'b0000,
                                     // Byte lanes used in an IO column.
   parameter DATA_CTL_B0           = 4'b1111,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter DATA_CTL_B1           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter DATA_CTL_B2           = 4'b1111,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter DATA_CTL_B3           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter DATA_CTL_B4           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane

   // this parameter specifies the location of the capture clock with respect
   // to read data.
   // Each byte refers to the information needed for data capture in the corresponding byte lane
   // Lower order nibble - is either 4'h1 or 4'h2. This refers to the capture clock in T1 or T2 byte lane
   // Higher order nibble - 4'h0 refers to clock present in the bank below the read data,
   //                       4'h1 refers to clock present in the same bank as the read data,
   //                       4'h2 refers to clock present in the bank above the read data.
   parameter CPT_CLK_SEL_B0  = 32'h11_11_11_11,
   parameter CPT_CLK_SEL_B1  = 32'h00_00_00_00,
   parameter CPT_CLK_SEL_B2  = 32'h00_00_00_00,

   parameter PHY_0_BITLANES       = 48'hFF8_FF5_C3F_EFC,
                                     // The bits used inside the Bank0 out of 48 pins.
   parameter PHY_1_BITLANES       = 48'h500_000_3BC_EFF,
                                     // The bits used inside the Bank1 out of 48 pins.
   parameter PHY_2_BITLANES       = 48'hFFE_CFE_3FF_EFE,
                                     // The bits used inside the Bank2 out of 48 pins.
   parameter PHY_3_BITLANES       = 48'h000_000_000_000,
                                     // The bits used inside the Bank3 out of 48 pins.
   parameter PHY_4_BITLANES       = 48'h000_000_000_000,
                                     // The bits used inside the Bank4 out of 48 pins.

   // Differentiates the INPUT and OUTPUT bytelates (1-input, 0-output)
   parameter BYTE_GROUP_TYPE_B0 = 4'b1111,
   parameter BYTE_GROUP_TYPE_B1 = 4'b0000,
   parameter BYTE_GROUP_TYPE_B2 = 4'b0000,
   parameter BYTE_GROUP_TYPE_B3 = 4'b0000,
   parameter BYTE_GROUP_TYPE_B4 = 4'b0000,

   // mapping for K/K# clocks. This parameter needs to have an 8-bit value per component
   // since the phy drives a K/K# clock pair to each memory it interfaces to. A 3 component
   // interface is supported for now. This parameter needs to be used in conjunction with
   // NUM_DEVICES parameter which provides information on the number. of components being
   // interfaced to.
   // the 8 bit for each component is defined as follows:
   // [7:4] - bank number ; [3:0] - byte lane number
   parameter K_MAP = 48'h00_00_00_00_00_22,

   // mapping for CQ/CQ# clocks. This parameter needs to have an 4-bit value per component
   // since the phy drives a CQ/CQ# clock pair to each memory it interfaces to. A 3 component
   // interface is supported for now. This parameter needs to be used in conjunction with
   // NUM_DEVICES parameter which provides information on the number. of components being
   // interfaced to.
   // the 4 bit for each component is defined as follows:
   // [3:0] - bank number
   parameter CQ_MAP = 48'h00_00_00_00_00_01,

   //**********************************************************************************************
   // Each of the following parameter contains the byte_lane and bit position information for
   // the address/control, data write and data read signals. Each bit has 12 bits and the details are
   // [3:0] - Bit position within a byte lane .
   // [7:4] - Byte lane position within a bank. [5:4] have the byte lane position and others reserved.
   // [11:8] - Bank position. [10:8] have the bank position. [11] tied to zero .
   //**********************************************************************************************

   // Mapping for address and control signals.

   parameter RD_MAP = 12'h103,      // Mapping for read enable signal
   parameter WR_MAP = 12'h138,      // Mapping for write enable signal

   // Mapping for address signals. Supports upto 22 bits of address bits (22*12)
   parameter ADD_MAP = 264'h000_000_000_000_101_109_100_106_112_119_10A_10B_113_107_102_105_104_114_115_117_13A_118,

   // Mapping for the byte lanes used for address/control signals. Supports a maximum of 3 banks.
   parameter ADDR_CTL_MAP = 24'h13_11_10,

   // Mapping for data WRITE signals

   // Mapping for data write bytes (9*12)
   parameter D0_MAP  = 108'h223_22B_222_22A_224_221_225_227_226, //byte 0
   parameter D1_MAP  = 108'h23A_236_238_235_234_237_233_231_239, //byte 1
   parameter D2_MAP  = 108'h219_218_216_214_217_212_211_213_215, //byte 2
   parameter D3_MAP  = 108'h20B_203_202_207_20A_201_206_205_204, //byte 3
   parameter D4_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 4
   parameter D5_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 5
   parameter D6_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 6
   parameter D7_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 7

   // Mapping for byte write signals (8*12)
   parameter BW_MAP = 84'h000_000_000_210_209_232_23B,

   // Mapping for data READ signals

   // Mapping for data read bytes (9*12)
   parameter Q0_MAP  = 108'h03B_03A_035_037_039_033_036_038_034, //byte 0
   parameter Q1_MAP  = 108'h026_020_025_02B_022_029_02A_024_028, //byte 1
   parameter Q2_MAP  = 108'h01A_01B_010_013_011_014_015_012_027, //byte 2
   parameter Q3_MAP  = 108'h009_00B_007_006_005_004_00A_003_002, //byte 3
   parameter Q4_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 4
   parameter Q5_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 5
   parameter Q6_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 6
   parameter Q7_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 7

   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   parameter IODELAY_HP_MODE       = "ON",
                                     // to phy_top
   parameter IBUF_LPWR_MODE        = "OFF",
                                     // to phy_top
   parameter TCQ                   = 100,
   parameter IODELAY_GRP           = "IODELAY_MIG",
                                     // It is associated to a set of IODELAYs with
                                     // an IDELAYCTRL that have same IODELAY CONTROLLER
                                     // clock frequency.
   parameter SYSCLK_TYPE           = "SINGLE_ENDED",
                                     // System clock type DIFFERENTIAL, SINGLE_ENDED,
                                     // NO_BUFFER
   parameter REFCLK_TYPE           = "SINGLE_ENDED",
                                     // Reference clock type DIFFERENTIAL, SINGLE_ENDED,
                                     // NO_BUFFER, USE_SYSTEM_CLOCK
   parameter SYS_RST_PORT          = "FALSE",
                                     // "TRUE" - if pin is selected for sys_rst
                                     //          and IBUF will be instantiated.
                                     // "FALSE" - if pin is not selected for sys_rst
      
   // Number of taps in target IDELAY
   parameter integer DEVICE_TAPS = 32,

   
   //***************************************************************************
   // Referece clock frequency parameters
   //***************************************************************************
   parameter REFCLK_FREQ           = 200.0,
                                     // IODELAYCTRL reference clock frequency
   parameter DIFF_TERM_REFCLK      = "TRUE",
                                     // Differential Termination for idelay
                                     // reference clock input pins
      
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter CLK_PERIOD            = 2000,
                                     // memory tCK paramter.
                                     // # = Clock Period in pS.
   parameter nCK_PER_CLK           = 2,
                                     // # of memory CKs per fabric CLK
   parameter DIFF_TERM_SYSCLK      = "TRUE",
                                     // Differential Termination for System
                                     // clock input pins

      //***************************************************************************
   // Traffic Gen related parameters
   //***************************************************************************
   parameter BL_WIDTH              = 8,
   parameter PORT_MODE             = "BI_MODE",
   parameter DATA_MODE             = 4'b0010,
   parameter EYE_TEST              = "FALSE",
                                     // set EYE_TEST = "TRUE" to probe memory
                                     // signals. Traffic Generator will only
                                     // write to one single location and no
                                     // read transactions will be generated.
   parameter DATA_PATTERN          = "DGEN_ALL",
                                      // "DGEN_HAMMER", "DGEN_WALKING1",
                                      // "DGEN_WALKING0","DGEN_ADDR","
                                      // "DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"
   parameter CMD_PATTERN           = "CGEN_ALL",
                                      // "CGEN_PRBS","CGEN_FIXED","CGEN_BRAM",
                                      // "CGEN_SEQUENTIAL", "CGEN_ALL"
   parameter CMD_WDT               = 'h3FF,
   parameter WR_WDT                = 'h1FFF,
   parameter RD_WDT                = 'h3FF,
   parameter BEGIN_ADDRESS         = 32'h00000000,
   parameter END_ADDRESS           = 32'h00000fff,
   parameter PRBS_EADDR_MASK_POS   = 32'hfffff000,

   //***************************************************************************
   // Wait period for the read strobe (CQ) to become stable
   //***************************************************************************
   parameter CLK_STABLE            = (20*1000*1000/(CLK_PERIOD*2)),
                                     // Cycles till CQ/CQ# is stable

   //***************************************************************************
   // Debug parameter
   //***************************************************************************
   parameter DEBUG_PORT            = "ON",
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
      
   parameter RST_ACT_LOW           = 1
                                     // =1 for active low reset,
                                     // =0 for active high.
   )
  (
// Single-ended system clock
   input                                        sys_clk_i,// Single-ended iodelayctrl clk (reference clock)
   input                                        clk_ref_i,
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
   output wire                       qdriip_dll_off_n,
   output                                       tg_compare_error,
   
   output                                       init_calib_complete,
      

   // System reset - Default polarity of sys_rst pin is Active Low.
   // System reset polarity will change based on the option 
   // selected in GUI.
   input                                        sys_rst
   );

  // clogb2 function - ceiling of log base 2
  function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction

   localparam APP_DATA_WIDTH        = BURST_LEN*DATA_WIDTH;
   localparam APP_MASK_WIDTH        = APP_DATA_WIDTH / 9;
   // Number of bits needed to represent DEVICE_TAPS
   localparam integer TAP_BITS = clogb2(DEVICE_TAPS - 1);
   // Number of bits to represent number of cq/cq#'s
   localparam integer CQ_BITS  = clogb2(DATA_WIDTH/9 - 1);
   // Number of bits needed to represent number of q's
   localparam integer Q_BITS   = clogb2(DATA_WIDTH - 1);

  // Wire declarations
   wire                            clk;
   wire                            rst_clk;
   wire                            cmp_err;
   wire                            dbg_clear_error;
   wire                            app_wr_cmd0;
   wire                            app_wr_cmd1;
   wire [ADDR_WIDTH-1:0]           app_wr_addr0;
   wire [ADDR_WIDTH-1:0]           app_wr_addr1;
   wire                            app_rd_cmd0;
   wire                            app_rd_cmd1;
   wire [ADDR_WIDTH-1:0]           app_rd_addr0;
   wire [ADDR_WIDTH-1:0]           app_rd_addr1;
   wire [BURST_LEN*DATA_WIDTH-1:0] app_wr_data0;
   wire [DATA_WIDTH*2-1:0]         app_wr_data1;
   wire [BURST_LEN*BW_WIDTH-1:0]   app_wr_bw_n0;
   wire [BW_WIDTH*2-1:0]           app_wr_bw_n1;
   wire                            app_cal_done;
   wire                            app_rd_valid0;
   wire                            app_rd_valid1;
   wire [BURST_LEN*DATA_WIDTH-1:0] app_rd_data0;
   wire [DATA_WIDTH*2-1:0]         app_rd_data1;
   wire [ADDR_WIDTH*2-1:0]         tg_addr;
   wire [APP_DATA_WIDTH-1:0]       dbg_cmp_data;
   wire [47:0]                     wr_data_counts;
   wire [47:0]                     rd_data_counts;

   wire                            vio_modify_enable;
   wire [3:0]                      vio_data_mode_value;
   wire                            vio_pause_traffic;
   wire [2:0]                      vio_addr_mode_value;
   wire [3:0]                      vio_instr_mode_value;
   wire [1:0]                      vio_bl_mode_value;
   wire [7:0]                      vio_fixed_bl_value;
   wire [2:0]                      vio_fixed_instr_value;
   wire                            vio_data_mask_gen;
   // Debug port wire declarations
   wire [15:0]                       qdriip_trigger;
   wire                              qdriip_cs0_clk;      // connect to clock in example top
   wire [35:0]                       qdriip_cs0_control;  // connect to ILA in example top
   wire [255:0]                      qdriip_ila0_data;
   wire [15:0]                       qdriip_ila0_trig;

   wire                              qdriip_cs1_clk;
   wire [35:0]                       qdriip_cs1_control;  // connect to ILA in example top
   wire [511:0]                      qdriip_ila1_data;
   wire [15:0]                       qdriip_ila1_trig;

   wire                              qdriip_cs2_clk;
   wire [35:0]                       qdriip_cs2_control;  // connect to VIO in example top
   wire [255:0]                      qdriip_vio2_async_in;
   wire [71:0]                       qdriip_vio2_sync_out;

   wire                              dbg_win_inc;
   wire                              dbg_win_dec;
   wire                              dbg_win_active;
   wire [3:0]                        dbg_win_current_byte;
   wire [5:0]                        dbg_pi_counter_read_val;
   wire [5:0]                        dbg_win_left_ram_out;
   wire [5:0]                        dbg_win_right_ram_out;
   wire [6:0]                        dbg_current_bit_ram_out;
   reg  [6:0]                        dbg_win_bit_select;
   wire [6:0]                        dbg_win_current_bit;
   wire                              dbg_win_clr_error;
   wire                              dbg_win_start;
   wire                              dbg_win_dump;
   wire                              dbg_win_dump_active;
   wire                              vio_win_bit_select_inc;
   wire                              vio_win_bit_select_dec;
   wire                              dbg_cmp_err;


//***************************************************************************






      
// Start of User Design top instance
//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************

  mig_7series_v1_9 #
    (
     
     .MEM_TYPE               (MEM_TYPE),             //Memory Type (QDR2PLUS, QDR2)
     .CLK_STABLE             (CLK_STABLE ),          //Cycles till CQ/CQ# is stable
     .ADDR_WIDTH             (ADDR_WIDTH ),          //Adress Width
     .DATA_WIDTH             (DATA_WIDTH ),          //Data Width
     .BW_WIDTH               (BW_WIDTH),             //Byte Write Width
     .BURST_LEN              (BURST_LEN),            //Burst Length
     .NUM_DEVICES            (NUM_DEVICES),          //Memory Devices
     .FIXED_LATENCY_MODE     (FIXED_LATENCY_MODE),   //Fixed Latency for data reads
     .PHY_LATENCY            (PHY_LATENCY),          //Value for Fixed Latency Mode
     .MEM_RD_LATENCY         (MEM_RD_LATENCY),       //Value of Memory part read latency
     .CPT_CLK_CQ_ONLY        (CPT_CLK_CQ_ONLY),      //Only CQ is used for data capture and no CQ#
     .SIMULATION             (SIMULATION),           //TRUE during design simulation
     .INTER_BANK_SKEW        (INTER_BANK_SKEW),      //Clock skew between adjacent banks
     .PHY_CONTROL_MASTER_BANK(PHY_CONTROL_MASTER_BANK),

     .SIM_BYPASS_INIT_CAL    (SIM_BYPASS_INIT_CAL),
     .IBUF_LPWR_MODE         (IBUF_LPWR_MODE ),      //Input buffer low power mode
     .IODELAY_HP_MODE        (IODELAY_HP_MODE),      //IODELAY High Performance Mode

     .DATA_CTL_B0            (DATA_CTL_B0),          //Data write/read bits in all banks
     .DATA_CTL_B1            (DATA_CTL_B1),
     .DATA_CTL_B2            (DATA_CTL_B2),
     .DATA_CTL_B3            (DATA_CTL_B3),
     .DATA_CTL_B4            (DATA_CTL_B4),
     .ADDR_CTL_MAP           (ADDR_CTL_MAP),

     .BYTE_LANES_B0          (BYTE_LANES_B0),        //Byte lanes used for the complete design
     .BYTE_LANES_B1          (BYTE_LANES_B1),
     .BYTE_LANES_B2          (BYTE_LANES_B2),
     .BYTE_LANES_B3          (BYTE_LANES_B3),
     .BYTE_LANES_B4          (BYTE_LANES_B4),

     .BYTE_GROUP_TYPE_B0     (BYTE_GROUP_TYPE_B0),   //Differentiates data write and read byte lanes
     .BYTE_GROUP_TYPE_B1     (BYTE_GROUP_TYPE_B1),
     .BYTE_GROUP_TYPE_B2     (BYTE_GROUP_TYPE_B2),
     .BYTE_GROUP_TYPE_B3     (BYTE_GROUP_TYPE_B3),
     .BYTE_GROUP_TYPE_B4     (BYTE_GROUP_TYPE_B4),

     .CPT_CLK_SEL_B0         (CPT_CLK_SEL_B0),         //Capture clock placement parameters
     .CPT_CLK_SEL_B1         (CPT_CLK_SEL_B1),
     .CPT_CLK_SEL_B2         (CPT_CLK_SEL_B2),

     .PHY_0_BITLANES         (PHY_0_BITLANES),         //Bits used for the complete design
     .PHY_1_BITLANES         (PHY_1_BITLANES),
     .PHY_2_BITLANES         (PHY_2_BITLANES),
     .PHY_3_BITLANES         (PHY_3_BITLANES),
     .PHY_4_BITLANES         (PHY_4_BITLANES),

     .ADD_MAP                (ADD_MAP),              // Address bits mapping
     .RD_MAP                 (RD_MAP),
     .WR_MAP                 (WR_MAP),

     .D0_MAP                 (D0_MAP),               // Data write bits mapping
     .D1_MAP                 (D1_MAP),
     .D2_MAP                 (D2_MAP),
     .D3_MAP                 (D3_MAP),
     .D4_MAP                 (D4_MAP),
     .D5_MAP                 (D5_MAP),
     .D6_MAP                 (D6_MAP),
     .D7_MAP                 (D7_MAP),
     .BW_MAP                 (BW_MAP),
     .K_MAP                  (K_MAP),

     .Q0_MAP                 (Q0_MAP),               // Data read bits mapping
     .Q1_MAP                 (Q1_MAP),
     .Q2_MAP                 (Q2_MAP),
     .Q3_MAP                 (Q3_MAP),
     .Q4_MAP                 (Q4_MAP),
     .Q5_MAP                 (Q5_MAP),
     .Q6_MAP                 (Q6_MAP),
     .Q7_MAP                 (Q7_MAP),
     .CQ_MAP                 (CQ_MAP),

     .DEBUG_PORT             (DEBUG_PORT),           // Debug using Chipscope controls
     .TCQ                    (TCQ),                  //Register Delay
      
     
     .nCK_PER_CLK                      (nCK_PER_CLK),
     .CLK_PERIOD                       (CLK_PERIOD),
     .DIFF_TERM_SYSCLK                 (DIFF_TERM_SYSCLK),
     .CLKIN_PERIOD                     (CLKIN_PERIOD),
     .CLKFBOUT_MULT                    (CLKFBOUT_MULT),                //Infrastructure M and D values
     .DIVCLK_DIVIDE                    (DIVCLK_DIVIDE),
     .CLKOUT0_DIVIDE                   (CLKOUT0_DIVIDE),
     .CLKOUT1_DIVIDE                   (CLKOUT1_DIVIDE),
     .CLKOUT2_DIVIDE                   (CLKOUT2_DIVIDE),
     .CLKOUT3_DIVIDE                   (CLKOUT3_DIVIDE),
     
     .SYSCLK_TYPE                      (SYSCLK_TYPE),
     .REFCLK_TYPE                      (REFCLK_TYPE),
     .SYS_RST_PORT                     (SYS_RST_PORT),
     .REFCLK_FREQ                      (REFCLK_FREQ),
     .DIFF_TERM_REFCLK                 (DIFF_TERM_REFCLK),
     .IODELAY_GRP                      (IODELAY_GRP),
      
     .DEVICE_TAPS                      (DEVICE_TAPS),          // Number of taps in the IDELAY chain
      
      
     .RST_ACT_LOW                      (RST_ACT_LOW)
     )
    u_mig_7series_v1_9
      (
       
     
     // Memory interface ports
     .qdriip_cq_p                     (qdriip_cq_p),
     .qdriip_cq_n                     (qdriip_cq_n),
     .qdriip_q                        (qdriip_q),
     .qdriip_k_p                      (qdriip_k_p),
     .qdriip_k_n                      (qdriip_k_n),
     .qdriip_d                        (qdriip_d),
     .qdriip_sa                       (qdriip_sa),
     .qdriip_w_n                      (qdriip_w_n),
     .qdriip_r_n                      (qdriip_r_n),
     .qdriip_bw_n                     (qdriip_bw_n),
     .qdriip_dll_off_n                (qdriip_dll_off_n),
     .init_calib_complete              (init_calib_complete),
      
     
     // Application interface ports
     .app_wr_cmd0                     (app_wr_cmd0),
     .app_wr_cmd1                     (1'b0),
     .app_wr_addr0                    (app_wr_addr0),
     .app_wr_addr1                    ({ADDR_WIDTH{1'b0}}),
     .app_rd_cmd0                     (app_rd_cmd0),
     .app_rd_cmd1                     (1'b0),
     .app_rd_addr0                    (app_rd_addr0),
     .app_rd_addr1                    ({ADDR_WIDTH{1'b0}}),
     .app_wr_data0                    (app_wr_data0),
     .app_wr_data1                    ({DATA_WIDTH*2{1'b0}}),
     .app_wr_bw_n0                    ({BURST_LEN*BW_WIDTH{1'b0}}),
     .app_wr_bw_n1                    ({2*BW_WIDTH{1'b0}}),
     .app_rd_valid0                   (app_rd_valid0),
     .app_rd_valid1                   (app_rd_valid1),
     .app_rd_data0                    (app_rd_data0),
     .app_rd_data1                    (app_rd_data1),
     .clk                             (clk),
     .rst_clk                         (rst_clk),
      
     // Debug Ports
     .qdriip_ila0_data                (qdriip_ila0_data),
     .qdriip_ila0_trig                (qdriip_ila0_trig),
     .qdriip_ila1_data                (qdriip_ila1_data[370:0]),
     .qdriip_ila1_trig                (qdriip_ila1_trig[12:0]),
     .qdriip_vio2_async_in            (qdriip_vio2_async_in[199:0]),
     .qdriip_vio2_sync_out            (qdriip_vio2_sync_out[35:0]),
     .dbg_win_inc             (dbg_win_inc),
     .dbg_win_dec             (dbg_win_dec),
     .dbg_win_active          (dbg_win_active),
     .dbg_win_current_byte    (dbg_win_current_byte),
     .dbg_pi_counter_read_val (dbg_pi_counter_read_val),

     
     // System Clock Ports
     .sys_clk_i                       (sys_clk_i),
     // Reference Clock Ports
     .clk_ref_i                       (clk_ref_i),
      
       .sys_rst                        (sys_rst)
       );
// End of User Design top instance


//***************************************************************************
// The traffic generation module instantiated below drives traffic (patterns)
// on the application interface of the memory controller
//***************************************************************************

  assign app_wr_addr0 = tg_addr[ADDR_WIDTH-1:0];
  assign app_rd_addr0 = tg_addr[ADDR_WIDTH-1:0];

  mig_7series_v1_9_traffic_gen_top #
    (
     .TCQ                 (TCQ),
     .SIMULATION          (SIMULATION),
     .FAMILY              ("VIRTEX7"),
     .MEM_TYPE            (MEM_TYPE),
     //.BL_WIDTH            (BL_WIDTH),
     .nCK_PER_CLK         (nCK_PER_CLK),
     .NUM_DQ_PINS         (DATA_WIDTH),
     .MEM_BURST_LEN       (BURST_LEN),
     .PORT_MODE           (PORT_MODE),
     .DATA_PATTERN        (DATA_PATTERN),
     .CMD_PATTERN         (CMD_PATTERN),
     .DATA_WIDTH          (APP_DATA_WIDTH),
     .ADDR_WIDTH          (ADDR_WIDTH),
     .DATA_MODE           (DATA_MODE),
     .BEGIN_ADDRESS       (BEGIN_ADDRESS),
     .END_ADDRESS         (END_ADDRESS),
     .PRBS_EADDR_MASK_POS (PRBS_EADDR_MASK_POS),
     .CMD_WDT             (CMD_WDT),
     .RD_WDT              (RD_WDT),
     .WR_WDT              (WR_WDT),
     .EYE_TEST            (EYE_TEST)
     )
    u_traffic_gen_top
      (
       .clk                  (clk),
       .rst                  (rst_clk),
       .tg_only_rst          (rst_clk),
       .manual_clear_error   (dbg_clear_error),
       .memc_init_done       (init_calib_complete),
       .memc_cmd_full        (1'b0),
       .memc_cmd_en          (),
       .memc_cmd_instr       (),
       .memc_cmd_bl          (),
       .memc_cmd_addr        (tg_addr[31:0]),
       .memc_wr_en           (),
       .memc_wr_end          (),
       .memc_wr_mask         (),
       .memc_wr_data         (app_wr_data0),
       .memc_wr_full         (1'b0),
       .memc_rd_en           (),
       .memc_rd_data         (app_rd_data0),
       .memc_rd_empty        (~app_rd_valid0),
       .qdr_wr_cmd_o         (app_wr_cmd0),
       .qdr_rd_cmd_o         (app_rd_cmd0),
       .vio_pause_traffic    (vio_pause_traffic),
       .vio_modify_enable    (vio_modify_enable),
       .vio_data_mode_value  (vio_data_mode_value),
       .vio_addr_mode_value  (vio_addr_mode_value),
       .vio_instr_mode_value (vio_instr_mode_value),
       .vio_bl_mode_value    (vio_bl_mode_value),
       .vio_fixed_bl_value   (vio_fixed_bl_value),
       .vio_fixed_instr_value(vio_fixed_instr_value),
       .vio_data_mask_gen    (vio_data_mask_gen),
       .fixed_addr_i         (32'b0),
       .fixed_data_i         (32'b0),
       .simple_data0         (32'b0),
       .simple_data1         (32'b0),
       .simple_data2         (32'b0),
       .simple_data3         (32'b0),
       .simple_data4         (32'b0),
       .simple_data5         (32'b0),
       .simple_data6         (32'b0),
       .simple_data7         (32'b0),
       .wdt_en_i             (1'b1),
       .bram_cmd_i           (39'b0),
       .bram_valid_i         (1'b0),
       .bram_rdy_o           (),
       .cmp_data             (dbg_cmp_data),
       .cmp_data_valid       (),
       .cmp_error            (dbg_cmp_err),
       .wr_data_counts       (wr_data_counts),
       .rd_data_counts       (rd_data_counts),
       .cumlative_dq_lane_error (),
       .cmd_wdt_err_o        (),
       .wr_wdt_err_o         (),
       .rd_wdt_err_o         (),
       .mem_pattern_init_done(),
       .error                (tg_compare_error),
       .error_status         ()
       );



  //*****************************************************************
  // Window check
  //*****************************************************************
  // number of bits for window size measurements
  localparam WIN_SIZE         = 6;
  localparam SIMULATE_CHK_WIN = "FALSE";

  wire sim_win_start;
  wire sim_win_dump;
  wire [nCK_PER_CLK*DATA_WIDTH-1 : 0] rd_data0;
  wire [nCK_PER_CLK*DATA_WIDTH-1 : 0] rd_data1;

  //Way to simulate chk_win functionality
  generate
    if ( (SIMULATION == "TRUE") && (SIMULATE_CHK_WIN == "TRUE")) begin: gen_sim_chk_win

      mig_7series_v1_9_sim_chk_win #
       (
         .TCQ                (TCQ)
       ) u_sim_chk_win
       (
         .clk                (clk),
         .rst                (rst_clk),
         .read_valid         (rd_valid0),
         .init_calib_complete(init_calib_complete),
         .win_active         (dbg_win_active),
         .win_start          (sim_win_start),
         .win_dump           (sim_win_dump)
       );

      //synthesis translate_off
      always @(posedge sim_win_start)
        if (!rst_clk)
          $display ("example_top.v: sim_win_start asserted  %t", $time);
      //synthesis translate_on

    end else begin: gen_sim_chk_win_bypass

      assign sim_win_start   = 1'b0;
      assign sim_win_dump    = 1'b0;

    end

    if (BURST_LEN == 2) begin: bl2_rddata

      assign rd_data0 = app_rd_data0;
      assign rd_data1 = app_rd_data1;

    end else begin: bl4_rddata

      assign rd_data0 = app_rd_data0[2*DATA_WIDTH-1 : 0];
      assign rd_data1 = app_rd_data0[4*DATA_WIDTH-1 : 2*DATA_WIDTH];

    end

  endgenerate

  always @(posedge clk)
  begin
    if (rst_clk)
      dbg_win_bit_select <= #TCQ 'b0;
    else if (dbg_win_inc) begin
      if (dbg_win_bit_select == (DATA_WIDTH/9)-1)
        dbg_win_bit_select <= #TCQ 'b0;
      else
        dbg_win_bit_select <= #TCQ dbg_win_bit_select + 1;
    end else if (dbg_win_dec) begin
      if (dbg_win_bit_select == 0)
        dbg_win_bit_select <= #TCQ (DATA_WIDTH/9) -1;
      else
        dbg_win_bit_select <= #TCQ dbg_win_bit_select - 1;
    end
  end

  mig_7series_v1_9_chk_win_top #
  (
    .TCQ         (TCQ),
    .nCK_PER_CLK (nCK_PER_CLK),
    .DLY_WIDTH   (26),
    .DQ_PER_DQS  (9),
    .DQ_WIDTH    (DATA_WIDTH),
    .SC_WIDTH    (3),
    .SDC_WIDTH   (5),
    .WIN_SIZE    (WIN_SIZE),
    .SIM_OPTION  ((SIMULATION == "TRUE") ? "ON" : "OFF")
  ) u_chk_win_top
  (
    .clk                 (clk),
    .rst                 (rst_clk),
    .win_start           ((SIMULATE_CHK_WIN == "TRUE") ? sim_win_start :
                                                         dbg_win_start),
    .win_dump            ((SIMULATE_CHK_WIN == "TRUE") ? sim_win_dump :
                                                         dbg_win_dump),
    .read_valid          (rd_valid0),
    .win_bit_select      ((SIMULATE_CHK_WIN == "TRUE") ? 7'b0 :
                                                       dbg_win_bit_select),
    .cmp_data            (dbg_cmp_data),
    .rd_data             ({rd_data1,
                           rd_data0}),
    .curr_tap_cnt        (dbg_pi_counter_read_val),
    .left_ram_out        (dbg_win_left_ram_out),
    .right_ram_out       (dbg_win_right_ram_out),
    .current_bit_ram_out (dbg_current_bit_ram_out),
    .win_active          (dbg_win_active),
    .win_dump_active     (dbg_win_dump_active),
    .win_clr_error       (dbg_win_clr_error),
    .win_inc             (dbg_win_inc),
    .win_dec             (dbg_win_dec),
    .win_current_bit     (dbg_win_current_bit),
    .win_current_byte    (dbg_win_current_byte),
    .dbg_win_chk         (),
    .dbg_clear_error     ((SIMULATE_CHK_WIN == "TRUE") ? 1'b0 :
                                                     dbg_clear_error)
  );

  generate
    if (DEBUG_PORT=="ON") begin: CHIPSCOPE_INST

       assign qdriip_cs0_clk            = clk;
       assign qdriip_cs1_clk            = clk;
       assign qdriip_cs2_clk            = clk;
       assign vio_modify_enable         = qdriip_vio2_sync_out[36];
       assign vio_data_mode_value       = qdriip_vio2_sync_out[40:37];
       assign vio_addr_mode_value       = qdriip_vio2_sync_out[43:41];
       assign vio_instr_mode_value      = qdriip_vio2_sync_out[47:44];
       assign vio_bl_mode_value         = qdriip_vio2_sync_out[49:48];
       assign vio_fixed_bl_value        = qdriip_vio2_sync_out[57:50];
       assign vio_data_mask_gen         = qdriip_vio2_sync_out[58];
       assign vio_pause_traffic         = qdriip_vio2_sync_out[59];
       assign vio_fixed_instr_value     = qdriip_vio2_sync_out[62:60];
       assign dbg_clear_error           = (!dbg_win_active) ? qdriip_vio2_sync_out[63] :
                                                              dbg_win_clr_error;
       assign dbg_win_start             = qdriip_vio2_sync_out[64];
       assign dbg_win_dump              = qdriip_vio2_sync_out[65];

       assign qdriip_vio2_async_in[200]    = tg_compare_error;
       assign qdriip_vio2_async_in[201]    = dbg_win_active;
       assign qdriip_vio2_async_in[202+:6] = dbg_win_left_ram_out;
       assign qdriip_vio2_async_in[208+:6] = dbg_win_right_ram_out;
       assign qdriip_vio2_async_in[214+:7] = dbg_win_bit_select;
       assign qdriip_vio2_async_in[221+:7] = dbg_win_current_bit[6:0];
       assign qdriip_vio2_async_in[228]    = dbg_cmp_err;
       assign qdriip_vio2_async_in[255:229]= 'b0;

       assign qdriip_ila1_data[511:428]    = 'b0;
       assign qdriip_ila1_data[422+:6]     = dbg_win_left_ram_out;
       assign qdriip_ila1_data[416+:6]     = dbg_win_right_ram_out;
       assign qdriip_ila1_data[409+:7]     = dbg_current_bit_ram_out;
       assign qdriip_ila1_data[373+:36]    = dbg_cmp_data[35:0];
       assign qdriip_ila1_data[372]        = tg_compare_error;
       assign qdriip_ila1_data[371]        = dbg_cmp_err;

       assign qdriip_ila1_trig[13]         = dbg_win_dump_active;
       assign qdriip_ila1_trig[14]         = dbg_cmp_err;
       assign qdriip_ila1_trig[15]         = tg_compare_error;

       icon3 u_icon3
       (
        .CONTROL0 (qdriip_cs0_control),
        .CONTROL1 (qdriip_cs1_control),
        .CONTROL2 (qdriip_cs2_control)
       );

       ila256_16 u_cs0_ila256_16
       (
        .CLK     (qdriip_cs0_clk),
        .CONTROL (qdriip_cs0_control),
        .DATA    (qdriip_ila0_data),
        .TRIG0   (qdriip_ila0_trig)
       );

       ila512_16 u_cs1_ila512_16
       (
        .CLK     (qdriip_cs1_clk),
        .CONTROL (qdriip_cs1_control),
        .DATA    (qdriip_ila1_data),
        .TRIG0   (qdriip_ila1_trig)
       );

       vio_async_in256_sync_out72 u_cs2_vio_async_in256_sync_out72
       (
        .CLK      (qdriip_cs2_clk),
        .CONTROL  (qdriip_cs2_control),
        .ASYNC_IN (qdriip_vio2_async_in),
        .SYNC_OUT (qdriip_vio2_sync_out)
       );

    end
    else begin: NO_CHIPSCOPE
       assign vio_modify_enable     = 1'b0;
       assign vio_data_mode_value   = 4'b0010;
       assign vio_addr_mode_value   = 3'b011;
       assign vio_instr_mode_value  = 4'b0010;
       assign vio_bl_mode_value     = 2'b10;
       assign vio_fixed_bl_value    = 8'd32;
       assign vio_data_mask_gen     = 1'b0;
       assign vio_pause_traffic     = 1'b0;
       assign vio_fixed_instr_value = 3'b001;
       assign dbg_clear_error       = 1'b0;
       assign qdriip_vio2_sync_out  = 72'b0;
    end
 endgenerate
      

endmodule
