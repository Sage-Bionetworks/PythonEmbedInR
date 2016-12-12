.onLoad <- function(libname, pkgname) {
  # at the compile time a flag is set which can
  # be accessed by using the function isDllVersion 
  #TODO: handle Windows
  Sys.setenv(PYTHONHOME=system.file(package="PythonInR"))
  Sys.setenv(PYTHONPATH=system.file("lib", package="PythonInR"))
  library.dynam.unload("PythonInR", "/Library/Frameworks/R.framework/Versions/3.3/Resources/library/PythonInR")
  library.dynam( "PythonInR", pkgname, libname, local=FALSE)
  
  if ( !.Call( "isDllVersion") ){
      pyConnect()
  } else if ( nchar(Sys.getenv('PYTHON_EXE')) > 0 ) {
  	  pyConnect(pythonExePath=Sys.getenv('PYTHON_EXE'))
  }
  
  invisible(NULL)
}

