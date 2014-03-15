all: example_chipscope_ibert10g.bit example_chipscope_ibert1g.bit example_chipscope_ibert_pcie_gen2.bit example_chipscope_ibert_pcie_gen3.bit  example_chipscope_ibert_sas6g.bit


example_%.bit: %.xco
	coregen -p coregen.cgp -b $^

clean:
	rm -fr chipscope_ibert*g chipscope_ibert_pcie_gen2 *.bit chipscope_ibert_pcie_gen3 example_chipscope_ibert_sas6g
	rm -fr  *.asy *.txt *.gise *.ngc *.v *.veo *.xise *.tcl  *.lso *.pcf *.ncd *.pad *.csv *.mrp  *.log
