
all: k7_netfpga_test.bit

export XIL_PAR_DESIGN_CHECK_VERBOSE=1

k7_netfpga_test.bit: k7_netfpga_test.ncd
	bitgen -g UnconstrainedPins:Allow -intstyle ise $^

k7_netfpga_test.ncd: k7_netfpga_test_map.ncd 
	par -w -intstyle ise -ol high -xe n k7_netfpga_test_map.ncd k7_netfpga_test.ncd k7_netfpga_test.pcf

k7_netfpga_test_map.ncd: k7_netfpga_test.ngd
	map -intstyle ise -p xc7k325t-ffg900-3 -w -ol high -xe n -register_duplication off -ir off -pr off -lc off -power off -o k7_netfpga_test_map.ncd k7_netfpga_test.ngd k7_netfpga_test.pcf

k7_netfpga_test.ngd: k7_netfpga_test.ngc k7_netfpga_test.ucf
	ngdbuild -intstyle ise -nt timestamp -uc k7_netfpga_test.ucf -p xc7k325t-ffg900-3 k7_netfpga_test.ngc k7_netfpga_test.ngd

k7_netfpga_test.ngc: 
	xst -ifn xst_options.txt -ofn k7_netfpga_test.syr -intstyle ise
