#!/bin/sh

set -e  # Exit immediately if a simple command exits with a non-zero status

echo "TEMP = $TEMP"
echo "TMP = $TMP"

if [ -z "$TMP" ]; then
    TMP=/tmp
fi

CHECK_DIR=$TMP/$BUILD_TAG
mkdir $CHECK_DIR


rm -f $WORKSPACE/*.tar.gz
$HOME_OF_R/bin/Rscript $BUILDER_SCRIPTS/docPkgBuilder-scripts/prerun.R
echo "d0"
echo "workspace is $WORKSPACE"
echo "current dir is"
echo `pwd`
cd $WORKSPACE
echo "now current dir is"
echo `pwd`
# uncomment this:
###$HOME_OF_R/bin/R CMD build $WORKSPACE
# remove this:
$HOME_OF_R/bin/R CMD build --no-vignettes $WORKSPACE
echo "d1"
# uncomment this:
# cd $CHECK_DIR
###$HOME_OF_R/bin/R CMD check --no-vignettes $WORKSPACE/*.tar.gz
# rm -rf $CHECK_DIR

if [ "$NODE_NAME" = "master" ]; then
    echo "workspace is $WORKSPACE"
    cd $WORKSPACE
    rm -rf library
    mkdir library
    R_LIBS_USER=$WORKSPACE/library $HOME_OF_R/bin/R CMD INSTALL --library=library $WORKSPACE/*.tar.gz

    tar zxf *.tar.gz
    export pkg=`echo *.tar.gz | cut -d _ -f 1`
    echo "pkg is:"
    echo $pkg
    rm -rf $pkg.Rcheck
    cd $pkg
    echo "current directory:"
    echo `pwd`
    if [ -d "vignettes" ]; then
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
        #R_LIBS_USER=$WORKSPACE/library 
        echo "Building $i..."
        $HOME_OF_R/bin/R --vanilla -q -e "library(knitr);.libPaths(c("$WORKSPACE/library", .libPaths()));.libPaths();knit('$i')"
    done
    tar zcf $WORKSPACE/$pkg-vignettes.tar.gz .
    echo "Vignette tarball has been created."
fi
