#  -----------------------------------------------------------
#  pyImport
#  ========
#' @title Import virtual Python objects to R
#'
#' @description A convenience function to call the Python function 
#'              \bold{import} and creating virtual Python objects for
#'              the imported objects in R.
#' @param import a character vector  
#' @param from TODO
#' @param as an optional string defining a alias for the module name.
#' @param env TODO
#' @details The function pyImport has a special behavior for the packages numpy 
#'          and pandas. For these two packages pyImport does not only import 
#'          numpy but also register their alias in the options. To be found when
#'          pyGet and pySet is used with the option useNumpy set to TRUE.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' pyImport("os")
#' \dontrun{
#' #NOTE: The following does not only import numpy but also register the
#' #      alias in the options under the name "numpyAlias". 
#' #      The same is done for pandas, the default alias for pandas and numpy 
#' #      are respectively "pandas" and "numpy". The numpyAlias is used 
#' #      when calling pyGet or pySet with the option useNumpy set to TRUE.
#' pyImport("numpy", "np")
#' pyImport("pandas", "pd")
#' }
# -----------------------------------------------------------
## NOTE: fun <- function(env=parent.env(environment())) would 
##       have a different, in this case not desired behavior!
pyImport <- function(import, from=NULL, as=NULL, env = parent.frame()){
  check_string(import)
  if (!is.null(from)) check_string(from)
  if (!is.null(as)) check_string(as)
  # import 0 | import + as 1 | import + from 2 | import + as + from 3
  mode <- sum((1:2)[c(!is.null(as), !is.null(from))])

  print(env)

  if (mode == 0){
      pyExec(sprintf("import %s", import))
      assign(import, pyGet0(import), envir = env)
  }else if(mode == 1){
      pyExec(sprintf("import %s as %s", import, as))
      if (import=="numpy") options(numpyAlias=as)
      if (import=="pandas") options(pandasAlias=as)
      assign(as, pyGet0(as), envir = env)
  }else if(mode == 2){
      if (length(import) > 1){
          imp <- paste(import, collapse=", ")
          pyExec(sprintf("from %s import %s", from, imp))
          for (imp in import){
              assign(imp, pyGet0(imp), envir = env)  
          }
      }else if(import == "*"){
        stop("'from foo import *' is not allowed in pyImport")
      }else{
          pyExec(sprintf("from %s import %s", from, import))
          assign(import, pyGet0(import), envir = env)
      }
  }else if(mode == 3){
      pyExec(sprintf("from %s import %s as %s", from, import, as))
      assign(as, pyGet0(as), envir = env)
  }else{stop(pi)}
  
  invisible(NULL)
}