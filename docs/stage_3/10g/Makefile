all: example_chipscope_ibert10g.bit example_chipscope_ibert1g.bit


example_%.bit: %.xco
	coregen -p coregen.cgp -b $^

clean:
	rm -fr *.bit 
