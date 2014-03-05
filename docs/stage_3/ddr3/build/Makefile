all: mig_7series_v1_9_readme.txt

CGP=../coregen.cgp
XCO=../mig_7series_v1_9.xco

mig_7series_v1_9_readme.txt: ${CGP} ${XCO}
	cp ${CGP} ${XCO} .
	coregen -p coregen.cgp -b mig_7series_v1_9.xco

clean:
	rm -fr mig_*

