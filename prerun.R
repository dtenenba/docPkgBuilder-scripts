#!/usr/bin/env Rscript

## Determine package dependencies.

## For now, just assume that the working directory contains 
## a package. Later, we will create a package if necessary
## from just a directory containing Rmd files (and images, etc).

userdir <- unlist(strsplit(Sys.getenv("R_LIBS_USER"),
                                   .Platform$path.sep))[1L]

print("userdir is:")
print(userdir)


instPkgs <- installed.packages()

if (!"BiocInstaller" %in% rownames(instPkgs))
{
    source("http://bioconductor.org/biocLite.R")
} else {
    library(BiocInstaller)
}

try(useDevel(), silent=TRUE)

if ("!knitr" %in% rownames(instPkgs))
    biocLite("knitr")


