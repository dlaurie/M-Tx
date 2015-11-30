default:
	texlua buildmtxdoc.lua
halleluja:
	texlua buildmtxdoc.lua halleluja
kanons:
	texlua buildmtxdoc.lua kanons
PHONY: default hallelua kanons

support = docversion Makefile make-dvi make-pdf make-target pdfcat \
  buildmtxdoc.lua mtxproject.lua

Dzip: 
	- @zip -ju mtxD`./docversion` $(sources) $(support) README

bare:
	- rm $(examples) $(halleluja_pieces) $(kanons_pieces) *.dvi *.lj *.ps *.pdf\
     dwoman.mtx netsoos?.mtx melisma?.mtx *.mx? *.ind *.idx *.ilg *.toc *.aux *.log *.pm?

commit: bare
	git add *

############################################################################
##    Everything below this box must be thought of as unmaintained code   ##
############################################################################

PREPMX = ../prepmx
include make-target

sources = mtxdoc.tex mtxdoc.sty mtxlatex.sty mozart0.mtx mozart.mtx\
 netfirst.mtx meter.mtx notes.tex lyrics.tex\
 dertod.mtx volta.mtx title.mtx title1.mtx psalm42.mtx netsoos1.mtb \
 netsoos2.mtb borup.mtx melisma1.mtb dwoman.mtb \
 melisma2.mtb melisma3.mtb melisma4.mtb melisma5.mtb melisma6.mtb \
 dwoman.mta melisma.mta netsoos.mta kroonhom.mtx loofnou.mtx \
 viva.mtx dona.mtx sanctus.mtx halleluja.tex kanons.tex chord.mtx \
 macro.mtx

examples = mozart0.tex mozart.tex netfirst.tex meter.tex \
 dertod.tex volta.tex title.tex title1.tex psalm42.tex netsoos1.tex \
 netsoos2.tex borup.tex melisma1.tex dwoman.tex \
 melisma2.tex melisma3.tex melisma4.tex melisma5.tex melisma6.tex \
 chord.tex macro.tex

halleluja_pieces = kroonhom.tex loofnou.tex

kanons_pieces = viva.tex dona.tex sanctus.tex

%.tex: %.mtx
	$(PREPMX) $* 
	pmxab $*
	rm $*.pml $*.pmx pmxaerr.dat

DOC: mtx.$(target)

mtxdoc.$(target): mtxdoc.tex mtxdoc.sty $(examples)
	touch mtxdoc.mx1
	rm *.mx?
	- $(latex) mtxdoc
	musixflx mtxdoc
	makeindex mtxdoc
	- $(latex) mtxdoc
	rm mtxdoc.log mtxdoc.idx mtxdoc.ilg 

%.mtx: %.mta %.mtb
	cat $*.mta $*.mtb > $*.mtx

melisma%.mtx: melisma.mta melisma%.mtb
	cat melisma.mta melisma$*.mtb > melisma$*.mtx

netsoos%.mtx: netsoos.mta netsoos%.mtb
	cat netsoos.mta netsoos$*.mtb > netsoos$*.mtx

once: mtxdoc.tex mtxdoc.sty $(examples)
	- $(latex) mtxdoc

index: mtxdoc.idx mtxindex.tex
	makeindex mtxdoc
	$(latex) mtxindex

%.$(target): %.tex
	- rm $*.mx?; $(latex) $*.tex; musixflx $*; $(latex) $*.tex

kanons.$(target): kanons.tex $(kanons_pieces)

halleluja.$(target): halleluja.tex $(halleluja_pieces)

all: mtxdoc.$(target) kanons.$(target) halleluja.$(target) 

config:
	@echo "Configuring mtxdoc Version `./docversion`"
	@echo "Looking for prepmx ... `which prepmx`"
	ln -sf `which prepmx` .
	@echo "Looking for pmxab ... `which pmxab`"
	@echo "Looking for musixflx ... `which musixflx`"
	@echo "Looking for musixtex ... `kpsewhich musixtex.tex`"
	@echo "Looking for musixlyr ... `kpsewhich musixlyr.tex`"
	@echo "Looking for $(latex) ... `which $(latex)`"
	@echo "Looking for $(concat) ... `which $(concat)`"

pdftarget: 
	ln -sf make-pdf make-target


dvitarget: 
	ln -sf make-dvi make-target

paperus:
	echo \\def\\paperUS{} > mypaper.tex

papera4:
	echo \\def\\paperA4{} > mypaper.tex

mtxdocus.$(target): paperus mtxdoc.$(target)
	mv mtxdoc.$(target) mtxdocus.$(target)	

mtxdoca4.$(target): papera4 mtxdoc.$(target)
	mv mtxdoc.$(target) mtxdoca4.$(target)

ps: mtxdoc.ps halleluja.ps kanons.ps

pdf: mtxdoc.pdf halleluja.pdf kanons.pdf 

mtx.dvi: mtxdoc.dvi mtxindex.dvi
	dviconcat -o mtx.dvi mtxdoc.dvi mtxindex.dvi




