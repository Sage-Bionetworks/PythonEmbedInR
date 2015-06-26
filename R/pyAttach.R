#  -----------------------------------------------------------
#  pyAttach
#  ========
#' @title attach Python objects to an R environment
#' @description A convenience function to attach Python objects to an R environment.
#'
#' @param what a character vector the names which should be attached to R.
#' @param env the environment where he virtual Python objects are 
#'            assigned to.
#'
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
# -----------------------------------------------------------
pyAttach <- function(what, env = parent.frame()){
  if ( pyConnectionCheck() ) return(invisible(NULL))
  checkType(environment(), "pyAttach", what="character", env="environment")
  
  for (w in what){
    if (!pyVariableExists(w)) stop(w, "doesn't exist")
  }

  for (o in what){
    po <- o
    print(po)
    spo <- unlist(strsplit(po, split = ".", fixed = TRUE))

    if (length(spo) == 1){
      variableName <- po
      o <- NULL
    }else{
      variableName <- paste(spo[-length(spo)], collapse=".")
      o <- spo[length(spo)] 
    }
    
    if (pyIsCallable(po)){ # callable functions
      cfun <- sprintf(callFun, po)
      print("assignFun")
      assign(po, eval(parse(text=cfun)), envir=env)
    }else{ # active binding functions
      if (is.null(o)){
        afun <- sprintf(activeFun0, variableName, variableName)
      }else{
        afun <- sprintf(activeFun, variableName, o, o, variableName)
        print(afun)
      }
      print("makeActiveBinding")
      makeActiveBinding(po, eval(parse(text=afun)), env=env)
    }
  }
}

## new version
## pyPolluteSearchPath <- function(variableName, exports, env=parent.env(environment())){
##    ns <-makeNamespace(sprintf("python:%s", variableName))
##    pydir <- pyDir(variableName)
## 
##    actBind <- NULL
##    for (o in pydir){
##        po <- paste(c(variableName, o), collapse=".")
##        if (pyIsCallable(po)){ # callable functions
##            cfun <- sprintf(callFun, variableName, o, variableName, o, variableName, o)
##            assign(po, eval(parse(text=cfun)), envir=ns)
##        }else{ # active binding functions
##            afun <- sprintf(activeFun, variableName, o, o, variableName)
##            makeActiveBinding(po, eval(parse(text=afun)), env=ns)
##            actBind <- c(po, actBind)
##        }
##    }
## 
##    if (is.null(exports)){
##        namespaceExport(ns, ls(ns))
##    }else{
##        namespaceExport(ns, exports)
##    }
##    env <- attachNamespace(ns)
##    for (acb in actBind) unlockBinding(acb, env)
##    invisible(NULL)
## }

## pyPolluteSearchPath <- function(variableName, exports){
##     ## http://r.789695.n4.nabble.com/Active-bindings-in-attached-environments-td920310.html
##     pydir <- pyDir(variableName)
##     py <- new.env()
##     for (o in pydir){
##         po <- paste(c(variableName, o), collapse=".")
##         if (pyIsCallable(po)){ # callable functions
##             cfun <- sprintf(callFun, variableName, o, variableName, o, variableName, o)
##             assign(po, eval(parse(text=cfun)), env=py)
##         }else{ # active binding functions
##             afun <- sprintf(activeFun, variableName, o, o, variableName)
##             makeActiveBinding(po, eval(parse(text=afun)), env=py)
##             #lockBinding(po, ns)
##         }
##     }

##     ## (TODO is commented out): add error checks
##     py2 <- new.env()
##     attach( py2, pos = 2L , name=sprintf("python:%s", variableName))
##     .Internal(importIntoEnv( as.environment(2L), ls(py), py, ls(py) ))
## }
