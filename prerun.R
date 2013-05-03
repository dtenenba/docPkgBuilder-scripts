#!/usr/bin/env Rscript

## Determine package dependencies.

## For now, just assume that the working directory contains 
## a package. Later, we will create a package if necessary
## from just a directory containing Rmd files (and images, etc).

instPkgs <- installed.packages()

if (!"BiocInstaller" %in% rownames(instPkgs))
    source("http://bioconductor.org/biocLite.R")
else
    library(BiocInstaller)

if ("!knitr" %in% rownames(instPkgs))
    biocLite("knitr")


