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
eval add wave -noupdate $hexopt /tb${ps}qdriip_q
eval add wave -noupdate $hexopt /tb${ps}qdriip_d

eval add wave -noupdate -divider {"u_mig_7series_v1_9"}
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}u_mig_7series_v1_9${ps}u_infrastructure${ps}rstdiv0
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}u_mig_7series_v1_9${ps}u_infrastructure${ps}clk
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}u_mig_7series_v1_9${ps}u_infrastructure${ps}mem_refclk
eval add wave -noupdate $binopt /tb${ps}qdr_tb${ps}example_top${ps}u_mig_7series_v1_9${ps}u_infrastructure${ps}sync_pulse


# Wave window configuration information
#
configure  wave -justifyvalue          right
configure  wave -signalnamewidth       1

TreeUpdate [SetDefaultTree]
