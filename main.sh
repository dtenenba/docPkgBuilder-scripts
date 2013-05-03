#!/bin/sh

set -e  # Exit immediately if a simple command exits with a non-zero status

rm -f $WORKSPACE/*.tar.gz
$HOME_OF_R/bin/Rscript $BUILDER_SCRIPTS/docPkgBuilder-scripts/prerun.R
# uncomment this:
###$HOME_OF_R/bin/R CMD build $WORKSPACE
# remove this:
$HOME_OF_R/bin/R CMD build $ --no-vignettes WORKSPACE
# uncomment this:
###$HOME_OF_R/bin/R CMD check --no-vignettes *.tar.gz
if [ "$NODE_NAME" == "master" ]
then
    cd $WORKSPACE
    rm -f library
    mkdir library
    $HOME_OF_R/bin/R CMD INSTALL --library=library *.tar.gz

    tar zxf *.tar.gz
    export pkg=`echo *.tar.gz | cut -d _ -f 1`
    echo "pkg is:"
    echo $pkg
    rm -f $pkg.Rcheck
    cd $pkg
    echo "current directory:"
    echo `pwd`
    if [ -d "vignettes" ]
    then
        cd vignettes
    else
        if [ -d "inst/doc" ]
        then
            cd inst/doc
        else
            echo "There are no vignettes in this package!"
            exit 1
        fi
    fi
    for i in `ls *.Rmd`
    do
        R_LIBS_USER=$WORKSPACE/library $HOME_OF_R/bin/R --vanilla -q -e "library(knitr);knit('$i')"
    done
    tar zcf $WORKSPACE/$pkg-vignettes.tar.gz .
    echo "Vignette tarball has been created."
fi
