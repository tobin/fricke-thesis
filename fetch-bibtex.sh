#!/bin/sh
wget --output-document=tobin.bib "http://www.citeulike.org/bibtex/user/tobin?key_type=4"
./remove-doi-urls.sh
