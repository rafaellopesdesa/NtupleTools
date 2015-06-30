#!/bin/bash

sed -i '22,$s/_/\\_/g' overview.tex 
#ps2pdf diff.ps
pdflatex overview.tex
pdflatex overview.tex
#gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -sOutputFile=results.pdf overview.pdf diff.pdf
