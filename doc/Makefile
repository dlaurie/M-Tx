# Makefile for the M-Tx documentation

default:
	texlua buildmtxdoc.lua
halleluja:
	texlua buildmtxdoc.lua halleluja
kanons:
	texlua buildmtxdoc.lua kanons
PHONY: default hallelua kanons

support = Makefile make-dvi make-pdf make-target pdfcat \
  buildmtxdoc.lua buildzip.lua

sources = mtxdoc.ltx mtxdoc.sty mtxlatex.sty mozart0.mtx mozart.mtx\
 netfirst.mtx meter.mtx dertod.mtx volta.mtx title.mtx title1.mtx\
 psalm42.mtx netsoos1.mtb notes.tex lyrics.tex\
 netsoos2.mtb borup.mtx melisma1.mtb dwoman.mtb \
 melisma2.mtb melisma3.mtb melisma4.mtb melisma5.mtb melisma6.mtb \
 dwoman.mta melisma.mta netsoos.mta kroonhom.mtx loofnou.mtx \
 viva.mtx dona.mtx sanctus.mtx halleluja.ltx kanons.ltx chord.mtx \
 macro.mtx

nonsources = borup.tex chord.tex dertod.tex dwoman.tex macro.tex\
 melisma1.tex melisma2.tex melisma3.tex melisma4.tex melisma5.tex\
 melisma6.tex meter.tex mozart.tex mozart0.tex netfirst.tex\
 netsoos1.tex netsoos2.tex psalm42.tex title1.tex title.tex volta.tex\
 mtxdoc.aux mtxdoc.ind mtxdoc.toc mtxdoc.pdf halleluja.pdf kanons.pdf

zip: 
	texlua buildzip.lua $(sources) $(support) README

clean:
	- rm dwoman.mtx netsoos?.mtx melisma?.mtx *.pm?

bare: clean
	- rm $(nonsources)

commit: clean
	git add $(sources) $(support)


