#!/bin/bash

sed -i 's/_/\\_/g' overview.tex 
pdflatex overview.tex
ps2pdf diff.ps
gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -sOutputFile=results.pdf overview.pdf diff.pdf