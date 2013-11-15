
all: example_top.bit


example_top.bit: example_top.ncd
	bitgen -g UnconstrainedPins:Allow -intstyle ise $^

example_top.ncd: example_top_map.ncd 
	par -w -intstyle ise -ol high -xe n example_top_map.ncd example_top.ncd example_top.pcf

example_top_map.ncd: example_top.ngd
	map -intstyle ise -p xc7k325t-ffg900-3 -w -ol high -xe n -register_duplication off -ir off -pr off -lc off -power off -o example_top_map.ncd example_top.ngd example_top.pcf

example_top.ngd: example_top.ngc
	ngdbuild -intstyle ise -dd ../synth/_ngo -nt timestamp -uc example_top_tune.ucf -p xc7k325t-ffg900-3 example_top.ngc example_top.ngd

example_top.ngc: 
	xst -ifn xst_options.txt -ofn example_top.syr -intstyle ise
