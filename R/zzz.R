
pathToPythonLibraries<-function(libname, pkgname) {
	# Note: 'pythonLibs' is defined in configure.win
	pathToPythonLibraries<-file.path(libname, pkgname, "pythonLibs")
	pathToPythonLibraries<-gsub("/", "\\", pathToPythonLibraries, fixed=T)
	pathToPythonLibraries
}

# on Windows we need to add Python dll's to library search path
addPythonLibrariesToWindowsPath<-function(libname, pkgname) {
	if (Sys.info()['sysname']!="Windows") return
	extendedPath <- sprintf("%s%s%s", Sys.getenv("PATH"), .Platform$path.sep, pathToPythonLibraries(libname, pkgname))
	Sys.setenv(PATH=pathToPythonLibraries(libname, pkgname))
	# TODO uncomment the following, to fix SYNR-1132
	#Sys.setenv(PATH=extendedPath)
}

# NOTE:  This is one of several places the version is hard coded.  See also AutodetectPython.R, configure, configure.win 
PYTHON_VERSION<-"3.5"

.onLoad <- function(libname, pkgname) {
  # at the compile time a flag is set which can
  # be accessed by using the function isDllVersion 
  addPythonLibrariesToWindowsPath(libname, pkgname)
  Sys.setenv(PYTHONHOME=system.file(package="PythonEmbedInR"))
  Sys.setenv(PYTHONPATH=system.file("lib", package="PythonEmbedInR"))
  
  # Unloading it and then reloading it is a hacky way of making less modifications to the original code:
  # In the NAMESPACE file, we load load PythonInR.so with "useDynLib(PythonInR)"
  # However, the symbols are not loaded globally(RTLD_GLOBAL) and will cause issues
  # when importing python packages.
  # If we were to simply remove the "useDynLib(PythonInR)" in NAMESPACE and load it here instead of unload/load
  # Then every .Call() function to a function defined would have to be rewritten e.g.:
  # .Call( "isDllVersion") ======> .Call( "isDllVersion", PACKAGE="PythonInR")
  # Reference: http://r.789695.n4.nabble.com/question-re-error-message-package-error-quot-functionName-quot-not-resolved-from-current-namespace-td4663892.html
  library.dynam.unload("PythonEmbedInR", system.file(package="PythonEmbedInR"))
  library.dynam( "PythonEmbedInR", pkgname, libname, local=FALSE)
	
	# On Mac load the ssl libraries
	if (Sys.info()['sysname']=='Darwin') {
		sharedObjectFile<-system.file("lib/libcrypto.1.0.0.dylib", package="PythonEmbedInR")
		dyn.load(sharedObjectFile, local=FALSE)
		sharedObjectFile<-system.file("lib/libssl.1.0.0.dylib", package="PythonEmbedInR")
		dyn.load(sharedObjectFile, local=FALSE)
		Sys.setenv(SSL_CERT_FILE=system.file(paste0("lib/python", PYTHON_VERSION, "/site-packages/pip/_vendor/requests/cacert.pem"), package="PythonEmbedInR"))
	}
	
	pyConnect()
  
  if (Sys.info()['sysname']=="Linux") {
		# if we build a static library, libpythonX.Xm.a, instead of a dynamically linked one,
		# libpythonX.Xm.so.1.0, then don't do the following
		sharedObjectFile<-system.file(paste0("lib/libpython", PYTHON_VERSION, "m.so.1.0", package="PythonEmbedInR"))
		if (file.exists(sharedObjectFile)) {
			dyn.load(sharedObjectFile, local=FALSE)
		}
  }
  invisible(NULL)
}

.onUnload <- function( libpath ){
  pyExit()
  library.dynam.unload( "PythonEmbedInR", libpath )
}

