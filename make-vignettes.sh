#!/bin/bash

set -e

killall Xvfb || true
killall Xvfb || true
killall Xvfb || true
echo "killed those processes, now starting X"
. /var/lib/jenkins/start-virtual-X.sh > /dev/null 2>&1
    
## redundant bit:
echo ">>> Running R CMD build:"
$HOME_OF_R/bin/R CMD build $WORKSPACE
# remove this:
#$HOME_OF_R/bin/R CMD build --no-vignettes $WORKSPACE
cd $CHECK_DIR
##echo ">>> Running R CMD check:"
##$HOME_OF_R/bin/R CMD check --no-vignettes $WORKSPACE/*.tar.gz
cd $WORKSPACE
rm -rf $CHECK_DIR
## end of redundant bit


echo "workspace is $WORKSPACE"
cd $WORKSPACE
rm -rf library
mkdir library
#R_LIBS_USER=$WORKSPACE/library 
echo ">>> Running R CMD INSTALL..."
$HOME_OF_R/bin/R CMD INSTALL --library=library $WORKSPACE/*.tar.gz

tar zxf *.tar.gz
export pkg=`echo *.tar.gz | cut -d _ -f 1`
rm -rf $pkg.Rcheck
cd $pkg
if [ -d "vignettes" ]; then
    cd vignettes
else
    if [ -d "inst/doc" ]
    then
        cd inst/doc
    else
        echo ">>> ERROR: There are no vignettes in this package!"
        exit 1
    fi
fi
for i in `ls *.Rmd`
do
    #R_LIBS_USER=$WORKSPACE/library 
    echo ">>> Building $i..."
    $HOME_OF_R/bin/R --vanilla -q -e "library(knitr);.libPaths(c(file.path(Sys.getenv('WORKSPACE'),'library'), .libPaths()));knit('$i')"
done
killall Xvfb || true
killall Xvfb || true
killall Xvfb || true

rm -f *.Rmd
tar zcf $WORKSPACE/$pkg-vignettes.tar.gz .
cp $WORKSPACE/$pkg-vignettes.tar.gz ~/docbuilder-output
echo ">>> Vignette tarball has been created in the following location:"
echo ">>> http://docbuilder.bioconductor.org/docbuilder/$pkg-vignettes.tar.gz"
