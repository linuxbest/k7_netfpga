all: ddr3_tb.bit

CGP=../coregen.cgp
XCO=../mig_7series_v1_9.xco
PRJ=../mig.prj
DEV=xc7k325t-ffg900-2

export XIL_PAR_DESIGN_CHECK_VERBOSE=1

mig_7series_v1_9_readme.txt: ${CGP} ${XCO} ${PRJ}
	cp ${CGP} ${XCO} ${PRJ} .
	coregen -p coregen.cgp -b mig_7series_v1_9.xco

clean:
	rm -fr mig_*

# NGC
ddr3_tb.ngc: ../ddr3_tb.v ../example_inf.v mig_7series_v1_9_readme.txt
	xst -ifn ../ddr3_tb_xst_opt.txt -ofn ddr3_tb_xst.syr -intstyle ise

# TRANSLATE
ddr3_tb.ngd: ddr3_tb.ngc ../ddr3_tb.ucf 
	ngdbuild -intstyle ise -sd mig_7series_v1_9/example_design/par -dd . -nt timestamp -uc ../ddr3_tb.ucf -p ${DEV} ddr3_tb.ngc ddr3_tb.ngd

# MAP
ddr3_tb_map.ncd: ddr3_tb.ngd
	map -intstyle ise -p ${DEV} -w -pr b -ol high -timing -detail -o ddr3_tb_map.ncd ddr3_tb.ngd ddr3_tb.pcf

# PAR
ddr3_tb.ncd: ddr3_tb_map.ncd
	par -w -intstyle ise -ol high ddr3_tb_map.ncd ddr3_tb.ncd ddr3_tb.pcf

# TRACE
ddr3_tb.twr: ddr3_tb.ncd
	trce -intstyle ise -v 3 -fastpaths -xml ddr3_tb ddr3_tb.ncd -o ddr3_tb.twr ddr3_tb.pcf

CGS=ddr_icon.ngc
CGS+=ddr_ila_basic.ngc
CGS+=ddr_ila_wrpath.ngc
CGS+=ddr_ila_rdpath.ngc
CGS+=ddr_vio_sync_async_out72.ngc
CGS+=ddr_vio_async_in_sync_out.ngc

# BIT
ddr3_tb.bit: ${CGS} ddr3_tb.ncd ddr3_tb.twr
	bitgen -w -intstyle ise ddr3_tb.ncd

mig_7series_v1_9/example_design/par/example_top.bit: mig_7series_v1_9_readme.txt
	cd mig_7series_v1_9/example_design/par/ && ./ise_flow.sh

ddr_icon.ngc: mig_7series_v1_9_readme.txt
	cp mig_7series_v1_9/example_design/par/ddr_icon_cg.xco .
	coregen -p coregen.cgp -b ddr_icon_cg.xco

ddr_ila_basic.ngc: mig_7series_v1_9_readme.txt
	cp mig_7series_v1_9/example_design/par/ddr_ila_basic_cg.xco .
	coregen -p coregen.cgp -b ddr_ila_basic_cg.xco

ddr_ila_wrpath.ngc: mig_7series_v1_9_readme.txt
	cp mig_7series_v1_9/example_design/par/ddr_ila_wrpath_cg.xco .
	coregen -p coregen.cgp -b ddr_ila_wrpath_cg.xco

ddr_ila_rdpath.ngc: mig_7series_v1_9_readme.txt
	cp mig_7series_v1_9/example_design/par/ddr_ila_rdpath_cg.xco .
	coregen -p coregen.cgp -b ddr_ila_rdpath_cg.xco

ddr_vio_sync_async_out72.ngc: mig_7series_v1_9_readme.txt
	cp mig_7series_v1_9/example_design/par/ddr_vio_sync_async_out72_cg.xco .
	coregen -p coregen.cgp -b ddr_vio_sync_async_out72_cg.xco

ddr_vio_async_in_sync_out.ngc: mig_7series_v1_9_readme.txt
	cp mig_7series_v1_9/example_design/par/ddr_vio_async_in_sync_out_cg.xco .
	coregen -p coregen.cgp -b ddr_vio_async_in_sync_out_cg.xco
