all: example_chipscope_ibert.ngc icon_kintex7.ngc
	cp *.ngc ../top/

example_chipscope_ibert.ngc:
	coregen -p k7_325.cgp  -b chipscope_ibert.xco

icon_kintex7.ngc:
	coregen -p k7_325.cgp  -b chipscope_icon_1.xco
