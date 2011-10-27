#!/bin/sh
wget --output-document=tobin.bib "http://www.citeulike.org/bibtex/user/tobin?key_type=4&incl_amazon=0&clean_urls=0"
./remove-doi-urls.sh
bibtex dissertation
# Remove non-public DCC links since they bother everyone so much
perl -i -ne 'print if !(/private/)' tobin.bib

