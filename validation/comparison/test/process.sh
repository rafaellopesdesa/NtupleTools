#!/bin/bash

#sed -i '23,$s/_/\\_/g' overview.tex 
##ps2pdf diff.ps
#pdflatex overview.tex
#pdflatex overview.tex && rm hists/*
gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -sOutputFile=results.pdf hists/*.pdf
#rm hists/*
