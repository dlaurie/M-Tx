pasfiles = globals.pas mtx.pas preamble.pas lyrics.pas analyze.pas mtxline.pas\
  status.pas uptext.pas prepmx.pas files.pas notes.pas multfile.pas \
  strings.pas utility.pas control.pas
sfiles =  mtx.tex mtxdoc.tex mtxdoc.pdf Makefile Corrections Bugs MAINTENANCE

SYSTEM=LINUX

prepmx: $(pasfiles)
	fpc -g -B -vn -So prepmx -T$(SYSTEM)

commit: $(pasfiles) $(sfiles)
	git add $(pasfiles) $(sfiles)
	echo Now type: git commit -m \"DESCRIPTION OF_CHANGES\"

clean:
	- rm *.o *~ *~ core *.pmx *.pml *.log *.dvi 

bare: clean
	- rm prepmx *.ppu

Pzip:
	zip -ju mtxP`./version` version $(pasfiles) $(sfiles) README.*  


