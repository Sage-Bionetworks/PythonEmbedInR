##
## build the artifacts and install the package
## for the active R version

## create the temporary library directory
mkdir -p ../RLIB

## export the jenkins-defined environment variables
export label
export RVERS

PACKAGE_NAME=PythonEmbedInR
# if version is specified, build the given version
if [ -n ${VERSION} ] 
then
	# replace DESCRIPTION with $VERSION
	VERSION_LINE=`grep Version DESCRIPTION`
	sed "s|$VERSION_LINE|Version: $VERSION|g" DESCRIPTION > DESCRIPTION.temp
	rm DESCRIPTION
	mv DESCRIPTION.temp DESCRIPTION
fi
export PACKAGE_VERSION=`grep Version DESCRIPTION | awk '{print $2}'`

## Now build/install the package
if [ $label = ubuntu ] || [ $label = ubuntu-remote ]
then
  ## build the package, including the vignettes
  R CMD build ./

  ## now install it
  R CMD INSTALL ./ --library=../RLIB --no-test-load

  CREATED_ARCHIVE=${PACKAGE_NAME}_${PACKAGE_VERSION}.tar.gz
  
  if [ ! -f ${CREATED_ARCHIVE} ]; then
  	echo "Linux artifact was not created"
  	exit 1
  fi  
elif [ $label = osx ] || [ $label = osx-lion ] || [ $label = osx-leopard ]
then
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
elif  [ $label = windows-aws ]
then
  export TZ=UTC
  echo TZ=$TZ

  ## build the package, including the vignettes
  # for some reason latex is not on the path.  So we add it.
  export PATH="$PATH:/cygdrive/c/Program Files/MiKTeX 2.9/miktex/bin/x64"
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
     R CMD INSTALL --build "$f" --library=../RLIB --no-test-load
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

R -e ".libPaths('../RLIB');\
     library(PythonEmbedInR);\
     pyExec('import platform');\
     result<-pyGet('platform.python_version()');\
     expected<-'3.5.3';\
     if (is.null(result)) stop('Python version is unexpectedly null.');\
     if (length(grep(expected, result))==0) stop(sprintf('Expected %s in the version string but found %s\n', expected, result));\
     cat(sprintf('\n\nPython version string:\n%s\n\n', result));\

     pyImport('pip');\
     pyImport('ssl');\
     pyGet('ssl.OPENSSL_VERSION');\
     
     testPackage<-'ggplot2';\
     try(remove.packages(testPackage), silent=T);\
     install.packages(testPackage, repos='https://cran.cnr.berkeley.edu/');\
     library(testPackage, character.only=T)"

## clean up the temporary R library dir
rm -rf ../RLIB