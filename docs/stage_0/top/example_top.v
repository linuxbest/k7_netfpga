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
// \   \   \/     Version            : 1.9
//  \   \         Application        : MIG
//  /   /         Filename           : example_top.v
// /___/   /\     Date Last Modified : $Date: 2011/06/02 08:35:03 $
// \   \  /  \    Date Created       : Mon Aug 08 2011
//  \___\/\___\
//
// Device           : 7 Series
// Design Name      : Multi-Controller
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

   //***************************************************************************
   // Traffic Gen related parameters
   //***************************************************************************
   parameter C0_DDR3_BL_WIDTH              = 10,
   parameter C0_DDR3_PORT_MODE             = "BI_MODE",
   parameter C0_DDR3_DATA_MODE             = 4'b0010,
   parameter C0_DDR3_ADDR_MODE             = 4'b0011,
   parameter C0_DDR3_TST_MEM_INSTR_MODE    = "R_W_INSTR_MODE",
   parameter C0_DDR3_EYE_TEST              = "FALSE",
                                     // set EYE_TEST = "TRUE" to probe memory
                                     // signals. Traffic Generator will only
                                     // write to one single location and no
                                     // read transactions will be generated.
   parameter C0_DDR3_DATA_PATTERN          = "DGEN_ALL",
                                      // For small devices, choose one only.
                                      // For large device, choose "DGEN_ALL"
                                      // "DGEN_HAMMER", "DGEN_WALKING1",
                                      // "DGEN_WALKING0","DGEN_ADDR","
                                      // "DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"
   parameter C0_DDR3_CMD_PATTERN           = "CGEN_ALL",
                                      // "CGEN_PRBS","CGEN_FIXED","CGEN_BRAM",
                                      // "CGEN_SEQUENTIAL", "CGEN_ALL"
   parameter C0_DDR3_BEGIN_ADDRESS         = 32'h00000000,
   parameter C0_DDR3_END_ADDRESS           = 32'h00ffffff,
   parameter C0_DDR3_MEM_ADDR_ORDER
     = "TG_TEST",
   parameter C0_DDR3_PRBS_EADDR_MASK_POS   = 32'hff000000,
   parameter C0_DDR3_CMD_WDT               = 'h3FF,
   parameter C0_DDR3_WR_WDT                = 'h1FFF,
   parameter C0_DDR3_RD_WDT                = 'h3FF,
   parameter C0_DDR3_SEL_VICTIM_LINE       = 0,

   //***************************************************************************
   // The following parameters refer to width of various ports
   //***************************************************************************
   parameter C0_DDR3_BANK_WIDTH            = 3,
                                     // # of memory Bank Address bits.
   parameter C0_DDR3_CK_WIDTH              = 1,
                                     // # of CK/CK# outputs to memory.
   parameter C0_DDR3_COL_WIDTH             = 10,
                                     // # of memory Column Address bits.
   parameter C0_DDR3_CS_WIDTH              = 1,
                                     // # of unique CS outputs to memory.
   parameter C0_DDR3_nCS_PER_RANK          = 1,
                                     // # of unique CS outputs per rank for phy
   parameter C0_DDR3_CKE_WIDTH             = 1,
                                     // # of CKE outputs to memory.
   parameter C0_DDR3_DATA_BUF_ADDR_WIDTH   = 5,
   parameter C0_DDR3_DQ_CNT_WIDTH          = 6,
                                     // = ceil(log2(DQ_WIDTH))
   parameter C0_DDR3_DQ_PER_DM             = 8,
   parameter C0_DDR3_DM_WIDTH              = 8,
                                     // # of DM (data mask)
   parameter C0_DDR3_DQ_WIDTH              = 64,
                                     // # of DQ (data)
   parameter C0_DDR3_DQS_WIDTH             = 8,
   parameter C0_DDR3_DQS_CNT_WIDTH         = 3,
                                     // = ceil(log2(DQS_WIDTH))
   parameter C0_DDR3_DRAM_WIDTH            = 8,
                                     // # of DQ per DQS
   parameter C0_DDR3_ECC                   = "OFF",
   parameter C0_DDR3_nBANK_MACHS           = 4,
   parameter C0_DDR3_RANKS                 = 1,
                                     // # of Ranks.
   parameter C0_DDR3_ODT_WIDTH             = 1,
                                     // # of ODT outputs to memory.
   parameter C0_DDR3_ROW_WIDTH             = 16,
                                     // # of memory Row Address bits.
   parameter C0_DDR3_ADDR_WIDTH            = 30,
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices
   parameter C0_DDR3_USE_CS_PORT          = 1,
                                     // # = 1, When Chip Select (CS#) output is enabled
                                     //   = 0, When Chip Select (CS#) output is disabled
                                     // If CS_N disabled, user must connect
                                     // DRAM CS_N input(s) to ground
   parameter C0_DDR3_USE_DM_PORT           = 1,
                                     // # = 1, When Data Mask option is enabled
                                     //   = 0, When Data Mask option is disbaled
                                     // When Data Mask option is disabled in
                                     // MIG Controller Options page, the logic
                                     // related to Data Mask should not get
                                     // synthesized
   parameter C0_DDR3_USE_ODT_PORT          = 1,
                                     // # = 1, When ODT output is enabled
                                     //   = 0, When ODT output is disabled
                                     // Parameter configuration for Dynamic ODT support:
                                     // USE_ODT_PORT = 0, RTT_NOM = "DISABLED", RTT_WR = "60/120".
                                     // This configuration allows to save ODT pin mapping from FPGA.
                                     // The user can tie the ODT input of DRAM to HIGH.
   parameter C0_DDR3_PHY_CONTROL_MASTER_BANK = 1,
                                     // The bank index where master PHY_CONTROL resides,
                                     // equal to the PLL residing bank
   parameter C0_DDR3_MEM_DENSITY           = "4Gb",
                                     // Indicates the density of the Memory part
                                     // Added for the sake of Vivado simulations
   parameter C0_DDR3_MEM_SPEEDGRADE        = "107E",
                                     // Indicates the Speed grade of Memory Part
                                     // Added for the sake of Vivado simulations
   parameter C0_DDR3_MEM_DEVICE_WIDTH      = 8,
                                     // Indicates the device width of the Memory Part
                                     // Added for the sake of Vivado simulations

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   parameter C0_DDR3_AL                    = "0",
                                     // DDR3 SDRAM:
                                     // Additive Latency (Mode Register 1).
                                     // # = "0", "CL-1", "CL-2".
                                     // DDR2 SDRAM:
                                     // Additive Latency (Extended Mode Register).
   parameter C0_DDR3_nAL                   = 0,
                                     // # Additive Latency in number of clock
                                     // cycles.
   parameter C0_DDR3_BURST_MODE            = "8",
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".
   parameter C0_DDR3_BURST_TYPE            = "SEQ",
                                     // DDR3 SDRAM: Burst Type (Mode Register 0).
                                     // DDR2 SDRAM: Burst Type (Mode Register).
                                     // # = "SEQ" - (Sequential),
                                     //   = "INT" - (Interleaved).
   parameter C0_DDR3_CL                    = 13,
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Latency (Mode Register 0).
                                     // DDR2 SDRAM: CAS Latency (Mode Register).
   parameter C0_DDR3_CWL                   = 9,
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Write Latency (Mode Register 2).
                                     // DDR2 SDRAM: Can be ignored
   parameter C0_DDR3_OUTPUT_DRV            = "HIGH",
                                     // Output Driver Impedance Control (Mode Register 1).
                                     // # = "HIGH" - RZQ/7,
                                     //   = "LOW" - RZQ/6.
   parameter C0_DDR3_RTT_NOM               = "60",
                                     // RTT_NOM (ODT) (Mode Register 1).
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
                                     //   = "40"  - RZQ/6.
   parameter C0_DDR3_RTT_WR                = "OFF",
                                     // RTT_WR (ODT) (Mode Register 2).
                                     // # = "OFF" - Dynamic ODT off,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
   parameter C0_DDR3_ADDR_CMD_MODE         = "1T" ,
                                     // # = "1T", "2T".
   parameter C0_DDR3_REG_CTRL              = "OFF",
                                     // # = "ON" - RDIMMs,
                                     //   = "OFF" - Components, SODIMMs, UDIMMs.
   parameter C0_DDR3_CA_MIRROR             = "OFF",
                                     // C/A mirror opt for DDR3 dual rank
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for PLLE2.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   parameter C0_DDR3_CLKIN_PERIOD          = 6432,
                                     // Input Clock Period
   parameter C0_DDR3_CLKFBOUT_MULT         = 12,
                                     // write PLL VCO multiplier
   parameter C0_DDR3_DIVCLK_DIVIDE         = 1,
                                     // write PLL VCO divisor
   parameter C0_DDR3_CLKOUT0_PHASE         = 337.5,
                                     // Phase for PLL output clock (CLKOUT0)
   parameter C0_DDR3_CLKOUT0_DIVIDE        = 2,
                                     // VCO output divisor for PLL output clock (CLKOUT0)
   parameter C0_DDR3_CLKOUT1_DIVIDE        = 2,
                                     // VCO output divisor for PLL output clock (CLKOUT1)
   parameter C0_DDR3_CLKOUT2_DIVIDE        = 32,
                                     // VCO output divisor for PLL output clock (CLKOUT2)
   parameter C0_DDR3_CLKOUT3_DIVIDE        = 8,
                                     // VCO output divisor for PLL output clock (CLKOUT3)

   //***************************************************************************
   // Memory Timing Parameters. These parameters varies based on the selected
   // memory part.
   //***************************************************************************
   parameter C0_DDR3_tCKE                  = 5000,
                                     // memory tCKE paramter in pS
   parameter C0_DDR3_tFAW                  = 25000,
                                     // memory tRAW paramter in pS.
   parameter C0_DDR3_tRAS                  = 34000,
                                     // memory tRAS paramter in pS.
   parameter C0_DDR3_tRCD                  = 13910,
                                     // memory tRCD paramter in pS.
   parameter C0_DDR3_tREFI                 = 7800000,
                                     // memory tREFI paramter in pS.
   parameter C0_DDR3_tRFC                  = 300000,
                                     // memory tRFC paramter in pS.
   parameter C0_DDR3_tRP                   = 13910,
                                     // memory tRP paramter in pS.
   parameter C0_DDR3_tRRD                  = 5000,
                                     // memory tRRD paramter in pS.
   parameter C0_DDR3_tRTP                  = 7500,
                                     // memory tRTP paramter in pS.
   parameter C0_DDR3_tWTR                  = 7500,
                                     // memory tWTR paramter in pS.
   parameter C0_DDR3_tZQI                  = 128_000_000,
                                     // memory tZQI paramter in nS.
   parameter C0_DDR3_tZQCS                 = 64,
                                     // memory tZQCS paramter in clock cycles.

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   parameter C0_DDR3_SIM_BYPASS_INIT_CAL   = "OFF",
                                     // # = "OFF" -  Complete memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Not supported
                                     // # = "FAST" - Complete memory init & use
                                     //              abbreviated calib sequence

   parameter C0_DDR3_SIMULATION            = "FALSE",
                                     // Should be TRUE during design simulations and
                                     // FALSE during implementations

   //***************************************************************************
   // The following parameters varies based on the pin out entered in MIG GUI.
   // Do not change any of these parameters directly by editing the RTL.
   // Any changes required should be done through GUI and the design regenerated.
   //***************************************************************************
   parameter C0_DDR3_BYTE_LANES_B0         = 4'b1111,
                                     // Byte lanes used in an IO column.
   parameter C0_DDR3_BYTE_LANES_B1         = 4'b1110,
                                     // Byte lanes used in an IO column.
   parameter C0_DDR3_BYTE_LANES_B2         = 4'b1111,
                                     // Byte lanes used in an IO column.
   parameter C0_DDR3_BYTE_LANES_B3         = 4'b0000,
                                     // Byte lanes used in an IO column.
   parameter C0_DDR3_BYTE_LANES_B4         = 4'b0000,
                                     // Byte lanes used in an IO column.
   parameter C0_DDR3_DATA_CTL_B0           = 4'b1111,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C0_DDR3_DATA_CTL_B1           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C0_DDR3_DATA_CTL_B2           = 4'b1111,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C0_DDR3_DATA_CTL_B3           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C0_DDR3_DATA_CTL_B4           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C0_DDR3_PHY_0_BITLANES        = 48'h3FE_3FE_3FE_2FF,
   parameter C0_DDR3_PHY_1_BITLANES        = 48'h3FF_FFF_C20_000,
   parameter C0_DDR3_PHY_2_BITLANES        = 48'h3FE_3FE_3FE_2FF,

   // control/address/data pin mapping parameters
   parameter C0_DDR3_CK_BYTE_MAP
     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_13,
   parameter C0_DDR3_ADDR_MAP
     = 192'h139_138_137_136_135_134_133_132_131_130_129_128_127_126_12B_12A,
   parameter C0_DDR3_BANK_MAP   = 36'h125_124_123,
   parameter C0_DDR3_CAS_MAP    = 12'h121,
   parameter C0_DDR3_CKE_ODT_BYTE_MAP = 8'h00,
   parameter C0_DDR3_CKE_MAP    = 96'h000_000_000_000_000_000_000_11A,
   parameter C0_DDR3_ODT_MAP    = 96'h000_000_000_000_000_000_000_115,
   parameter C0_DDR3_CS_MAP     = 120'h000_000_000_000_000_000_000_000_000_11B,
   parameter C0_DDR3_PARITY_MAP = 12'h000,
   parameter C0_DDR3_RAS_MAP    = 12'h122,
   parameter C0_DDR3_WE_MAP     = 12'h120,
   parameter C0_DDR3_DQS_BYTE_MAP
     = 144'h00_00_00_00_00_00_00_00_00_00_20_21_22_23_00_01_02_03,
   parameter C0_DDR3_DATA0_MAP  = 96'h031_032_033_034_035_036_037_038,
   parameter C0_DDR3_DATA1_MAP  = 96'h021_022_023_024_025_026_027_028,
   parameter C0_DDR3_DATA2_MAP  = 96'h011_012_013_014_016_017_018_019,
   parameter C0_DDR3_DATA3_MAP  = 96'h000_001_002_003_004_005_006_007,
   parameter C0_DDR3_DATA4_MAP  = 96'h231_232_233_234_235_236_237_238,
   parameter C0_DDR3_DATA5_MAP  = 96'h221_222_223_224_225_226_227_228,
   parameter C0_DDR3_DATA6_MAP  = 96'h211_212_213_214_216_217_218_219,
   parameter C0_DDR3_DATA7_MAP  = 96'h200_201_202_203_204_205_206_207,
   parameter C0_DDR3_DATA8_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter C0_DDR3_DATA9_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter C0_DDR3_DATA10_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter C0_DDR3_DATA11_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter C0_DDR3_DATA12_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter C0_DDR3_DATA13_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter C0_DDR3_DATA14_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter C0_DDR3_DATA15_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter C0_DDR3_DATA16_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter C0_DDR3_DATA17_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter C0_DDR3_MASK0_MAP  = 108'h000_209_215_229_239_009_015_029_039,
   parameter C0_DDR3_MASK1_MAP  = 108'h000_000_000_000_000_000_000_000_000,

   parameter C0_DDR3_SLOT_0_CONFIG         = 8'b0000_0001,
                                     // Mapping of Ranks.
   parameter C0_DDR3_SLOT_1_CONFIG         = 8'b0000_0000,
                                     // Mapping of Ranks.

   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   parameter C0_DDR3_IODELAY_HP_MODE       = "ON",
                                     // to phy_top
   parameter C0_DDR3_IBUF_LPWR_MODE        = "OFF",
                                     // to phy_top
   parameter C0_DDR3_DATA_IO_IDLE_PWRDWN   = "ON",
                                     // # = "ON", "OFF"
   parameter C0_DDR3_BANK_TYPE             = "HP_IO",
                                     // # = "HP_IO", "HPL_IO", "HR_IO", "HRL_IO"
   parameter C0_DDR3_DATA_IO_PRIM_TYPE     = "HP_LP",
                                     // # = "HP_LP", "HR_LP", "DEFAULT"
   parameter C0_DDR3_CKE_ODT_AUX           = "FALSE",
   parameter C0_DDR3_USER_REFRESH          = "OFF",
   parameter C0_DDR3_WRLVL                 = "ON",
                                     // # = "ON" - DDR3 SDRAM
                                     //   = "OFF" - DDR2 SDRAM.
   parameter C0_DDR3_ORDERING              = "NORM",
                                     // # = "NORM", "STRICT", "RELAXED".
   parameter C0_DDR3_CALIB_ROW_ADD         = 16'h0000,
                                     // Calibration row address will be used for
                                     // calibration read and write operations
   parameter C0_DDR3_CALIB_COL_ADD         = 12'h000,
                                     // Calibration column address will be used for
                                     // calibration read and write operations
   parameter C0_DDR3_CALIB_BA_ADD          = 3'h0,
                                     // Calibration bank address will be used for
                                     // calibration read and write operations
   parameter C0_DDR3_TCQ                   = 100,
   parameter IODELAY_GRP           = "IODELAY_MIG",
                                     // It is associated to a set of IODELAYs with
                                     // an IDELAYCTRL that have same IODELAY CONTROLLER
                                     // clock frequency.
   parameter SYSCLK_TYPE           = "DIFFERENTIAL",
                                     // System clock type DIFFERENTIAL, SINGLE_ENDED,
                                     // NO_BUFFER
   parameter REFCLK_TYPE           = "DIFFERENTIAL",
                                     // Reference clock type DIFFERENTIAL, SINGLE_ENDED,
                                     // NO_BUFFER, USE_SYSTEM_CLOCK
   parameter SYS_RST_PORT          = "FALSE",
                                     // "TRUE" - if pin is selected for sys_rst
                                     //          and IBUF will be instantiated.
                                     // "FALSE" - if pin is not selected for sys_rst
      
   parameter DRAM_TYPE             = "DDR3",
   parameter CAL_WIDTH             = "HALF",
   parameter STARVE_LIMIT          = 2,
                                     // # = 2,3,4.

   //***************************************************************************
   // Referece clock frequency parameters
   //***************************************************************************
   parameter REFCLK_FREQ           = 200.0,
                                     // IODELAYCTRL reference clock frequency
   parameter DIFF_TERM_REFCLK      = "FALSE",
                                     // Differential Termination for idelay
                                     // reference clock input pins
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter C0_DDR3_tCK                   = 1072,
                                     // memory tCK paramter.
                                     // # = Clock Period in pS.
   parameter C0_DDR3_nCK_PER_CLK           = 4,
                                     // # of memory CKs per fabric CLK
   parameter C0_DDR3_DIFF_TERM_SYSCLK      = "TRUE",
                                     // Differential Termination for System
                                     // clock input pins

   

   //***************************************************************************
   // Debug parameters
   //***************************************************************************
   parameter C0_DDR3_DEBUG_PORT            = "OFF",
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.

   //***************************************************************************
   // Temparature monitor parameter
   //***************************************************************************
   parameter C0_DDR3_TEMP_MON_CONTROL                          = "INTERNAL",
                                     // # = "INTERNAL", "EXTERNAL"
      
   parameter C1_QDRIIP_MEM_TYPE              = "QDR2PLUS",
                                     // # of CK/CK# outputs to memory.
   parameter C1_QDRIIP_DATA_WIDTH            = 36,
                                     // # of DQ (data)
   parameter C1_QDRIIP_BW_WIDTH              = 4,
                                     // # of byte writes (data_width/9)
   parameter C1_QDRIIP_ADDR_WIDTH            = 19,
                                     // Address Width
   parameter C1_QDRIIP_NUM_DEVICES           = 2,
                                     // # of memory components connected
   parameter C1_QDRIIP_MEM_RD_LATENCY        = 2.5,
                                     // Value of Memory part read latency
   parameter C1_QDRIIP_CPT_CLK_CQ_ONLY       = "TRUE",
                                     // whether CQ and its inverse are used for the data capture
   parameter C1_QDRIIP_INTER_BANK_SKEW       = 0,
                                     // Clock skew between two adjacent banks
   parameter C1_QDRIIP_PHY_CONTROL_MASTER_BANK = 2,
                                     // The bank index where master PHY_CONTROL resides,
                                     // equal to the PLL residing bank

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   parameter C1_QDRIIP_BURST_LEN             = 4,
                                     // Burst Length of the design (4 or 2).
   parameter C1_QDRIIP_FIXED_LATENCY_MODE    = 0,
                                     // Enable Fixed Latency
   parameter C1_QDRIIP_PHY_LATENCY           = 0,
                                     // Value for Fixed Latency Mode
                                     // Expected Latency
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for MMCM.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   parameter C1_QDRIIP_CLKIN_PERIOD          = 10000,
                                     // Input Clock Period
   parameter C1_QDRIIP_CLKFBOUT_MULT         = 10,
                                     // write PLL VCO multiplier
   parameter C1_QDRIIP_DIVCLK_DIVIDE         = 1,
                                     // write PLL VCO divisor
   parameter C1_QDRIIP_CLKOUT0_DIVIDE        = 2,
                                     // VCO output divisor for PLL output clock (CLKOUT0)
   parameter C1_QDRIIP_CLKOUT1_DIVIDE        = 2,
                                     // VCO output divisor for PLL output clock (CLKOUT1)
   parameter C1_QDRIIP_CLKOUT2_DIVIDE        = 32,
                                     // VCO output divisor for PLL output clock (CLKOUT2)
   parameter C1_QDRIIP_CLKOUT3_DIVIDE        = 4,
                                     // VCO output divisor for PLL output clock (CLKOUT3)

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   parameter C1_QDRIIP_SIM_BYPASS_INIT_CAL   = "OFF",
                                     // # = "OFF" -  Complete memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Skip memory init &
                                     //              calibration sequence
                                     // # = "FAST" - Skip memory init & use
                                     //              abbreviated calib sequence
   parameter C1_QDRIIP_SIMULATION            = "FALSE",
                                     // Should be TRUE during design simulations and
                                     // FALSE during implementations

   //***************************************************************************
   // The following parameters varies based on the pin out entered in MIG GUI.
   // Do not change any of these parameters directly by editing the RTL.
   // Any changes required should be done through GUI and the design regenerated.
   //***************************************************************************
   parameter C1_QDRIIP_BYTE_LANES_B0         = 4'b1111,
                                     // Byte lanes used in an IO column.
   parameter C1_QDRIIP_BYTE_LANES_B1         = 4'b1100,
                                     // Byte lanes used in an IO column.
   parameter C1_QDRIIP_BYTE_LANES_B2         = 4'b1111,
                                     // Byte lanes used in an IO column.
   parameter C1_QDRIIP_BYTE_LANES_B3         = 4'b0000,
                                     // Byte lanes used in an IO column.
   parameter C1_QDRIIP_BYTE_LANES_B4         = 4'b0000,
                                     // Byte lanes used in an IO column.
   parameter C1_QDRIIP_DATA_CTL_B0           = 4'b1111,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C1_QDRIIP_DATA_CTL_B1           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C1_QDRIIP_DATA_CTL_B2           = 4'b1111,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C1_QDRIIP_DATA_CTL_B3           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C1_QDRIIP_DATA_CTL_B4           = 4'b0000,
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
   parameter C1_QDRIIP_CPT_CLK_SEL_B0  = 32'h11_11_01_01,
   parameter C1_QDRIIP_CPT_CLK_SEL_B1  = 32'h00_00_00_00,
   parameter C1_QDRIIP_CPT_CLK_SEL_B2  = 32'h00_00_00_00,

   parameter C1_QDRIIP_PHY_0_BITLANES       = 48'hFF8_FF1_D3F_EFC,
                                     // The bits used inside the Bank0 out of 48 pins.
   parameter C1_QDRIIP_PHY_1_BITLANES       = 48'hFFE_FFC_000_000,
                                     // The bits used inside the Bank1 out of 48 pins.
   parameter C1_QDRIIP_PHY_2_BITLANES       = 48'h3FE_FFE_3FE_FFE,
                                     // The bits used inside the Bank2 out of 48 pins.
   parameter C1_QDRIIP_PHY_3_BITLANES       = 48'h000_000_000_000,
                                     // The bits used inside the Bank3 out of 48 pins.
   parameter C1_QDRIIP_PHY_4_BITLANES       = 48'h000_000_000_000,
                                     // The bits used inside the Bank4 out of 48 pins.

   // Differentiates the INPUT and OUTPUT bytelates (1-input, 0-output)
   parameter C1_QDRIIP_BYTE_GROUP_TYPE_B0 = 4'b1111,
   parameter C1_QDRIIP_BYTE_GROUP_TYPE_B1 = 4'b0000,
   parameter C1_QDRIIP_BYTE_GROUP_TYPE_B2 = 4'b0000,
   parameter C1_QDRIIP_BYTE_GROUP_TYPE_B3 = 4'b0000,
   parameter C1_QDRIIP_BYTE_GROUP_TYPE_B4 = 4'b0000,

   // mapping for K/K# clocks. This parameter needs to have an 8-bit value per component
   // since the phy drives a K/K# clock pair to each memory it interfaces to. A 3 component
   // interface is supported for now. This parameter needs to be used in conjunction with
   // NUM_DEVICES parameter which provides information on the number. of components being
   // interfaced to.
   // the 8 bit for each component is defined as follows:
   // [7:4] - bank number ; [3:0] - byte lane number
   parameter C1_QDRIIP_K_MAP = 48'h00_00_00_00_21_23,

   // mapping for CQ/CQ# clocks. This parameter needs to have an 4-bit value per component
   // since the phy drives a CQ/CQ# clock pair to each memory it interfaces to. A 3 component
   // interface is supported for now. This parameter needs to be used in conjunction with
   // NUM_DEVICES parameter which provides information on the number. of components being
   // interfaced to.
   // the 4 bit for each component is defined as follows:
   // [3:0] - bank number
   parameter C1_QDRIIP_CQ_MAP = 48'h00_00_00_00_11_01,

   //**********************************************************************************************
   // Each of the following parameter contains the byte_lane and bit position information for
   // the address/control, data write and data read signals. Each bit has 12 bits and the details are
   // [3:0] - Bit position within a byte lane .
   // [7:4] - Byte lane position within a bank. [5:4] have the byte lane position and others reserved.
   // [11:8] - Bank position. [10:8] have the bank position. [11] tied to zero .
   //**********************************************************************************************

   // Mapping for address and control signals.

   parameter C1_QDRIIP_RD_MAP = 12'h122,      // Mapping for read enable signal
   parameter C1_QDRIIP_WR_MAP = 12'h123,      // Mapping for write enable signal

   // Mapping for address signals. Supports upto 22 bits of address bits (22*12)
   parameter C1_QDRIIP_ADD_MAP = 264'h000_000_000_139_138_137_136_13B_13A_135_134_133_132_131_129_128_127_126_12B_12A_125_124,

   // Mapping for the byte lanes used for address/control signals. Supports a maximum of 3 banks.
   parameter C1_QDRIIP_ADDR_CTL_MAP = 24'h00_12_13,

   // Mapping for data WRITE signals

   // Mapping for data write bytes (9*12)
   parameter C1_QDRIIP_D0_MAP  = 108'h231_232_233_234_235_236_237_238_239, //byte 0
   parameter C1_QDRIIP_D1_MAP  = 108'h221_222_223_224_225_22A_22B_226_227, //byte 1
   parameter C1_QDRIIP_D2_MAP  = 108'h211_212_213_214_215_216_217_218_219, //byte 2
   parameter C1_QDRIIP_D3_MAP  = 108'h201_202_203_204_205_20A_20B_206_207, //byte 3
   parameter C1_QDRIIP_D4_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 4
   parameter C1_QDRIIP_D5_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 5
   parameter C1_QDRIIP_D6_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 6
   parameter C1_QDRIIP_D7_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 7

   // Mapping for byte write signals (8*12)
   parameter C1_QDRIIP_BW_MAP = 84'h000_000_000_208_209_228_229,

   // Mapping for data READ signals

   // Mapping for data read bytes (9*12)
   parameter C1_QDRIIP_Q0_MAP  = 108'h033_034_035_03A_03B_036_037_038_039, //byte 0
   parameter C1_QDRIIP_Q1_MAP  = 108'h020_024_025_02A_02B_026_027_028_029, //byte 1
   parameter C1_QDRIIP_Q2_MAP  = 108'h010_011_012_013_014_015_01A_01B_018, //byte 2
   parameter C1_QDRIIP_Q3_MAP  = 108'h002_003_004_005_00A_00B_006_007_009, //byte 3
   parameter C1_QDRIIP_Q4_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 4
   parameter C1_QDRIIP_Q5_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 5
   parameter C1_QDRIIP_Q6_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 6
   parameter C1_QDRIIP_Q7_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 7

   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   parameter C1_QDRIIP_IODELAY_HP_MODE       = "ON",
                                     // to phy_top
   parameter C1_QDRIIP_IBUF_LPWR_MODE        = "OFF",
                                     // to phy_top
   parameter C1_QDRIIP_TCQ                   = 100,
   
   // Number of taps in target IDELAY
   parameter integer DEVICE_TAPS = 32,

   
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter C1_QDRIIP_CLK_PERIOD            = 2000,
                                     // memory tCK paramter.
                                     // # = Clock Period in pS.
   parameter C1_QDRIIP_nCK_PER_CLK           = 2,
                                     // # of memory CKs per fabric CLK
   parameter C1_QDRIIP_DIFF_TERM_SYSCLK      = "FALSE",
                                     // Differential Termination for System
                                     // clock input pins

      //***************************************************************************
   // Traffic Gen related parameters
   //***************************************************************************
   parameter C1_QDRIIP_BL_WIDTH              = 8,
   parameter C1_QDRIIP_PORT_MODE             = "BI_MODE",
   parameter C1_QDRIIP_DATA_MODE             = 4'b0010,
   parameter C1_QDRIIP_EYE_TEST              = "FALSE",
                                     // set EYE_TEST = "TRUE" to probe memory
                                     // signals. Traffic Generator will only
                                     // write to one single location and no
                                     // read transactions will be generated.
   parameter C1_QDRIIP_DATA_PATTERN          = "DGEN_ALL",
                                      // "DGEN_HAMMER", "DGEN_WALKING1",
                                      // "DGEN_WALKING0","DGEN_ADDR","
                                      // "DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"
   parameter C1_QDRIIP_CMD_PATTERN           = "CGEN_ALL",
                                      // "CGEN_PRBS","CGEN_FIXED","CGEN_BRAM",
                                      // "CGEN_SEQUENTIAL", "CGEN_ALL"
   parameter C1_QDRIIP_CMD_WDT               = 'h3FF,
   parameter C1_QDRIIP_WR_WDT                = 'h1FFF,
   parameter C1_QDRIIP_RD_WDT                = 'h3FF,
   parameter C1_QDRIIP_BEGIN_ADDRESS         = 32'h00000000,
   parameter C1_QDRIIP_END_ADDRESS           = 32'h00000fff,
   parameter C1_QDRIIP_PRBS_EADDR_MASK_POS   = 32'hfffff000,

   //***************************************************************************
   // Wait period for the read strobe (CQ) to become stable
   //***************************************************************************
   parameter C1_QDRIIP_CLK_STABLE            = (20*1000*1000/(C1_QDRIIP_CLK_PERIOD*2)),
                                     // Cycles till CQ/CQ# is stable

   //***************************************************************************
   // Debug parameter
   //***************************************************************************
   parameter C1_QDRIIP_DEBUG_PORT            = "OFF",
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
      
   parameter C2_QDRIIP_MEM_TYPE              = "QDR2PLUS",
                                     // # of CK/CK# outputs to memory.
   parameter C2_QDRIIP_DATA_WIDTH            = 36,
                                     // # of DQ (data)
   parameter C2_QDRIIP_BW_WIDTH              = 4,
                                     // # of byte writes (data_width/9)
   parameter C2_QDRIIP_ADDR_WIDTH            = 19,
                                     // Address Width
   parameter C2_QDRIIP_NUM_DEVICES           = 2,
                                     // # of memory components connected
   parameter C2_QDRIIP_MEM_RD_LATENCY        = 2.5,
                                     // Value of Memory part read latency
   parameter C2_QDRIIP_CPT_CLK_CQ_ONLY       = "TRUE",
                                     // whether CQ and its inverse are used for the data capture
   parameter C2_QDRIIP_INTER_BANK_SKEW       = 0,
                                     // Clock skew between two adjacent banks
   parameter C2_QDRIIP_PHY_CONTROL_MASTER_BANK = 1,
                                     // The bank index where master PHY_CONTROL resides,
                                     // equal to the PLL residing bank

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   parameter C2_QDRIIP_BURST_LEN             = 4,
                                     // Burst Length of the design (4 or 2).
   parameter C2_QDRIIP_FIXED_LATENCY_MODE    = 0,
                                     // Enable Fixed Latency
   parameter C2_QDRIIP_PHY_LATENCY           = 0,
                                     // Value for Fixed Latency Mode
                                     // Expected Latency
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for MMCM.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   parameter C2_QDRIIP_CLKIN_PERIOD          = 10000,
                                     // Input Clock Period
   parameter C2_QDRIIP_CLKFBOUT_MULT         = 10,
                                     // write PLL VCO multiplier
   parameter C2_QDRIIP_DIVCLK_DIVIDE         = 1,
                                     // write PLL VCO divisor
   parameter C2_QDRIIP_CLKOUT0_DIVIDE        = 2,
                                     // VCO output divisor for PLL output clock (CLKOUT0)
   parameter C2_QDRIIP_CLKOUT1_DIVIDE        = 2,
                                     // VCO output divisor for PLL output clock (CLKOUT1)
   parameter C2_QDRIIP_CLKOUT2_DIVIDE        = 32,
                                     // VCO output divisor for PLL output clock (CLKOUT2)
   parameter C2_QDRIIP_CLKOUT3_DIVIDE        = 4,
                                     // VCO output divisor for PLL output clock (CLKOUT3)

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   parameter C2_QDRIIP_SIM_BYPASS_INIT_CAL   = "OFF",
                                     // # = "OFF" -  Complete memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Skip memory init &
                                     //              calibration sequence
                                     // # = "FAST" - Skip memory init & use
                                     //              abbreviated calib sequence
   parameter C2_QDRIIP_SIMULATION            = "FALSE",
                                     // Should be TRUE during design simulations and
                                     // FALSE during implementations

   //***************************************************************************
   // The following parameters varies based on the pin out entered in MIG GUI.
   // Do not change any of these parameters directly by editing the RTL.
   // Any changes required should be done through GUI and the design regenerated.
   //***************************************************************************
   parameter C2_QDRIIP_BYTE_LANES_B0         = 4'b0011,
                                     // Byte lanes used in an IO column.
   parameter C2_QDRIIP_BYTE_LANES_B1         = 4'b1111,
                                     // Byte lanes used in an IO column.
   parameter C2_QDRIIP_BYTE_LANES_B2         = 4'b1111,
                                     // Byte lanes used in an IO column.
   parameter C2_QDRIIP_BYTE_LANES_B3         = 4'b0000,
                                     // Byte lanes used in an IO column.
   parameter C2_QDRIIP_BYTE_LANES_B4         = 4'b0000,
                                     // Byte lanes used in an IO column.
   parameter C2_QDRIIP_DATA_CTL_B0           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C2_QDRIIP_DATA_CTL_B1           = 4'b1111,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C2_QDRIIP_DATA_CTL_B2           = 4'b1111,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C2_QDRIIP_DATA_CTL_B3           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter C2_QDRIIP_DATA_CTL_B4           = 4'b0000,
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
   parameter C2_QDRIIP_CPT_CLK_SEL_B0  = 32'h00_00_00_00,
   parameter C2_QDRIIP_CPT_CLK_SEL_B1  = 32'h00_00_00_00,
   parameter C2_QDRIIP_CPT_CLK_SEL_B2  = 32'h11_11_21_21,

   parameter C2_QDRIIP_PHY_0_BITLANES       = 48'h000_000_FFF_FF8,
                                     // The bits used inside the Bank0 out of 48 pins.
   parameter C2_QDRIIP_PHY_1_BITLANES       = 48'h3FE_FFD_1FF_EFF,
                                     // The bits used inside the Bank1 out of 48 pins.
   parameter C2_QDRIIP_PHY_2_BITLANES       = 48'hFF8_FF1_D3F_EFC,
                                     // The bits used inside the Bank2 out of 48 pins.
   parameter C2_QDRIIP_PHY_3_BITLANES       = 48'h000_000_000_000,
                                     // The bits used inside the Bank3 out of 48 pins.
   parameter C2_QDRIIP_PHY_4_BITLANES       = 48'h000_000_000_000,
                                     // The bits used inside the Bank4 out of 48 pins.

   // Differentiates the INPUT and OUTPUT bytelates (1-input, 0-output)
   parameter C2_QDRIIP_BYTE_GROUP_TYPE_B0 = 4'b0000,
   parameter C2_QDRIIP_BYTE_GROUP_TYPE_B1 = 4'b0000,
   parameter C2_QDRIIP_BYTE_GROUP_TYPE_B2 = 4'b1111,
   parameter C2_QDRIIP_BYTE_GROUP_TYPE_B3 = 4'b0000,
   parameter C2_QDRIIP_BYTE_GROUP_TYPE_B4 = 4'b0000,

   // mapping for K/K# clocks. This parameter needs to have an 8-bit value per component
   // since the phy drives a K/K# clock pair to each memory it interfaces to. A 3 component
   // interface is supported for now. This parameter needs to be used in conjunction with
   // NUM_DEVICES parameter which provides information on the number. of components being
   // interfaced to.
   // the 8 bit for each component is defined as follows:
   // [7:4] - bank number ; [3:0] - byte lane number
   parameter C2_QDRIIP_K_MAP = 48'h00_00_00_00_11_13,

   // mapping for CQ/CQ# clocks. This parameter needs to have an 4-bit value per component
   // since the phy drives a CQ/CQ# clock pair to each memory it interfaces to. A 3 component
   // interface is supported for now. This parameter needs to be used in conjunction with
   // NUM_DEVICES parameter which provides information on the number. of components being
   // interfaced to.
   // the 4 bit for each component is defined as follows:
   // [3:0] - bank number
   parameter C2_QDRIIP_CQ_MAP = 48'h00_00_00_00_11_21,

   //**********************************************************************************************
   // Each of the following parameter contains the byte_lane and bit position information for
   // the address/control, data write and data read signals. Each bit has 12 bits and the details are
   // [3:0] - Bit position within a byte lane .
   // [7:4] - Byte lane position within a bank. [5:4] have the byte lane position and others reserved.
   // [11:8] - Bank position. [10:8] have the bank position. [11] tied to zero .
   //**********************************************************************************************

   // Mapping for address and control signals.

   parameter C2_QDRIIP_RD_MAP = 12'h003,      // Mapping for read enable signal
   parameter C2_QDRIIP_WR_MAP = 12'h004,      // Mapping for write enable signal

   // Mapping for address signals. Supports upto 22 bits of address bits (22*12)
   parameter C2_QDRIIP_ADD_MAP = 264'h000_000_000_019_018_017_016_01B_01A_015_014_013_012_011_010_009_008_007_006_00B_00A_005,

   // Mapping for the byte lanes used for address/control signals. Supports a maximum of 3 banks.
   parameter C2_QDRIIP_ADDR_CTL_MAP = 24'h00_00_01,

   // Mapping for data WRITE signals

   // Mapping for data write bytes (9*12)
   parameter C2_QDRIIP_D0_MAP  = 108'h131_132_133_134_135_136_137_138_139, //byte 0
   parameter C2_QDRIIP_D1_MAP  = 108'h120_122_123_124_125_12A_12B_126_127, //byte 1
   parameter C2_QDRIIP_D2_MAP  = 108'h110_111_112_113_114_115_116_117_118, //byte 2
   parameter C2_QDRIIP_D3_MAP  = 108'h100_101_102_103_104_105_10A_10B_106, //byte 3
   parameter C2_QDRIIP_D4_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 4
   parameter C2_QDRIIP_D5_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 5
   parameter C2_QDRIIP_D6_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 6
   parameter C2_QDRIIP_D7_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 7

   // Mapping for byte write signals (8*12)
   parameter C2_QDRIIP_BW_MAP = 84'h000_000_000_107_109_128_129,

   // Mapping for data READ signals

   // Mapping for data read bytes (9*12)
   parameter C2_QDRIIP_Q0_MAP  = 108'h233_234_235_23A_23B_236_237_238_239, //byte 0
   parameter C2_QDRIIP_Q1_MAP  = 108'h220_224_225_22A_22B_226_227_228_229, //byte 1
   parameter C2_QDRIIP_Q2_MAP  = 108'h210_211_212_213_214_215_21A_21B_218, //byte 2
   parameter C2_QDRIIP_Q3_MAP  = 108'h202_203_204_205_20A_20B_206_207_209, //byte 3
   parameter C2_QDRIIP_Q4_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 4
   parameter C2_QDRIIP_Q5_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 5
   parameter C2_QDRIIP_Q6_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 6
   parameter C2_QDRIIP_Q7_MAP  = 108'h000_000_000_000_000_000_000_000_000, //byte 7

   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   parameter C2_QDRIIP_IODELAY_HP_MODE       = "ON",
                                     // to phy_top
   parameter C2_QDRIIP_IBUF_LPWR_MODE        = "OFF",
                                     // to phy_top
   parameter C2_QDRIIP_TCQ                   = 100,
   

   
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter C2_QDRIIP_CLK_PERIOD            = 2000,
                                     // memory tCK paramter.
                                     // # = Clock Period in pS.
   parameter C2_QDRIIP_nCK_PER_CLK           = 2,
                                     // # of memory CKs per fabric CLK
   parameter C2_QDRIIP_DIFF_TERM_SYSCLK      = "FALSE",
                                     // Differential Termination for System
                                     // clock input pins

      //***************************************************************************
   // Traffic Gen related parameters
   //***************************************************************************
   parameter C2_QDRIIP_BL_WIDTH              = 8,
   parameter C2_QDRIIP_PORT_MODE             = "BI_MODE",
   parameter C2_QDRIIP_DATA_MODE             = 4'b0010,
   parameter C2_QDRIIP_EYE_TEST              = "FALSE",
                                     // set EYE_TEST = "TRUE" to probe memory
                                     // signals. Traffic Generator will only
                                     // write to one single location and no
                                     // read transactions will be generated.
   parameter C2_QDRIIP_DATA_PATTERN          = "DGEN_ALL",
                                      // "DGEN_HAMMER", "DGEN_WALKING1",
                                      // "DGEN_WALKING0","DGEN_ADDR","
                                      // "DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"
   parameter C2_QDRIIP_CMD_PATTERN           = "CGEN_ALL",
                                      // "CGEN_PRBS","CGEN_FIXED","CGEN_BRAM",
                                      // "CGEN_SEQUENTIAL", "CGEN_ALL"
   parameter C2_QDRIIP_CMD_WDT               = 'h3FF,
   parameter C2_QDRIIP_WR_WDT                = 'h1FFF,
   parameter C2_QDRIIP_RD_WDT                = 'h3FF,
   parameter C2_QDRIIP_BEGIN_ADDRESS         = 32'h00000000,
   parameter C2_QDRIIP_END_ADDRESS           = 32'h00000fff,
   parameter C2_QDRIIP_PRBS_EADDR_MASK_POS   = 32'hfffff000,

   //***************************************************************************
   // Wait period for the read strobe (CQ) to become stable
   //***************************************************************************
   parameter C2_QDRIIP_CLK_STABLE            = (20*1000*1000/(C2_QDRIIP_CLK_PERIOD*2)),
                                     // Cycles till CQ/CQ# is stable

   //***************************************************************************
   // Debug parameter
   //***************************************************************************
   parameter C2_QDRIIP_DEBUG_PORT            = "OFF",
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
      
   parameter RST_ACT_LOW           = 1
                                     // =1 for active low reset,
                                     // =0 for active high.
   )
  (

   // Inouts
   inout [C0_DDR3_DQ_WIDTH-1:0]                         c0_ddr3_dq,
   inout [C0_DDR3_DQS_WIDTH-1:0]                        c0_ddr3_dqs_n,
   inout [C0_DDR3_DQS_WIDTH-1:0]                        c0_ddr3_dqs_p,

   // Outputs
   output [C0_DDR3_ROW_WIDTH-1:0]                       c0_ddr3_addr,
   output [C0_DDR3_BANK_WIDTH-1:0]                      c0_ddr3_ba,
   output                                       c0_ddr3_ras_n,
   output                                       c0_ddr3_cas_n,
   output                                       c0_ddr3_we_n,
   output                                       c0_ddr3_reset_n,
   output [C0_DDR3_CK_WIDTH-1:0]                        c0_ddr3_ck_p,
   output [C0_DDR3_CK_WIDTH-1:0]                        c0_ddr3_ck_n,
   output [C0_DDR3_CKE_WIDTH-1:0]                       c0_ddr3_cke,
   output [C0_DDR3_CS_WIDTH*C0_DDR3_nCS_PER_RANK-1:0]           c0_ddr3_cs_n,
   output [C0_DDR3_DM_WIDTH-1:0]                        c0_ddr3_dm,
   output [C0_DDR3_ODT_WIDTH-1:0]                       c0_ddr3_odt,

   // Inputs
   // Differential system clocks
   input                                        c0_sys_clk_p,
   input                                        c0_sys_clk_n,
   // differential iodelayctrl clk (reference clock)
   input                                        clk_ref_p,
   input                                        clk_ref_n,
   
   output                                       tg_compare_error,
   output                                       init_calib_complete,
   
      // Differential system clocks
   input                                        c1_sys_clk_p,
   input                                        c1_sys_clk_n,
   input       [C1_QDRIIP_NUM_DEVICES-1:0]     c1_qdriip_cq_p,     //Memory Interface
   input       [C1_QDRIIP_NUM_DEVICES-1:0]     c1_qdriip_cq_n,
   input       [C1_QDRIIP_DATA_WIDTH-1:0]      c1_qdriip_q,
   output wire [C1_QDRIIP_NUM_DEVICES-1:0]     c1_qdriip_k_p,
   output wire [C1_QDRIIP_NUM_DEVICES-1:0]     c1_qdriip_k_n,
   output wire [C1_QDRIIP_DATA_WIDTH-1:0]      c1_qdriip_d,
   output wire [C1_QDRIIP_ADDR_WIDTH-1:0]      c1_qdriip_sa,
   output wire                       c1_qdriip_w_n,
   output wire                       c1_qdriip_r_n,
   output wire [C1_QDRIIP_BW_WIDTH-1:0]        c1_qdriip_bw_n,
   output wire                       c1_qdriip_dll_off_n,
   
   
   
      // Differential system clocks
   input                                        c2_sys_clk_p,
   input                                        c2_sys_clk_n,
   input       [C2_QDRIIP_NUM_DEVICES-1:0]     c2_qdriip_cq_p,     //Memory Interface
   input       [C2_QDRIIP_NUM_DEVICES-1:0]     c2_qdriip_cq_n,
   input       [C2_QDRIIP_DATA_WIDTH-1:0]      c2_qdriip_q,
   output wire [C2_QDRIIP_NUM_DEVICES-1:0]     c2_qdriip_k_p,
   output wire [C2_QDRIIP_NUM_DEVICES-1:0]     c2_qdriip_k_n,
   output wire [C2_QDRIIP_DATA_WIDTH-1:0]      c2_qdriip_d,
   output wire [C2_QDRIIP_ADDR_WIDTH-1:0]      c2_qdriip_sa,
   output wire                       c2_qdriip_w_n,
   output wire                       c2_qdriip_r_n,
   output wire [C2_QDRIIP_BW_WIDTH-1:0]        c2_qdriip_bw_n,
   output wire                       c2_qdriip_dll_off_n,
   
   
   
      

   // System reset - Default polarity of sys_rst pin is Active Low.
   // System reset polarity will change based on the option 
   // selected in GUI.
   input                                        sys_rst
   );

endmodule
