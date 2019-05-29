#!/bin/bash
##
## build the artifacts and install the package
## for the active R version

set -e
## create the temporary library directory
mkdir -p ../RLIB

## Install required R libraries
echo "try(remove.packages('synapser'), silent=T);" > installReqPkgs.R
echo "list.of.packages <- c('pack', 'R6', 'testthat', 'rjson', 'rlang');" >> installReqPkgs.R
echo "if(length(list.of.packages)) install.packages(list.of.packages, repos='http://cran.fhcrc.org')" >> installReqPkgs.R
R --vanilla < installReqPkgs.R
rm installReqPkgs.R

## export the jenkins-defined environment variables
export label
export RVERS=$(echo $label | awk -F[-] '{print $3}')

PACKAGE_NAME=PythonEmbedInR
# if version is specified, build the given version
if [ -n ${VERSION} ] 
then
  DATE=`date +%Y-%m-%d`
  # replace DESCRIPTION with $VERSION & $DATE
  sed "s|^Version: .*$|Version: $VERSION|g" DESCRIPTION > DESCRIPTION.temp
  sed "s|^Date: .*$|Date: $DATE|g" DESCRIPTION.temp > DESCRIPTION2.temp

  rm DESCRIPTION
  mv DESCRIPTION2.temp DESCRIPTION
  rm DESCRIPTION.temp
fi
export PACKAGE_VERSION=`grep Version DESCRIPTION | awk '{print $2}'`

## Now build/install the package
if [[ $label = $LINUX_LABEL_PREFIX* ]]; then
  ## build the package, including the vignettes
  R CMD build ./

  ## now install it
  R CMD INSTALL ./ --library=../RLIB --no-test-load

  CREATED_ARCHIVE=${PACKAGE_NAME}_${PACKAGE_VERSION}.tar.gz
  
  if [ ! -f ${CREATED_ARCHIVE} ]; then
  	echo "Linux artifact was not created"
  	exit 1
  fi  
elif [[ $label = $MAC_LABEL_PREFIX* ]]; then
  ## build the package, including the vignettes
  # for some reason latex is not on the path.  So we add it.
  export PATH="$PATH:/usr/texbin"
  # make sure there are no stray .tar.gz files
  rm -f ${PACKAGE_NAME}*.tar.gz
  rm -f ${PACKAGE_NAME}*.tgz
  R CMD build ./
  # now there should be exactly one ${PACKAGE_NAME}*.tar.gz file

  ## build the binary for MacOS
  for f in ${PACKAGE_NAME}_${PACKAGE_VERSION}.tar.gz
  do
     R CMD INSTALL --build "$f" --library=../RLIB --no-test-load
  done

  ## Now fix the binaries, per SYNR-341:
  # it's v 3.0 or greater, with just one platform
  mkdir -p ${PACKAGE_NAME}/libs
  cp ../RLIB/${PACKAGE_NAME}/libs/PythonEmbedInR.so ${PACKAGE_NAME}/libs
  install_name_tool -change "/Library/Frameworks/R.framework/Versions/$RVERS/Resources/lib/libR.dylib"  "/Library/Frameworks/R.framework/Versions/Current/Resources/lib/libR.dylib" ${PACKAGE_NAME}/libs/PythonEmbedInR.so


  # update archive with modified binaries
  for f in *.tgz
  do
	prefix="${f%.*}"
	gunzip "$f"
	# Note, >=3.0 there is only one platform
	tar -rf "$prefix".tar ${PACKAGE_NAME}/libs/PythonEmbedInR.so
	rm "$prefix".tar.gz
	gzip "$prefix".tar
	mv "$prefix".tar.gz "$prefix".tgz
  done

  ## Following what we do in the Windows build, remove the source package if it remains
  set +e
  rm ${PACKAGE_NAME}*.tar.gz
  set -e

  CREATED_ARCHIVE=${PACKAGE_NAME}_${PACKAGE_VERSION}.tgz

  if [ ! -f  ${CREATED_ARCHIVE} ]; then
  	echo "osx artifact was not created"
  	exit 1
  fi  
elif  [[ $label = $WINDOWS_LABEL_PREFIX* ]]; then
  export TZ=UTC
  echo TZ=$TZ

  ## build the package, including the vignettes
  # for some reason latex is not on the path.  So we add it.
  export PATH="$PATH:/cygdrive/c/Program Files/MiKTeX 2.9/miktex/bin/x64:/cygdrive/c/Program Files/MiKTeX 2.9/miktex/bin/i386"
  echo $PATH
  # make sure there are no stray .tar.gz files
  # 'set +e' keeps the script from terminating if there are no .tgz files
  set +e
  rm ${PACKAGE_NAME}*.tar.gz
  rm ${PACKAGE_NAME}*.tgz
  set -e
  R CMD build ./
  # now there should be exactly one ${PACKAGE_NAME}*.tar.gz file

  ## build the binary for Windows
  for f in ${PACKAGE_NAME}_${PACKAGE_VERSION}.tar.gz
  do
     R CMD INSTALL --build "$f" --library=../RLIB --no-test-load --merge-multiarch
  done
  ## This is very important, otherwise the source packages from the windows build overwrite 
  ## the ones created on the unix machine.
  rm -f ${PACKAGE_NAME}*.tar.gz

  CREATED_ARCHIVE=${ZIP_TARGET_NAME}

  if [ ! -f  ${CREATED_ARCHIVE} ]; then
  	echo "Windows artifact was not created"
  	exit 1
  fi  
else
  echo "*** UNRECOGNIZED LABEL: $label ***"
  exit 1
fi

echo ".libPaths(c('../RLIB', .libPaths()));" > runTests.R
echo "setwd(sprintf('%s/tests', getwd()));" >> runTests.R
echo "source('testthat.R')" >> runTests.R
echo "library(PythonEmbedInR);" >> runTests.R
echo "detach(\"package:PythonEmbedInR\", unload=TRUE);" >> runTests.R
echo "library(PythonEmbedInR)" >> runTests.R
R --vanilla < runTests.R
rm runTests.R

## clean up the temporary R library dir
rm -rf ../RLIB