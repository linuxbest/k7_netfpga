-------------------------------------------------------------------------------
-- axi_ethernetlite - entity/architecture pair
-------------------------------------------------------------------------------
--  ***************************************************************************
--  ** DISCLAIMER OF LIABILITY                                               **
--  **                                                                       **
--  **  This file contains proprietary and confidential information of       **
--  **  Xilinx, Inc. ("Xilinx"), that is distributed under a license         **
--  **  from Xilinx, and may be used, copied and/or disclosed only           **
--  **  pursuant to the terms of a valid license agreement with Xilinx.      **
--  **                                                                       **
--  **  XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION                **
--  **  ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER           **
--  **  EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                  **
--  **  LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,            **
--  **  MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx        **
--  **  does not warrant that functions included in the Materials will       **
--  **  meet the requirements of Licensee, or that the operation of the      **
--  **  Materials will be uninterrupted or error-free, or that defects       **
--  **  in the Materials will be corrected. Furthermore, Xilinx does         **
--  **  not warrant or make any representations regarding use, or the        **
--  **  results of the use, of the Materials in terms of correctness,        **
--  **  accuracy, reliability or otherwise.                                  **
--  **                                                                       **
--  **  Xilinx products are not designed or intended to be fail-safe,        **
--  **  or for use in any application requiring fail-safe performance,       **
--  **  such as life-support or safety devices or systems, Class III         **
--  **  medical devices, nuclear facilities, applications related to         **
--  **  the deployment of airbags, or any other applications that could      **
--  **  lead to death, personal injury or severe property or                 **
--  **  environmental damage (individually and collectively, "critical       **
--  **  applications"). Customer assumes the sole risk and liability         **
--  **  of any use of Xilinx products in critical applications,              **
--  **  subject only to applicable laws and regulations governing            **
--  **  limitations on product liability.                                    **
--  **                                                                       **
--  **  Copyright 2010 Xilinx, Inc.                                          **
--  **  All rights reserved.                                                 **
--  **                                                                       **
--  **  This disclaimer and copyright notice must be retained as part        **
--  **  of this file at all times.                                           **
--  ***************************************************************************
-------------------------------------------------------------------------------
-- Filename     : axi_ethernetlite.vhd
-- Version      : v1.00.a
-- Description  : This is the top level wrapper file for the Ethernet
--                Lite function It provides a 10 or 100 Mbs full or half 
--                duplex Ethernet bus with an interface to an AXI Interface.               
-- VHDL-Standard: VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--
--  axi_ethernetlite.vhd
--      \
--      \-- axi_interface.vhd
--      \-- xemac.vhd
--           \
--           \-- mdio_if.vhd
--           \-- emac_dpram.vhd                     
--           \    \                     
--           \    \-- RAMB16_S4_S36
--           \                          
--           \    
--           \-- emac.vhd                     
--                \                     
--                \-- MacAddrRAM                   
--                \-- receive.vhd
--                \      rx_statemachine.vhd
--                \      rx_intrfce.vhd
--                \         async_fifo_fg.vhd
--                \      crcgenrx.vhd
--                \                     
--                \-- transmit.vhd
--                       crcgentx.vhd
--                          crcnibshiftreg
--                       tx_intrfce.vhd
--                          async_fifo_fg.vhd
--                       tx_statemachine.vhd
--                       deferral.vhd
--                          cntr5bit.vhd
--                          defer_state.vhd
--                       bocntr.vhd
--                          lfsr16.vhd
--                       msh_cnt.vhd
--                       ld_arith_reg.vhd
--
-------------------------------------------------------------------------------
-- Author:    PVK
-- History:    
-- PVK        06/07/2010     First Version
-- ^^^^^^
-- First version.  
-- ~~~~~~
-- PVK        07/29/2010     First Version
-- ^^^^^^
-- Removed ARLOCK and AWLOCK, AWPROT, ARPROT signals from the list.
-- ~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                                "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_com" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- axi_ethernetlite_v1_01_b library is used for axi_ethernetlite_v1_01_b 
-- component declarations
-------------------------------------------------------------------------------
library axi_ethernetlite_v1_01_b;
use axi_ethernetlite_v1_01_b.mac_pkg.all;
use axi_ethernetlite_v1_01_b.axi_interface;
use axi_ethernetlite_v1_01_b.all;

-------------------------------------------------------------------------------
-- proc common package of the proc common library is used for different 
-- function declarations
-------------------------------------------------------------------------------
library proc_common_v3_00_a;
use proc_common_v3_00_a.all;

-------------------------------------------------------------------------------
-- Vcomponents from unisim library is used for FIFO instatiation
-- function declarations
-------------------------------------------------------------------------------
library unisim;
use unisim.Vcomponents.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
-------------------------------------------------------------------------------
-- 
-- C_FAMILY                    -- Target device family 
-- C_S_AXI_ACLK_PERIOD_PS      -- The period of the AXI clock in ps
-- C_S_AXI_ADDR_WIDTH          -- AXI address bus width - allowed value - 32 only
-- C_S_AXI_DATA_WIDTH          -- AXI data bus width - allowed value - 32 or 64 only
-- C_S_AXI_ID_WIDTH            -- AXI Identification TAG width - 1 to 16
-- C_S_AXI_PROTOCOL            -- AXI protocol type
--              
-- C_DUPLEX                    -- 1 = Full duplex, 0 = Half duplex
-- C_TX_PING_PONG              -- 1 = Ping-pong memory used for transmit buffer
--                                0 = Pong memory not used for transmit buffer 
-- C_RX_PING_PONG              -- 1 = Ping-pong memory used for receive buffer
--                                0 = Pong memory not used for receive buffer 
-- C_INCLUDE_MDIO              -- 1 = Include MDIO Innterface, 
--                                0 = No MDIO Interface
-- C_INCLUDE_INTERNAL_LOOPBACK -- 1 = Include Internal Loopback logic, 
--                                0 = Internal Loopback logic disabled
-- C_INCLUDE_GLOBAL_BUFFERS    -- 1 = Include global buffers for PHY clocks
--                                0 = Use normal input buffers for PHY clocks
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Ports:
--
-- S_AXI_ACLK            -- AXI Clock
-- S_AXI_ARESETN          -- AXI Reset - active low
-- -- Interrupts           
-- IP2INTC_Irpt       -- Interrupt to processor
--==================================
-- AXI Write Address Channel Signals
--==================================
-- S_AXI_AWID            -- AXI Write Address ID
-- S_AXI_AWADDR          -- AXI Write address - 32 bit
-- S_AXI_AWLEN           -- AXI Write Data Length
-- S_AXI_AWSIZE          -- AXI Burst Size - allowed values
--                       -- 000 - byte burst
--                       -- 001 - half word
--                       -- 010 - word
--                       -- 011 - double word
--                       -- NA for all remaining values
-- S_AXI_AWBURST         -- AXI Burst Type
--                       -- 00  - Fixed
--                       -- 01  - Incr
--                       -- 10  - Wrap
--                       -- 11  - Reserved
-- S_AXI_AWCACHE         -- AXI Cache Type
-- S_AXI_AWVALID         -- Write address valid
-- S_AXI_AWREADY         -- Write address ready
--===============================
-- AXI Write Data Channel Signals
--===============================
-- S_AXI_WDATA           -- AXI Write data width
-- S_AXI_WSTRB           -- AXI Write strobes
-- S_AXI_WLAST           -- AXI Last write indicator signal
-- S_AXI_WVALID          -- AXI Write valid
-- S_AXI_WREADY          -- AXI Write ready
--================================
-- AXI Write Data Response Signals
--================================
-- S_AXI_BID             -- AXI Write Response channel number
-- S_AXI_BRESP           -- AXI Write response
--                       -- 00  - Okay
--                       -- 01  - ExOkay
--                       -- 10  - Slave Error
--                       -- 11  - Decode Error
-- S_AXI_BVALID          -- AXI Write response valid
-- S_AXI_BREADY          -- AXI Response ready
--=================================
-- AXI Read Address Channel Signals
--=================================
-- S_AXI_ARID            -- AXI Read ID
-- S_AXI_ARADDR          -- AXI Read address
-- S_AXI_ARLEN           -- AXI Read Data length
-- S_AXI_ARSIZE          -- AXI Read Size
-- S_AXI_ARBURST         -- AXI Read Burst length
-- S_AXI_ARCACHE         -- AXI Read Cache
-- S_AXI_ARPROT          -- AXI Read Protection
-- S_AXI_RVALID          -- AXI Read valid
-- S_AXI_RREADY          -- AXI Read ready
--==============================
-- AXI Read Data Channel Signals
--==============================
-- S_AXI_RID             -- AXI Read Channel ID
-- S_AXI_RDATA           -- AXI Read data
-- S_AXI_RRESP           -- AXI Read response
-- S_AXI_RLAST           -- AXI Read Data Last signal
-- S_AXI_RVALID          -- AXI Read address valid
-- S_AXI_RREADY          -- AXI Read address ready

--                 
-- -- Ethernet
-- PHY_tx_clk       -- Ethernet tranmit clock
-- PHY_rx_clk       -- Ethernet receive clock
-- PHY_crs          -- Ethernet carrier sense
-- PHY_dv           -- Ethernet receive data valid
-- PHY_rx_data      -- Ethernet receive data
-- PHY_col          -- Ethernet collision indicator
-- PHY_rx_er        -- Ethernet receive error
-- PHY_rst_n        -- Ethernet PHY Reset
-- PHY_tx_en        -- Ethernet transmit enable
-- PHY_tx_data      -- Ethernet transmit data
-- PHY_MDIO_I       -- Ethernet PHY MDIO data input 
-- PHY_MDIO_O       -- Ethernet PHY MDIO data output 
-- PHY_MDIO_T       -- Ethernet PHY MDIO data 3-state control
-- PHY_MDC          -- Ethernet PHY management clock
-------------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------
entity axi_ethernetlite is
  generic 
   (
    C_FAMILY                        : string := "virtex6";
    C_INSTANCE                      : string := "axi_ethernetlite_inst";
    C_S_AXI_ACLK_PERIOD_PS          : integer := 10000;
    C_S_AXI_ADDR_WIDTH              : integer := 13;
    C_S_AXI_DATA_WIDTH              : integer range 32 to 32 := 32;
    C_S_AXI_ID_WIDTH                : integer := 4;
    C_S_AXI_PROTOCOL                : string  := "AXI4";

    C_INCLUDE_MDIO                  : integer := 1; 
    C_INCLUDE_INTERNAL_LOOPBACK     : integer := 0; 
    C_INCLUDE_GLOBAL_BUFFERS        : integer := 0; 
    C_DUPLEX                        : integer range 0 to 1:= 1; 
    C_TX_PING_PONG                  : integer range 0 to 1:= 0;
    C_RX_PING_PONG                  : integer range 0 to 1:= 0
    );
  port 
    (

--  -- AXI Slave signals ------------------------------------------------------
--   -- AXI Global System Signals
       S_AXI_ACLK       : in  std_logic;
       S_AXI_ARESETN    : in  std_logic;
       IP2INTC_Irpt     : out std_logic;
       

--   -- AXI Slave Burst Interface
--   -- AXI Write Address Channel Signals
       S_AXI_AWID    : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
       S_AXI_AWADDR  : in  std_logic_vector(12 downto 0); -- (C_S_AXI_ADDR_WIDTH-1 downto 0);
       S_AXI_AWLEN   : in  std_logic_vector(7 downto 0);
       S_AXI_AWSIZE  : in  std_logic_vector(2 downto 0);
       S_AXI_AWBURST : in  std_logic_vector(1 downto 0);
       S_AXI_AWCACHE : in  std_logic_vector(3 downto 0);
       S_AXI_AWVALID : in  std_logic;
       S_AXI_AWREADY : out std_logic;

--   -- AXI Write Data Channel Signals
       S_AXI_WDATA   : in  std_logic_vector(31 downto 0); -- (C_S_AXI_DATA_WIDTH-1 downto 0);
       S_AXI_WSTRB   : in  std_logic_vector(3 downto 0);
                               --(((C_S_AXI_DATA_WIDTH/8)-1) downto 0);
       S_AXI_WLAST   : in  std_logic;
       S_AXI_WVALID  : in  std_logic;
       S_AXI_WREADY  : out std_logic;

--   -- AXI Write Response Channel Signals
       S_AXI_BID     : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
       S_AXI_BRESP   : out std_logic_vector(1 downto 0);
       S_AXI_BVALID  : out std_logic;
       S_AXI_BREADY  : in  std_logic;
--   -- AXI Read Address Channel Signals
       S_AXI_ARID    : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
       S_AXI_ARADDR  : in  std_logic_vector(12 downto 0); -- (C_S_AXI_ADDR_WIDTH-1 downto 0);
       S_AXI_ARLEN   : in  std_logic_vector(7 downto 0);
       S_AXI_ARSIZE  : in  std_logic_vector(2 downto 0);
       S_AXI_ARBURST : in  std_logic_vector(1 downto 0);
       S_AXI_ARCACHE : in  std_logic_vector(3 downto 0);
       S_AXI_ARVALID : in  std_logic;
       S_AXI_ARREADY : out std_logic;
       
--   -- AXI Read Data Channel Signals
       S_AXI_RID     : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
       S_AXI_RDATA   : out std_logic_vector(31 downto 0); -- (C_S_AXI_DATA_WIDTH-1 downto 0);
       S_AXI_RRESP   : out std_logic_vector(1 downto 0);
       S_AXI_RLAST   : out std_logic;
       S_AXI_RVALID  : out std_logic;
       S_AXI_RREADY  : in  std_logic;     


--   -- Ethernet Interface
       PHY_tx_clk        : in std_logic;
       PHY_rx_clk        : in std_logic;
       PHY_crs           : in std_logic;
       PHY_dv            : in std_logic;
       PHY_rx_data       : in std_logic_vector (3 downto 0);
       PHY_col           : in std_logic;
       PHY_rx_er         : in std_logic;
       PHY_rst_n         : out std_logic; 
       PHY_tx_en         : out std_logic;
       PHY_tx_data       : out std_logic_vector (3 downto 0);
       PHY_MDIO_I        : in  std_logic;
       PHY_MDIO_O        : out std_logic;
       PHY_MDIO_T        : out std_logic;
       PHY_MDC           : out std_logic   
    
    );
    
-- XST attributes    

-- Fan-out attributes for XST
attribute MAX_FANOUT                             : string;
attribute MAX_FANOUT of S_AXI_ACLK               : signal is "10000";
attribute MAX_FANOUT of S_AXI_ARESETN            : signal is "10000";


--Psfutil attributes
attribute ASSIGNMENT       :   string;
attribute ADDRESS          :   string; 
attribute PAIR             :   string; 

end axi_ethernetlite;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------  

architecture imp of axi_ethernetlite is

 --Parameters captured for webtalk
   -- C_FAMILY
   -- C_S_AXI_ACLK_PERIOD_PS
   -- C_S_AXI_DATA_WIDTH           
   -- C_S_AXI_PROTOCOL             
   -- C_INCLUDE_MDIO               
   -- C_INCLUDE_INTERNAL_LOOPBACK  
   -- C_INCLUDE_GLOBAL_BUFFERS     
   -- C_DUPLEX                      
   -- C_TX_PING_PONG               
   -- C_RX_PING_PONG               
 
   constant C_CORE_GENERATION_INFO : string := C_INSTANCE & ",axi_ethernetlite,{"
    & "c_family="                       & C_FAMILY
    & ",C_INSTANCE = "                  & C_INSTANCE
    & ",c_s_axi_protocol="              & C_S_AXI_PROTOCOL
    & ",c_s_axi_aclk_period_ps="        & integer'image(C_S_AXI_ACLK_PERIOD_PS) 
    & ",c_s_axi_data_width="            & integer'image(C_S_AXI_DATA_WIDTH)
    & ",c_include_mdio="                & integer'image(C_INCLUDE_MDIO)
    & ",c_include_internal_loopback="   & integer'image(C_INCLUDE_INTERNAL_LOOPBACK)
    & ",c_include_global_buffers="      & integer'image(C_INCLUDE_GLOBAL_BUFFERS)
    & ",c_duplex="                      & integer'image(C_DUPLEX)
    & ",c_tx_ping_pong="                & integer'image(C_TX_PING_PONG)
    & ",c_rx_ping_pong="                & integer'image(C_RX_PING_PONG)
    & "}";

    attribute CORE_GENERATION_INFO : string;
    attribute CORE_GENERATION_INFO of imp : architecture is C_CORE_GENERATION_INFO;

-------------------------------------------------------------------------------
--  Constant Declarations
-------------------------------------------------------------------------------
constant NODE_MAC : bit_vector := x"00005e00FACE";


-------------------------------------------------------------------------------
--   Signal declaration Section 
-------------------------------------------------------------------------------
signal phy_rx_clk_i    : std_logic;
signal phy_tx_clk_i    : std_logic;
signal phy_rx_data_i   : std_logic_vector(3 downto 0); 
signal phy_tx_data_i   : std_logic_vector(3 downto 0);
signal phy_dv_i        : std_logic;
signal phy_rx_er_i     : std_logic;
signal phy_tx_en_i     : std_logic;
signal Loopback        : std_logic;
signal phy_rx_data_in  : std_logic_vector (3 downto 0);
signal phy_dv_in       : std_logic;
signal phy_rx_data_reg : std_logic_vector(3 downto 0);
signal phy_rx_er_reg   : std_logic;
signal phy_dv_reg      : std_logic;

signal phy_tx_clk_core    : std_logic;
signal phy_rx_clk_core    : std_logic;

-- IPIC Signals
signal temp_Bus2IP_Addr: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal bus2ip_addr     : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal Bus2IP_Data     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal bus2ip_rdce     : std_logic;
signal bus2ip_wrce     : std_logic;
signal ip2bus_data     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal bus2ip_burst    : std_logic;
signal bus2ip_be       : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
signal bus_rst         : std_logic;
signal ip2bus_errack   : std_logic;


component FDRE
  port 
   (
    Q  : out std_logic;
    C  : in std_logic;
    CE : in std_logic;
    D  : in std_logic;
    R  : in std_logic
   );
end component;
  
component BUFG
  port (
     O  : out std_ulogic;
     I : in std_ulogic := '0'
  );
end component;

component BUFGMUX
  port (
     O  : out std_ulogic;
     I0 : in std_ulogic := '0';
     I1 : in std_ulogic := '0';
     S  : in std_ulogic
  );
end component;

component BUF 
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end component;

  attribute IOB         : string;  

begin -- this is the begin between declarations and architecture body


   -- PHY Reset
   PHY_rst_n   <= S_AXI_ARESETN ;

   -- Bus Reset
   bus_rst     <= not S_AXI_ARESETN ;


   ----------------------------------------------------------------------------
   -- LOOPBACK_GEN :- Include MDIO interface if the parameter 
   -- C_INCLUDE_INTERNAL_LOOPBACK = 1
   ----------------------------------------------------------------------------
   LOOPBACK_GEN: if C_INCLUDE_INTERNAL_LOOPBACK = 1 generate
   begin


      -------------------------------------------------------------------------
      -- INCLUDE_BUFG_GEN :- Include Global Buffer for PHY clocks 
      -- C_INCLUDE_GLOBAL_BUFFERS = 1
      -------------------------------------------------------------------------
      INCLUDE_BUFG_GEN: if C_INCLUDE_GLOBAL_BUFFERS = 1 generate
      begin
         -------------------------------------------------------------------------
         -- BUFG for TX clock
         -------------------------------------------------------------------------
         CLOCK_BUFG_TX: BUFG
           port map (
             O  => phy_tx_clk_core,  --[out]
             I  => PHY_tx_clk        --[in]
           );

      end generate INCLUDE_BUFG_GEN; 

      -------------------------------------------------------------------------
      -- NO_BUFG_GEN :- Dont include Global Buffer for PHY clocks 
      -- C_INCLUDE_GLOBAL_BUFFERS = 0
      -------------------------------------------------------------------------
      NO_BUFG_GEN: if C_INCLUDE_GLOBAL_BUFFERS = 0 generate
      begin

         phy_tx_clk_core  <= PHY_tx_clk;
      
      end generate NO_BUFG_GEN; 


      -------------------------------------------------------------------------
      -- BUFGMUX for clock muxing in Loopback mode
      -------------------------------------------------------------------------
      CLOCK_MUX: BUFGMUX
        port map (
          O  => phy_rx_clk_core, --[out]
          I0 => PHY_rx_clk,      --[in]
          I1 => phy_tx_clk_core, --[in]
          S  => Loopback         --[in]
        );

      -------------------------------------------------------------------------
      -- Internal Loopback generation logic
      -------------------------------------------------------------------------
      phy_rx_data_in <=  phy_tx_data_i when Loopback = '1' else
                         phy_rx_data_reg;
      
      phy_dv_in      <=  phy_tx_en_i   when Loopback = '1' else
                         phy_dv_reg;
      
      -- No receive error is generated in internal loopback
      phy_rx_er_i    <= '0' when Loopback = '1' else
                         phy_rx_er_reg;
      
      
                         
      -- Transmit and Receive clocks         
      phy_tx_clk_i <= not(phy_tx_clk_core);
      phy_rx_clk_i <= not(phy_rx_clk_core);
   
      -------------------------------------------------------------------------
      -- Registering RX signal 
      -------------------------------------------------------------------------
      DV_FF: FDR
        port map (
          Q  => phy_dv_i,             --[out]
          C  => phy_rx_clk_i,         --[in]
          D  => phy_dv_in,            --[in]
          R  => bus_rst);             --[in]
      
    
      -------------------------------------------------------------------------
      -- Registering RX data input with clock mux output
      -------------------------------------------------------------------------
      RX_REG_GEN: for i in 3 downto 0 generate
      begin
         RX_FF: FDRE
           port map (
             Q  => phy_rx_data_i(i),   --[out]
             C  => phy_rx_clk_i,       --[in]
             CE => '1',                --[in]
             D  => phy_rx_data_in(i),  --[in]
             R  => bus_rst);           --[in]
      
      end generate RX_REG_GEN;

   end generate LOOPBACK_GEN; 

   ----------------------------------------------------------------------------
   -- NO_LOOPBACK_GEN :- Include MDIO interface if the parameter 
   -- C_INCLUDE_INTERNAL_LOOPBACK = 0
   ----------------------------------------------------------------------------
   NO_LOOPBACK_GEN: if C_INCLUDE_INTERNAL_LOOPBACK = 0 generate
   begin


      -------------------------------------------------------------------------
      -- INCLUDE_BUFG_GEN :- Include Global Buffer for PHY clocks 
      -- C_INCLUDE_GLOBAL_BUFFERS = 1
      -------------------------------------------------------------------------
      INCLUDE_BUFG_GEN: if C_INCLUDE_GLOBAL_BUFFERS = 1 generate
      begin
         -------------------------------------------------------------------------
         -- BUFGMUX for clock muxing 
         -------------------------------------------------------------------------
         CLOCK_BUFG_TX: BUFG
           port map (
             O  => phy_tx_clk_core,  --[out]
             I  => PHY_tx_clk        --[in]
           );


         -------------------------------------------------------------------------
         -- BUFGMUX for clock muxing 
         -------------------------------------------------------------------------
         CLOCK_BUFG_RX: BUFG
           port map (
             O  => phy_rx_clk_core,  --[out]
             I  => PHY_rx_clk        --[in]
           );
      

      end generate INCLUDE_BUFG_GEN; 

      -------------------------------------------------------------------------
      -- NO_BUFG_GEN :- Dont include Global Buffer for PHY clocks 
      -- C_INCLUDE_GLOBAL_BUFFERS = 0
      -------------------------------------------------------------------------
      NO_BUFG_GEN: if C_INCLUDE_GLOBAL_BUFFERS = 0 generate
      begin

         phy_tx_clk_core  <= PHY_tx_clk;
         phy_rx_clk_core  <= PHY_rx_clk;
      
      end generate NO_BUFG_GEN; 



      -- Transmit and Receive clocks for core         
      phy_tx_clk_i  <= not(phy_tx_clk_core);
      phy_rx_clk_i  <= not(phy_rx_clk_core);
       
      -- TX/RX internal signals
      phy_rx_data_i <= phy_rx_data_reg;
      phy_rx_er_i   <= phy_rx_er_reg;
      phy_dv_i      <= phy_dv_reg;
      
      

   end generate NO_LOOPBACK_GEN; 


   ----------------------------------------------------------------------------
   -- Registering the Ethernet data signals
   ----------------------------------------------------------------------------   
   IOFFS_GEN: for i in 3 downto 0 generate
   attribute IOB of RX_FF_I : label is "true";
   attribute IOB of TX_FF_I : label is "true";
   begin
      RX_FF_I: FDRE
         port map (
            Q  => phy_rx_data_reg(i), --[out]
            C  => phy_rx_clk_core,    --[in]
            CE => '1',                --[in]
            D  => PHY_rx_data(i),     --[in]
            R  => bus_rst);           --[in]
            
      TX_FF_I: FDRE
         port map (
            Q  => PHY_tx_data(i),     --[out]
            C  => phy_tx_clk_core,    --[in]
            CE => '1',                --[in]
            D  => phy_tx_data_i(i),   --[in]
            R  => bus_rst);           --[in]
          
    end generate IOFFS_GEN;


   ----------------------------------------------------------------------------
   -- Registering the Ethernet control signals
   ----------------------------------------------------------------------------   
   IOFFS_GEN2: if(true) generate 
      attribute IOB of DVD_FF : label is "true";
      attribute IOB of RER_FF : label is "true";
      attribute IOB of TEN_FF : label is "true";
      begin
         DVD_FF: FDRE
           port map (
             Q  => phy_dv_reg,      --[out]
             C  => phy_rx_clk_core, --[in]
             CE => '1',             --[in]
             D  => PHY_dv,          --[in]
             R  => bus_rst);        --[in]
               
         RER_FF: FDRE
           port map (
             Q  => phy_rx_er_reg,   --[out]
             C  => phy_rx_clk_core, --[in]
             CE => '1',             --[in]
             D  => PHY_rx_er,       --[in]
             R  => bus_rst);        --[in]
               
         TEN_FF: FDRE
           port map (
             Q  => PHY_tx_en,       --[out]
             C  => phy_tx_clk_core, --[in]
             CE => '1',             --[in]
             D  => PHY_tx_en_i,     --[in]
             R  => bus_rst);        --[in]    
               
   end generate IOFFS_GEN2;
      
   ----------------------------------------------------------------------------
   -- XEMAC Module
   ----------------------------------------------------------------------------   
   XEMAC_I : entity axi_ethernetlite_v1_01_b.xemac
     generic map 
        (
        C_FAMILY                 => C_FAMILY,
        C_S_AXI_ADDR_WIDTH       => C_S_AXI_ADDR_WIDTH,  
        C_S_AXI_DATA_WIDTH       => C_S_AXI_DATA_WIDTH,                     
        C_S_AXI_ACLK_PERIOD_PS   => C_S_AXI_ACLK_PERIOD_PS,
        C_DUPLEX                 => C_DUPLEX,
        C_RX_PING_PONG           => C_RX_PING_PONG,
        C_TX_PING_PONG           => C_TX_PING_PONG,
        C_INCLUDE_MDIO           => C_INCLUDE_MDIO,
        NODE_MAC                 => NODE_MAC

        )
     
     port map 
        (   
        Clk       => S_AXI_ACLK,
        Rst       => bus_Rst,
        IP2INTC_Irpt   => IP2INTC_Irpt,


 
     -- Bus2IP Signals
        Bus2IP_Addr          => bus2ip_addr,
        Bus2IP_Data          => bus2ip_data,
        Bus2IP_BE            => bus2ip_be,
        Bus2IP_Burst         => bus2ip_burst,
        Bus2IP_RdCE          => bus2ip_rdce,
        Bus2IP_WrCE          => bus2ip_wrce,

     -- IP2Bus Signals
        IP2Bus_Data          => ip2bus_data,
        IP2Bus_Error         => ip2bus_errack,

     -- EMAC Signals
        PHY_tx_clk     => phy_tx_clk_i,
        PHY_rx_clk     => phy_rx_clk_i,
        PHY_crs        => PHY_crs,
        PHY_dv         => phy_dv_i,
        PHY_rx_data    => phy_rx_data_i,
        PHY_col        => PHY_col,
        PHY_rx_er      => phy_rx_er_i,
        PHY_tx_en      => PHY_tx_en_i,
        PHY_tx_data    => PHY_tx_data_i,
        PHY_MDIO_I     => PHY_MDIO_I,
        PHY_MDIO_O     => PHY_MDIO_O,
        PHY_MDIO_T     => PHY_MDIO_T,
        PHY_MDC        => PHY_MDC,
        Loopback       => Loopback 
        );
        
I_AXI_NATIVE_IPIF: entity axi_ethernetlite_v1_01_b.axi_interface
  generic map (
  
        C_S_AXI_ADDR_WIDTH          => C_S_AXI_ADDR_WIDTH,  
        C_S_AXI_DATA_WIDTH          => C_S_AXI_DATA_WIDTH,                     
        C_S_AXI_ID_WIDTH            => C_S_AXI_ID_WIDTH,
        C_S_AXI_PROTOCOL            => C_S_AXI_PROTOCOL,
        C_FAMILY                    => C_FAMILY

        )
  port map (  
            
          
        S_AXI_ACLK      =>  S_AXI_ACLK,
        S_AXI_ARESETN   =>  S_AXI_ARESETN,
        S_AXI_AWADDR    =>  S_AXI_AWADDR,
        S_AXI_AWID      =>  S_AXI_AWID,
        S_AXI_AWLEN     =>  S_AXI_AWLEN,
        S_AXI_AWSIZE    =>  S_AXI_AWSIZE,
        S_AXI_AWBURST   =>  S_AXI_AWBURST,
        S_AXI_AWCACHE   =>  S_AXI_AWCACHE,
        S_AXI_AWVALID   =>  S_AXI_AWVALID,
        S_AXI_AWREADY   =>  S_AXI_AWREADY,
        S_AXI_WDATA     =>  S_AXI_WDATA,
        S_AXI_WSTRB     =>  S_AXI_WSTRB,
        S_AXI_WLAST     =>  S_AXI_WLAST,
        S_AXI_WVALID    =>  S_AXI_WVALID,
        S_AXI_WREADY    =>  S_AXI_WREADY,
        S_AXI_BID       =>  S_AXI_BID,
        S_AXI_BRESP     =>  S_AXI_BRESP,
        S_AXI_BVALID    =>  S_AXI_BVALID,
        S_AXI_BREADY    =>  S_AXI_BREADY,
        S_AXI_ARID      =>  S_AXI_ARID,
        S_AXI_ARADDR    =>  S_AXI_ARADDR,                                       
        S_AXI_ARLEN     =>  S_AXI_ARLEN,                                        
        S_AXI_ARSIZE    =>  S_AXI_ARSIZE,                                       
        S_AXI_ARBURST   =>  S_AXI_ARBURST,                                      
        S_AXI_ARCACHE   =>  S_AXI_ARCACHE,                                      
        S_AXI_ARVALID   =>  S_AXI_ARVALID,
        S_AXI_ARREADY   =>  S_AXI_ARREADY,                                              
        S_AXI_RID       =>  S_AXI_RID,                                      
        S_AXI_RDATA     =>  S_AXI_RDATA,                                        
        S_AXI_RRESP     =>  S_AXI_RRESP,                                        
        S_AXI_RLAST     =>  S_AXI_RLAST,                                        
        S_AXI_RVALID    =>  S_AXI_RVALID,                                       
        S_AXI_RREADY    =>  S_AXI_RREADY,                                       
                                                                
            
-- IP Interconnect (IPIC) port signals ------------------------------------                                                     
      -- Controls to the IP/IPIF modules
            -- IP Interconnect (IPIC) port signals
        IP2Bus_Data     =>  ip2bus_data,
        IP2Bus_Error    =>  ip2bus_errack,
			    
        Bus2IP_Addr     =>  bus2ip_addr,
        Bus2IP_Data     =>  bus2ip_data,
        Bus2IP_BE       =>  bus2ip_be,
        Bus2IP_Burst    =>  bus2ip_burst,
        Bus2IP_RdCE     =>  bus2ip_rdce,
        Bus2IP_WrCE     =>  bus2ip_wrce
        ); 
        

------------------------------------------------------------------------------------------

end imp;
