///////////////////////////////////////////////////////////////////////////////////////////
//  Copyright (c) 2009 Xilinx, Inc.
//
//   ____  ____
//  /   /\/   /
// /___/  \  /   This   document  contains  proprietary information  which   is
// \   \   \/    protected by  copyright. All rights  are reserved. No  part of
//  \   \        this  document may be photocopied, reproduced or translated to
//  /   /        another  program  language  without  prior written  consent of
// /___/   /\    XILINX Inc., San Jose, CA. 95125                              
// \   \  /  \ 
//  \___\/\___\
// 
//  Xilinx Template Revision:
//   $RCSfile: example_prime_top.ejava,v $
//   $Revision: 1.8 $
//   Modify $Date: 2012/09/21 11:25:54 $
//   Application : Virtex-6 IBERT
//   Version : 1.3
//
//  Description:
//   This file is an example top wrapper for the ibert design with the required
//   clock buffers. User logic can be instantiated in this wrapper along with 
//   the ibert design.
//

`timescale 1ns / 1ps
//***************************** Module ****************************
module example_chipscope_ibert
  (
  //Input Declarations
  input IBERT_SYSCLOCK_P_IPAD,
  input X0Y0_RX_P_IPAD,
  input X0Y0_RX_N_IPAD,
  input X0Y1_RX_P_IPAD,
  input X0Y1_RX_N_IPAD,
  input X0Y2_RX_P_IPAD,
  input X0Y2_RX_N_IPAD,
  input X0Y3_RX_P_IPAD,
  input X0Y3_RX_N_IPAD,
  input X0Y4_RX_P_IPAD,
  input X0Y4_RX_N_IPAD,
  input X0Y5_RX_P_IPAD,
  input X0Y5_RX_N_IPAD,
  input X0Y6_RX_P_IPAD,
  input X0Y6_RX_N_IPAD,
  input X0Y7_RX_P_IPAD,
  input X0Y7_RX_N_IPAD,
  input X0Y8_RX_P_IPAD,
  input X0Y8_RX_N_IPAD,
  input X0Y9_RX_P_IPAD,
  input X0Y9_RX_N_IPAD,
  input X0Y10_RX_P_IPAD,
  input X0Y10_RX_N_IPAD,
  input X0Y11_RX_P_IPAD,
  input X0Y11_RX_N_IPAD,
  input X0Y12_RX_P_IPAD,
  input X0Y12_RX_N_IPAD,
  input X0Y13_RX_P_IPAD,
  input X0Y13_RX_N_IPAD,
  input X0Y14_RX_P_IPAD,
  input X0Y14_RX_N_IPAD,
  input X0Y15_RX_P_IPAD,
  input X0Y15_RX_N_IPAD,
  input Q0_CLK0_MGTREFCLK_P_IPAD,
  input Q0_CLK0_MGTREFCLK_N_IPAD,
  input Q0_CLK1_MGTREFCLK_P_IPAD,
  input Q0_CLK1_MGTREFCLK_N_IPAD,
  input Q2_CLK1_MGTREFCLK_P_IPAD,
  input Q2_CLK1_MGTREFCLK_N_IPAD,
  input Q3_CLK1_MGTREFCLK_P_IPAD,
  input Q3_CLK1_MGTREFCLK_N_IPAD,
  //Output Decalarations
  output X0Y0_TX_P_OPAD,
  output X0Y0_TX_N_OPAD,
  output X0Y1_TX_P_OPAD,
  output X0Y1_TX_N_OPAD,
  output X0Y2_TX_P_OPAD,
  output X0Y2_TX_N_OPAD,
  output X0Y3_TX_P_OPAD,
  output X0Y3_TX_N_OPAD,
  output X0Y4_TX_P_OPAD,
  output X0Y4_TX_N_OPAD,
  output X0Y5_TX_P_OPAD,
  output X0Y5_TX_N_OPAD,
  output X0Y6_TX_P_OPAD,
  output X0Y6_TX_N_OPAD,
  output X0Y7_TX_P_OPAD,
  output X0Y7_TX_N_OPAD,
  output X0Y8_TX_P_OPAD,
  output X0Y8_TX_N_OPAD,
  output X0Y9_TX_P_OPAD,
  output X0Y9_TX_N_OPAD,
  output X0Y10_TX_P_OPAD,
  output X0Y10_TX_N_OPAD,
  output X0Y11_TX_P_OPAD,
  output X0Y11_TX_N_OPAD,
  output X0Y12_TX_P_OPAD,
  output X0Y12_TX_N_OPAD,
  output X0Y13_TX_P_OPAD,
  output X0Y13_TX_N_OPAD,
  output X0Y14_TX_P_OPAD,
  output X0Y14_TX_N_OPAD,
  output X0Y15_TX_P_OPAD,
  output X0Y15_TX_N_OPAD
  );
endmodule
