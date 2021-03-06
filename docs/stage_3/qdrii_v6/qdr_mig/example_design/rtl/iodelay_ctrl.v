//*****************************************************************************
//(c) Copyright 2006 - 2009 Xilinx, Inc. All rights reserved.
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
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version:3.92 
//  \   \         Application: MIG
//  /   /         Filename: iodelay_ctrl.v
// /___/   /\     Date Last Modified: $date$
// \   \  /  \    Date Created: Nov 19, 2008
//  \___\/\___\
//
//Device: Virtex-6
//Design Name: QDRII+ /RLDRAM-II
//Purpose:
//   This module instantiates the IDELAYCTRL primitive of the Virtex-5 device
//   which continously calibrates the IODELAY elements in the region in case of
//   varying operating conditions. It takes a 200MHz clock as an input
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ps/1ps

module iodelay_ctrl #(
   parameter IODELAY_GRP    = "IODELAY_MIG",  // May be assigned unique name when
                                              // multiple IP cores used in design
   parameter INPUT_CLK_TYPE = "DIFFERENTIAL", // input clock type 
                                              // "DIFFERENTIAL","SINGLE_ENDED"
   parameter RST_ACT_LOW    = 1,              //sys reset is active low
   parameter TCQ            = 100               
 )
(
   input  sys_rst,
   input  clk_ref_p,
   input  clk_ref_n,
   input  clk_ref,
   output iodelay_ctrl_rdy
);
  localparam RST_SYNC_NUM = 5;

  //Wire Declarations
  wire clk_ref_ibufg;
  wire clk_ref_bufg;
  wire rst_clkref_tmp;
  (* shreg_extract = "no" *)
  wire rst_clkref;
  wire sys_rst_act_hi;

  reg [RST_SYNC_NUM-1:0]  rst_clkref_sync_r  = -1;

  assign sys_rst_act_hi   = RST_ACT_LOW ? ~sys_rst: sys_rst;
  assign rst_clkref_tmp   = sys_rst_act_hi;

  generate
    if(INPUT_CLK_TYPE == "DIFFERENTIAL") begin : DIFF_ENDED_CLKS_INST
    //***************************************************************************
    // Differential input clock input buffers
    //***************************************************************************
    IBUFGDS IDLY_CLK_INST
      (
       .I (clk_ref_p),
       .IB(clk_ref_n),
       .O (clk_ref_ibufg)
       );

   end else if(INPUT_CLK_TYPE == "SINGLE_ENDED") begin : SINGLE_ENDED_CLKS_INST
    //**************************************************************************
    // Single ended input clock input buffers
    //**************************************************************************
    IBUFG IDLY_CLK_INST
      (
       .I (clk_ref),
       .O (clk_ref_ibufg)
       );
   end else if(INPUT_CLK_TYPE == "NO_BUFFER") begin : NO_BUFFER_ENDED_CLKS_INST
     assign clk_ref_ibufg = clk_ref;
    end
  endgenerate

  //***************************************************************************
  // IDELAYCTRL reference clock
  //***************************************************************************

  BUFG u_bufg_clk_ref
    (
     .I (clk_ref_ibufg),
     .O (clk_ref_bufg)
     );  

  (* IODELAY_GROUP = IODELAY_GRP *)IDELAYCTRL u_idelayctrl (
    .RDY      (iodelay_ctrl_rdy),
    .REFCLK   (clk_ref_bufg),
    .RST      (rst_clkref)
  );

  // make sure CLK200 doesn't depend on IODELAY_CTRL_RDY, else chicken n' egg
  always @(posedge clk_ref_bufg or posedge rst_clkref_tmp)
    if (rst_clkref_tmp)
      rst_clkref_sync_r <= #TCQ {RST_SYNC_NUM{1'b1}};
    else
      rst_clkref_sync_r <= #TCQ rst_clkref_sync_r << 1;

  assign rst_clkref = rst_clkref_sync_r[RST_SYNC_NUM-1];

endmodule
