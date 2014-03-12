all: mig_7series_v1_9_readme.txt qdr_tb.bit

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
qdr_tb.ngc: ../qdr_tb.v ../example_inf.v 
	xst -ifn ../qdr_tb_xst_opt.txt -ofn qdr_tb_xst.syr -intstyle ise

# TRANSLATE
qdr_tb.ngd: qdr_tb.ngc ../qdr_tb.ucf 
	ngdbuild -intstyle ise -sd mig_7series_v1_9/example_design/par -dd . -nt timestamp -uc ../qdr_tb.ucf -p ${DEV} qdr_tb.ngc qdr_tb.ngd

# MAP
qdr_tb_map.ncd: qdr_tb.ngd
	map -intstyle ise -p ${DEV} -w -ol high -xe n -register_duplication off -ir off -pr off -lc off -power off -o qdr_tb_map.ncd qdr_tb.ngd qdr_tb.pcf

# PAR
qdr_tb.ncd: qdr_tb_map.ncd
	par -w -intstyle ise -ol high -xe n qdr_tb_map.ncd qdr_tb.ncd qdr_tb.pcf

# TRACE
qdr_tb.twr: qdr_tb.ncd
	trce -intstyle ise -v 3 -fastpaths -xml qdr_tb qdr_tb.ncd -o qdr_tb.twr qdr_tb.pcf

CGS=icon3.ngc
CGS+=ila256_16.ngc
CGS+=ila512_16.ngc
CGS+=vio_async_in256_sync_out72.ngc

# BIT
qdr_tb.bit: ${CGS} qdr_tb.ncd qdr_tb.twr
	bitgen -w -intstyle ise qdr_tb.ncd

mig_7series_v1_9/example_design/par/example_top.bit: mig_7series_v1_9_readme.txt
	cd mig_7series_v1_9/example_design/par/ && ./ise_flow.sh

icon3.ngc:
	cp mig_7series_v1_9/example_design/par/icon3_cg.xco .
	coregen -p coregen.cgp -b icon3_cg.xco

ila256_16.ngc:
	cp mig_7series_v1_9/example_design/par/ila256_16_cg.xco .
	coregen -p coregen.cgp -b ila256_16_cg.xco

ila512_16.ngc:
	cp mig_7series_v1_9/example_design/par/ila512_16_cg.xco .
	coregen -p coregen.cgp -b ila512_16_cg.xco

vio_async_in256_sync_out72.ngc:
	cp mig_7series_v1_9/example_design/par/vio_async_in256_sync_out72_cg.xco .
	coregen -p coregen.cgp -b vio_async_in256_sync_out72_cg.xco
