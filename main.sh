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
rm -rf `echo $JOB_NAME|cut -d / -f 1`

rm -f $WORKSPACE/*.tar.gz
$HOME_OF_R/bin/Rscript $BUILDER_SCRIPTS/docPkgBuilder-scripts/prerun.R
echo "workspace is $WORKSPACE"
echo ">>> Running R CMD build:"
#$HOME_OF_R/bin/R CMD build $WORKSPACE
# remove this:
$HOME_OF_R/bin/R CMD build --no-vignettes $WORKSPACE
echo "about to cd to check dir"
cd $CHECK_DIR
echo "should be in check dir"
##echo ">>> Running R CMD check:"
##$HOME_OF_R/bin/R CMD check --no-vignettes $WORKSPACE/*.tar.gz
echo "about to cd to workspace"
cd $WORKSPACE
echo "should be in workspace"
rm -rf $CHECK_DIR

if [ "$NODE_NAME" = "master" ]; then
    bash $BUILDER_SCRIPTS/docPkgBuilder-scripts/make-vignettes.sh
fi
