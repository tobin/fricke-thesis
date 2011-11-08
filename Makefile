dissertation.pdf:
	pdflatex dissertation
	bibtex dissertation
	bibtex dissertation
	./lsu-fix-toc.sh
	pdflatex dissertation


