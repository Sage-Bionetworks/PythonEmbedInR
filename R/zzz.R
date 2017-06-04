
pathToPythonLibraries<-function(libname, pkgname) {
	# Note: 'pythonLibs' is defined in configure.win
	pathToPythonLibraries<-file.path(libname, pkgname, "pythonLibs")
	pathToPythonLibraries<-gsub("/", "\\", pathToPythonLibraries, fixed=T)
	pathToPythonLibraries
}

# on Windows we need to add Python dll's to library search path
addPythonLibrariesToWindowsPath<-function(libname, pkgname) {
	if (Sys.info()['sysname']!="Windows") return
	Sys.setenv(PATH=pathToPythonLibraries(libname, pkgname))
}

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
  pyConnect()
  
  
  if (Sys.info()['sysname']=="Linux"){
		sharedObjectFile<-system.file("lib/libpython3.5m.so.1.0", package="PythonEmbedInR")
		if (file.exists(sharedObjectFile)) {
			dyn.load(sharedObjectFile, local=FALSE)
		} else {
			message("Warning: ", sharedObjectFile, " does not exist. Here are the available files:")
			list.files(system.file("lib", package="PythonEmbedInR"))
		}
  }
  invisible(NULL)
}

.onUnload <- function( libpath ){
  pyExit()
  library.dynam.unload( "PythonEmbedInR", libpath )
}

