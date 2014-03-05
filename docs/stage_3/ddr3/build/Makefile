all: ../ddr3_tb.bit

CGP=../coregen.cgp
XCO=../mig_7series_v1_9.xco
PRJ=../mig.prj

mig_7series_v1_9_readme.txt: ${CGP} ${XCO} ${PRJ}
	cp ${CGP} ${XCO} ${PRJ} .
	coregen -p coregen.cgp -b mig_7series_v1_9.xco

clean:
	rm -fr mig_*


../ddr3_tb.bit: mig_7series_v1_9/example_design/par/example_top.bit ../ddr3_tb.v ../example_inf.v

# NGC
../ddr3_tb.ngc: ../ddr3_tb.v ../example_inf.v 
	xst -ifn ../ddr3_tb_xst_opt.txt -ofn ddr3_tb_xst.syr -intstyle ise

# MAP
