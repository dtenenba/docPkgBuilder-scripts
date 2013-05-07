#!/bin/sh

set -e  # Exit immediately if a simple command exits with a non-zero status

if [ -z "$TMP" ]; then
    TMP=/tmp
fi

CHECK_DIR=$TMP/$BUILD_TAG
mkdir $CHECK_DIR

cd $WORKSPACE
rm -rf `echo $JOB_NAME|cut -d / -f 1`

rm -f $WORKSPACE/*.tar.gz
$HOME_OF_R/bin/Rscript $BUILDER_SCRIPTS/docPkgBuilder-scripts/prerun.R
echo "workspace is $WORKSPACE"

if [ "$NODE_NAME" = "master" ]; then
    bash $BUILDER_SCRIPTS/docPkgBuilder-scripts/make-vignettes.sh
else
    echo ">>> Running R CMD build:"
    $HOME_OF_R/bin/R CMD build $WORKSPACE
    # remove this:
    #$HOME_OF_R/bin/R CMD build --no-vignettes $WORKSPACE
    cd $CHECK_DIR
    echo ">>> Running R CMD check:"
    $HOME_OF_R/bin/R CMD check --no-vignettes $WORKSPACE/*.tar.gz
    cd $WORKSPACE
    rm -rf $CHECK_DIR
fi
