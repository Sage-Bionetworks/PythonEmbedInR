.onLoad <- function(libname, pkgname) {
  # at the compile time a flag is set which can
  # be accessed by using the function isDllVersion 
  #TODO: handle Windows
  Sys.setenv(PYTHONHOME=system.file(package="PythonInR"))
  Sys.setenv(PYTHONPATH=system.file("lib", package="PythonInR"))

  # Unloading it and then reloading it is a hacky way of making less modifications to the original code:
  # In the NAMESPACE file, we load load PythonInR.so with "useDynLib(PythonInR)"
  # However, the symbols are not loaded globally(RTLD_GLOBAL) and will cause issues
  # when importing python packages.
  # If we were to simply remove the "useDynLib(PythonInR)" in NAMESPACE and load it here instead of unload/load
  # Then every .Call() function to a function defined would have to be rewritten e.g.:
  # .Call( "isDllVersion") ======> .Call( "isDllVersion", PACKAGE="PythonInR")
  # Reference: http://r.789695.n4.nabble.com/question-re-error-message-package-error-quot-functionName-quot-not-resolved-from-current-namespace-td4663892.html
  library.dynam.unload("PythonInR", system.file(package="PythonInR"))
  library.dynam( "PythonInR", pkgname, libname, local=FALSE)
  
  if ( !.Call( "isDllVersion") ){
      pyConnect()
  } else if ( nchar(Sys.getenv('PYTHON_EXE')) > 0 ) {
  	  pyConnect(pythonExePath=Sys.getenv('PYTHON_EXE'))
  }
  
  invisible(NULL)
}

.onUnload <- function( libpath ){
  pyExit()
  library.dynam.unload( "PythonInR", libpath )
}

