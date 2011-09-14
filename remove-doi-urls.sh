#!/bin/sh
perl -i -ne 'print if !(/http:\/\/dx.doi.org/ || /http:\/\/arxiv\.org\//)' tobin.bib
