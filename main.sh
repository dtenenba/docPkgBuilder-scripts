#!/bin/sh

set -e  # Exit immediately if a simple command exits with a non-zero status

echo "TEMP = $TEMP"
echo "TMP = $TMP"

if [ -z "$TMP" ]; then
    TMP=/tmp
fi

CHECK_DIR=$TMP/$BUILD_TAG
mkdir $CHECK_DIR

cd $WORKSPACE
echo "JOB_NAME IS $JOB_NAME"
rm -rf $JOB_NAME

rm -f $WORKSPACE/*.tar.gz
$HOME_OF_R/bin/Rscript $BUILDER_SCRIPTS/docPkgBuilder-scripts/prerun.R
echo "workspace is $WORKSPACE"
echo ">>> Running R CMD build:"
#$HOME_OF_R/bin/R CMD build $WORKSPACE
# remove this:
$HOME_OF_R/bin/R CMD build --no-vignettes $WORKSPACE
cd $CHECK_DIR
##echo ">>> Running R CMD check:"
##$HOME_OF_R/bin/R CMD check --no-vignettes $WORKSPACE/*.tar.gz
rm -rf $CHECK_DIR

if [ "$NODE_NAME" = "master" ]; then
    bash $BUILDER_SCRIPTS/docPkgBuilder-scripts/make-vignettes.sh
fi
