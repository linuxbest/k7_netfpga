vlib work

vlog cyqdr2_b4.v
vlog rw_test.v

vsim -t fs -novopt work.rw_test

if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"top"}
eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}K
eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}Kb

eval add wave -noupdate $hexopt /rw_test${ps}test_file${ps}A
eval add wave -noupdate $hexopt /rw_test${ps}test_file${ps}D

eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}RPSb
eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}WPSb

eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}BWS0b
eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}BWS1b
eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}BWS2b
eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}BWS3b

eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}CQ
eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}CQb

eval add wave -noupdate $binopt /rw_test${ps}test_file${ps}QVLD
eval add wave -noupdate $hexopt /rw_test${ps}test_file${ps}Q


# Wave window configuration information
#
configure  wave -justifyvalue          right
configure  wave -signalnamewidth       1

TreeUpdate [SetDefaultTree]

run -all
