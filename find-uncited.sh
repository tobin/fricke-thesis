#!/bin/bash

# This script lists the references that appear in the BibTex database but
# are not cited in the dissertation.
#
# http://tex.stackexchange.com/questions/30391/how-to-list-uncited-bib-entries

comm -13 <(sed -n 's/^\\bibitem{\(.*\)}/\1/p' < dissertation.bbl | sort) \
         <(sed -n 's/^@\(.*\){\(.*\),/\2/p'  < tobin.bib | sort)

