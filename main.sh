#!/bin/sh

set -e  # Exit immediately if a simple command exits with a non-zero status

rm -f $WORKSPACE/*.tar.gz
$HOME_OF_R/bin/Rscript $BUILDER_SCRIPTS/docPkgBuilder-scripts/prerun.R
$HOME_OF_R/bin/R CMD build $WORKSPACE
$HOME_OF_R/bin/R CMD check --no-vignettes *.tar.gz
if [ $NODE_NAME == "master" ]
then
    cd $WORKSPACE
    tar zxf *.tar.gz
    export pkg=`echo *.tar.gz | cut -d _ -f 1`
    cd $pkg
    if [ -d vignettes ]
    then
        cd vignettes
    else
        if [ -d inst/doc ]
        then
            cd inst/doc
        else
            echo "There are no vignettes in this package!"
            exit 1
        fi
    fi
    for i in `ls *.Rmd`
    do
        $HOME_OF_R/bin/R --vanilla -q -e "library(knitr);knit('$i')"
    done
    tar zcf $WORKSPACE/$pkg-vignettes.tar.gz .
    echo "Vignette tarball has been created."
fi
