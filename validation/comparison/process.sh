#!/bin/bash

sed -i '23,$s/_/\\_/g' overview.tex 
pdflatex overview.tex
pdflatex overview.tex
