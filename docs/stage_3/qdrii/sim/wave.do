if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"top"}
eval add wave -noupdate $binopt /tb${ps}sys_clk
eval add wave -noupdate $binopt /tb${ps}sys_rst

eval add wave -noupdate $binopt /tb${ps}qdriip_k_p
eval add wave -noupdate $binopt /tb${ps}qdriip_k_n

eval add wave -noupdate $binopt /tb${ps}qdriip_r_n
eval add wave -noupdate $binopt /tb${ps}qdriip_w_n

eval add wave -noupdate $hexopt /tb${ps}qdriip_bw_n
eval add wave -noupdate $hexopt /tb${ps}qdriip_sa
eval add wave -noupdate $hexopt /tb${ps}qdriip_d

eval add wave -noupdate $binopt /tb${ps}qdriip_cq_p
eval add wave -noupdate $binopt /tb${ps}qdriip_cq_n
eval add wave -noupdate $hexopt /tb${ps}qdriip_q
eval add wave -noupdate $binopt /tb${ps}qdriip_qvld

eval add wave -noupdate $binopt /tb${ps}qdriip_dll_off_n

eval add wave -noupdate -divider {"u_mig_7series_v1_9"}
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}u_mig_7series_v1_9${ps}u_infrastructure${ps}rstdiv0
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}u_mig_7series_v1_9${ps}u_infrastructure${ps}clk
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}u_mig_7series_v1_9${ps}u_infrastructure${ps}mem_refclk
#eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}u_mig_7series_v1_9${ps}u_infrastructure${ps}ddr_refclk
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}u_mig_7series_v1_9${ps}u_infrastructure${ps}sync_pulse

eval add wave -noupdate -divider {"ck p i"}
set osd "/tb/qdr_tb/example_top/u_mig_7series_v1_9/u_qdr_phy_top/u_qdr_rld_mc_phy/qdr_rld_phy_4lanes_2/u_qdr_rld_phy_4lanes/qdr_rld_byte_lane_C/qdr_rld_byte_lane_C/"
eval add wave -noupdate $binopt ${osd}skewd_oserdes_clk
eval add wave -noupdate $binopt ${osd}skewd_oserdes_clkdiv
eval add wave -noupdate $binopt ${osd}mem_refclk
eval add wave -noupdate $binopt ${osd}phy_clk_fast
eval add wave -noupdate $binopt ${osd}os_rst
eval add wave -noupdate $binopt ${osd}skewd_oserdes_clk_delayed
eval add wave -noupdate $binopt ${osd}ddr_ck_out_q


eval add wave -noupdate -divider {"example top"}
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}clk
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}rst_clk

eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}cmp_err
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}init_calib_complete

#eval add wave -noupdate -divider {"phy top"}
#eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}u_mig_7series_v1_9${ps}u_qdr_phy_top${ps}


# Wave window configuration information
#
configure  wave -justifyvalue          right
configure  wave -signalnamewidth       1

TreeUpdate [SetDefaultTree]
