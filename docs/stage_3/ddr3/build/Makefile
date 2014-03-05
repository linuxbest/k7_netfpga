all: ../ddr3_tb.bit

CGP=../coregen.cgp
XCO=../mig_7series_v1_9.xco
PRJ=../mig.prj
DEV=xc7k325t-ffg900-2

mig_7series_v1_9_readme.txt: ${CGP} ${XCO} ${PRJ}
	cp ${CGP} ${XCO} ${PRJ} .
	coregen -p coregen.cgp -b mig_7series_v1_9.xco

clean:
	rm -fr mig_*


../ddr3_tb.bit: mig_7series_v1_9/example_design/par/example_top.bit ../ddr3_tb.v ../example_inf.v

# NGC
../ddr3_tb.ngc: ../ddr3_tb.v ../example_inf.v 
	xst -ifn ../ddr3_tb_xst_opt.txt -ofn ddr3_tb_xst.syr -intstyle ise

# TRANSLATE
../ddr3_tb.ngd: ../ddr3_tb.ngc ../ddr3_tb.ucf 
	ngdbuild -intstyle ise -sd mig_7series_v1_9/example_design/par -dd . -nt timestamp -uc ../ddr3_tb.ucf -p ${DEV} ../ddr3_tb.ngc ../ddr3_tb.ngd

# MAP
../ddr3_tb_map.ncd: ../ddr3_tb.ngd
	map -intstyle ise -p ${DEV} -w -ol high -xe n -register_duplication off -ir off -pr off -lc off -power off -o ../ddr3_tb_map.ncd ../ddr3_tb.ngd ../ddr3_tb.pcf

# PAR
../ddr3_tb.ncd: ../ddr3_tb_map.ncd
	par -w -intstyle ise -ol high -xe n ../ddr3_tb_map.ncd ../ddr3_tb.ncd ../ddr3_tb.pcf

# TRACE
../ddr3_tb.twr: ../ddr3_tb.ncd
	trce -intstyle ise -v 3 -fastpaths -xml ../ddr3_tb ../ddr3_tb.ncd -o ../ddr3_tb.twr ../ddr3_tb.pcf

# BIT
../ddr3_tb.bit: ../ddr3_tb.ncd ../ddr3_tb.twr
	bitgen -intstyle ise ../ddr3_tb.ncd
	cp ddr3_tb.bit ../

mig_7series_v1_9/example_design/par/example_top.bit: mig_7series_v1_9_readme.txt
	cd mig_7series_v1_9/example_design/par/ && ./ise_flow.sh
