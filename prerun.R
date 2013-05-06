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

availPkgs <- available.packages(contrib.url(biocinstallRepos()))


try(useDevel(), silent=TRUE)

if (!"knitr" %in% rownames(instPkgs))
{
    print("installing knitr")
    biocLite("knitr")
} else {
    print("not installing knitr")
}

dcf <- read.dcf(file.path(Sys.getenv("WORKSPACE"), "DESCRIPTION"))


getPkgs <- function(field, dcf)
{
    if (!field %in% colnames(dcf))
        return(character(0))
    val <- dcf[, field]
    val <- gsub("\\s+", "", val)
    val <- gsub("\\(.+\\)", "", val)
    cands <- strsplit(val, ",", TRUE)[[1]]
    res <- c()
    for (cand in cands)
    {
        if (cand != "R")
        {
            if ((!cand %in% rownames(instPkgs)) 
                || (!grepl("^Part of R", instPkgs[cand, 'License'])))
                res <- append(res, cand)
        }
    }
    res
}

needToInstall <- function(pkgs)
{
    res <- c()
    for (pkg in pkgs)
    {
        if (!pkg %in% rownames(instPkgs))
        {
            res <- append(res, TRUE)
        } else {
            installedVersion <- package_version(instPkgs[pkg, "Version"])
            availableVersion <- package_version(availPkgs[pkg, "Version"])
            res <- append(res, availableVersion  > installedVersion)
        }
    }
    res
}

res <- c()
for (category in c("Depends", "Imports", "Suggests", "Enhances"))
{
    res <- append(res, getPkgs(category, dcf))
}

installMe <- res[needToInstall(res)]
if (length(installMe))
{
    print("Installing dependencies...")
    biocLite(installMe)
}