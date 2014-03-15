BITS += example_chipscope_ibert10g.bit
BITS += example_chipscope_ibert1g.bit
BITS += example_chipscope_ibert_pcie_gen2.bit
BITS += example_chipscope_ibert_pcie_gen3.bit
BITS += example_chipscope_ibert_sas6g.bit
BITS += k7netfpga_ibert_10g.bit
BITS += k7netfpga_ibert_1g.bit

all: ${BITS}

DEV=xc7k325t-ffg900-2

export XIL_PAR_DESIGN_CHECK_VERBOSE=1

example_%.bit: %.xco
	coregen -p coregen.cgp -b $^

clean:
	rm -fr chipscope_ibert*g chipscope_ibert_pcie_gen2 *.bit chipscope_ibert_pcie_gen3 example_chipscope_ibert_sas6g
	rm -fr  *.asy *.txt *.gise *.ngc *.v *.veo *.xise *.tcl  *.lso *.pcf *.ncd *.pad *.csv *.mrp  *.log

icon_kintex7.ngc: icon_kintex7.xco
	coregen -p coregen.cgp -b $^

#############################
# 10g ibert for k7 netfpga #
# xst
k7netfpga_ibert_10g.ngc: k7netfpga_ibert_10g.v  icon_kintex7.ngc
	xst -ifn k7netfpga_ibert_10g.xst -ofn $@ -intstyle ise
# translate
k7netfpga_ibert_10g.ngd: k7netfpga_ibert_10g.ngc k7netfpga_ibert_10g.ucf
	ngdbuild -intstyle ise -sd . -dd . -nt timestamp -uc k7netfpga_ibert_10g.ucf -p ${DEV} k7netfpga_ibert_10g.ngc k7netfpga_ibert_10g.ngd	
# map
k7netfpga_ibert_10g_map.ncd: k7netfpga_ibert_10g.ngd
	map -intstyle ise -p ${DEV} -w -ol high -xe n -register_duplication off -ir off -pr off -lc off -power off -o $@ $^ k7netfpga_ibert_10g.pcf
# par
k7netfpga_ibert_10g.ncd: k7netfpga_ibert_10g_map.ncd
	par -w -intstyle ise -ol high -xe n $^ $@ k7netfpga_ibert_10g.pcf
# trace
k7netfpga_ibert_10g.twr: k7netfpga_ibert_10g.ncd
	trce -intstyle ise -v 3 -fastpaths -xml k7netfpga_ibert_10g $^ -o $@ k7netfpga_ibert_10g.pcf
# bitgen
k7netfpga_ibert_10g.bit: k7netfpga_ibert_10g.twr
	bitgen -w -intstyle ise k7netfpga_ibert_10g.ncd


#############################
# 1g ibert for k7 netfpga #
# xst
k7netfpga_ibert_1g.ngc: k7netfpga_ibert_1g.v  icon_kintex7.ngc
	xst -ifn k7netfpga_ibert_1g.xst -ofn $@ -intstyle ise
# translate
k7netfpga_ibert_1g.ngd: k7netfpga_ibert_1g.ngc k7netfpga_ibert_1g.ucf
	ngdbuild -intstyle ise -sd . -dd . -nt timestamp -uc k7netfpga_ibert_1g.ucf -p ${DEV} k7netfpga_ibert_1g.ngc k7netfpga_ibert_1g.ngd	
# map
k7netfpga_ibert_1g_map.ncd: k7netfpga_ibert_1g.ngd
	map -intstyle ise -p ${DEV} -w -ol high -xe n -register_duplication off -ir off -pr off -lc off -power off -o $@ $^ k7netfpga_ibert_1g.pcf
# par
k7netfpga_ibert_1g.ncd: k7netfpga_ibert_1g_map.ncd
	par -w -intstyle ise -ol high -xe n $^ $@ k7netfpga_ibert_1g.pcf
# trace
k7netfpga_ibert_1g.twr: k7netfpga_ibert_1g.ncd
	trce -intstyle ise -v 3 -fastpaths -xml k7netfpga_ibert_1g $^ -o $@ k7netfpga_ibert_1g.pcf
# bitgen
k7netfpga_ibert_1g.bit: k7netfpga_ibert_1g.twr
	bitgen -w -intstyle ise k7netfpga_ibert_1g.ncd
