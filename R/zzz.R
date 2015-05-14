.onLoad <- function(libname, pkgname) {
  op <- options()
  op.PythonInR <- list(
    numpyAlias="numpy",
    useNumpy=FALSE,
    pandasAlias="pandas",
    usePandas=FALSE,
    winPython364=FALSE
  )
  toset <- !(names(op.PythonInR) %in% names(op))
  if(any(toset)) options(op.PythonInR[toset])

  # at the compile time a flag is set which can
  # be accessed by using the function isDllVersion 
  if ( !.Call( "isDllVersion") ){
      pyConnect()
  }
  
  invisible(NULL)
}

