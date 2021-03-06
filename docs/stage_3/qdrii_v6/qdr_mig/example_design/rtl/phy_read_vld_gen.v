//*****************************************************************************
//(c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
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

////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 3.92 
//  \   \         Application        : MIG
//  /   /         Filename           : phy_read_vld_gen.v
// /___/   /\     Date Last Modified : $date$
// \   \  /  \    Date Created       : Nov 19, 2008 
//  \___\/\___\
//
//Device: Virtex-6
//Design: QDRII+ / RLDRAM-II
//
//Purpose:
//  This module
//  1. Generates the valid signals for the read data sent to the user interface.
//  2. The valids are generated by delaying the incoming read commands from the
//     write path by some amount determined by the latency calibration.
//
//Revision History:
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module phy_read_vld_gen #
(
  parameter BURST_LEN = 4,  // 4 = Burst Length 4, 2 = Burst Length 2
  parameter TCQ       = 100 // Register delay
)
(
  // System Signals
  input       clk,            // main system half freq clk
  input       rst_clk,        // reset syncrhonized to clk

  // Write Interface
  input [1:0] int_rd_cmd_n,   // read command(s) - only bit 0 is used for BL4

  // Stage 2 Calibration Interface
  input [4:0] valid_latency,  // amount to delay read command
  input       cal_done,       // indicates calibration is complete

  // User Interface
  output reg  data_valid0,    // data valid for read data 0
  output reg  data_valid1,    // data valid for read data 1
  
  // ChipScope Debug Signals
  output [4:0] dbg_valid_lat
);

  wire data_valid0_int;
  wire data_valid1_int;
  
  reg data_valid0_int_r;
  reg data_valid1_int_r;

  
  // Delay the incoming rd_cmd0 by valid_latency number of cycles in order to
  // generate the data valid for read data 0
  SRLC32E vld_gen_srl0_inst (
    .Q    (data_valid0_int),
    .Q31  ( ),
    .A    (valid_latency),
    .CE   (1'b1),
    .CLK  (clk),
    .D    (~int_rd_cmd_n[0])
  );
  
  always @(posedge clk)
  begin
    data_valid0_int_r <=#TCQ data_valid0_int;
  end

  // Only issue valids after calibration has completed
  always @(posedge clk) begin
    if (rst_clk)
      data_valid0 <= #TCQ 0;
    else if (BURST_LEN==8)
      data_valid0 <= #TCQ (data_valid0_int | data_valid0_int_r) && cal_done;
    else
      data_valid0 <= #TCQ data_valid0_int && cal_done;
  end

  // Delay the incoming rd_cmd1 by valid_latency number of cycles in order to
  // generate the data valid for read data 1
  SRLC32E vld_gen_srl1_inst (
    .Q    (data_valid1_int),
    .Q31  ( ),
    .A    (valid_latency),
    .CE   (1'b1),
    .CLK  (clk),
    .D    (~int_rd_cmd_n[1])
  );
  
  always @(posedge clk)
  begin
    data_valid1_int_r <=#TCQ data_valid1_int;
  end


  // Only issue valids after calibration has completed
  always @(posedge clk) begin
    if (rst_clk)
      data_valid1 <= #TCQ 0;
    else if (BURST_LEN==8)
      data_valid1 <= #TCQ (data_valid1_int | data_valid1_int_r) && cal_done;
    else
      data_valid1 <= #TCQ data_valid1_int && cal_done;
  end

  // Assign debug signals
  assign dbg_valid_lat = valid_latency;

endmodule
