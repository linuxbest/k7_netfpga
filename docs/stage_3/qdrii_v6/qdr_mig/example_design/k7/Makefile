T=example_top
DEV=xc7k325t-ffg900-2

export XIL_PAR_DESIGN_CHECK_VERBOSE=1

all: ${T}.bit

${T}.lso:
	touch $@

${T}.ngc: xst_opt.txt ${T}.prj ${T}.lso icon.ngc ila.ngc vio.ngc
	xst -ifn xst_opt.txt -ofn ${T}_xst.syr -intstyle ise

# translatee
${T}.ngd: ${T}.ngc ${T}.ucf
	ngdbuild -intstyle ise -sd . -dd . -nt timestamp -uc ${T}.ucf -p ${DEV} ${T}.ngc ${T}.ngd
# map
${T}_map.ngd: ${T}.ngd
	map -intstyle ise -p ${DEV} -w -pr b -ol high -timing -detail -o ${T}_map.ncd ${T}.ngd ${T}.pcf
# par
${T}.ncd: ${T}_map.ngd
	par -w -intstyle ise -ol high ${T}_map.ncd ${T}.ncd ${T}.pcf
# trce
${T}.twr: ${T}.ncd
	trce -intstyle ise -v 3 -fastpaths -xml ${T} ${T}.ncd -o ${T}.twr ${T}.pcf
# bitgeen
${T}.bit: ${T}.twr 
	bitgen -w -intstyle ise ${T}.ncd

icon_cg.ngc:
	coregen -p coregen.cgp -b icon_cg.xco
ila_cg.ngc:
	coregen -p coregen.cgp -b ila_cg.xco
vio_cg.ngc:
	coregen -p coregen.cgp -b vio_cg.xco
