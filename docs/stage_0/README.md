Hardware Features
=================
 - Xilinx Kirtex-7 XC7K325T-2FFG900I 
 - 4x SFP+ interface (using 4 GTX transeivers)
   - Supports both 10Gps and 1Gps modes
 - x8 PCI Express Gen1/2/3
 - Two x36 QDR II (CY7C1515KV18)
 - DDR3 SODIMM
 - RJ45 interface
 - 3/6Gps SAS/SATA (using 4 GTX transeivers)
 - ATX Power Connector
 - USB Mini RS232 (FT232R)

DDR3
====
 - Bank 32: DQ[32-63]
 - Bank 33: Address/ctrl
 - Bank 34: DQ[0-31]

QDR II #0
=========
 - Bank 16: D[0-35]
 - Bank 17: Address/ctrl (T0,T1)
 - Bank 18: Q[0-35]

QDR II #1 
=========
 - Bank 12: Q[0-35]
 - Bank 15: Address/ctrl (T2,T3)
 - Bank 13: D[0-35]

FPGA Banks
===========
 #. Bank 12 - QDR II #1 Q[0-35]
 #. Bank 13 - QDR II #1 D[0-35]
 #. Bank 14 - (HR) Configuration Flash
 #. Bank 15 - (HR) GPIO, GCLK, QDR II #1 [Address/ctrl]
 #. Bank 16 - QDR II #0 D[0-35]
 #. Bank 17 - QDR II #0 [Address/ctrl], GCLK, Ethernet
 #. Bank 18 - QDR II #0 Q[0-35]
 #. Bank 32 - DDR3 DQ[32-63]
 #. Bank 33 - DDR3 DQ[Address/ctrl]
 #. Bank 34 - DDR3 DQ[0-31]

