all: example_chipscope_ibert10g.bit example_chipscope_ibert1g.bit example_chipscope_ibert_pcie_gen2.bit


example_%.bit: %.xco
	coregen -p coregen.cgp -b $^

clean:
	rm -fr chipscope_ibert*g chipscope_ibert_pcie* *.bit
