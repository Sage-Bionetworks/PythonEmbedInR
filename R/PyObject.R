## ----------------------------------------------------------------------------- 
##
##   PythonObjects
##
##  
## -----------------------------------------------------------------------------

pyObjectFinalize <- function(self){
    pyExec(sprintf("del(%s)", self$py.variableName))
}

##callFun <- '
##function(...){
##  if (missing(...)){
##    pyCall("%s.%s")
##  }else{
##    x <- as.list(...)
##    if (is.null(names(x))){
##      pyCall("%s.%s", args=x)
##    }else{
##      pyCall("%s.%s", kwargs=x)
##    }
##  }
##}
##'
##callFun2 <- '
##function(...){
##  if (missing(...)){
##    pyCall("%s")
##  }else{
##    x <- as.list(...)
##    if (is.null(names(x))){
##      pyCall("%s", args=x)
##    }else{
##      pyCall("%s", kwargs=x)
##    }
##  }
##}
##'

## TODO: Needs more testing but works fine for now.
##callFun2 <- '
##function(...){
##  x <- list(...)
##  i <- if ( !is.null(names(x)) ) (nchar(names(x)) > 0) else rep(FALSE, length(x))
##  xargs <- if ( sum(!i) > 0 ) x[!i] else NULL
##  xkwargs <- if ( sum(i) > 0 ) x[i] else NULL
##  pyCall("%s", args=xargs, kwargs=xkwargs)
##}
##'

callFun <- '
function(...){
  x <- list(...)
  i <- if ( !is.null(names(x)) ) (nchar(names(x)) > 0) else rep(FALSE, length(x))
  xargs <- if ( sum(!i) > 0 ) x[!i] else NULL
  xkwargs <- if ( sum(i) > 0 ) x[i] else NULL
  pyCall("%s", args=xargs, kwargs=xkwargs)
}
'

activeFun <- '
function(value){
    if (missing(value)){
        return(pyLend("%s.%s"))
    }else{
        pySet("%s", value, "%s")
    } 
}
'

activeFun0 <- '
function(value){
    if (missing(value)){
        return(pyLend("%s"))
    }else{
        pySet("%s", value)
    } 
}
'

## In Python try except is faster than if.
pyGetName <- function(x){
    pyExecg(sprintf('
try:
    x = %s.__name__
except:
    x = None
', x))[['x']]
}

pyObject <- function(variableName, regFinalizer = TRUE){
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(variableName)

    objectName <- pyGetName(variableName)
    type <- pyType(variableName)

    pyMethods <- list()
    pyActive <- list()
    
    pydir <- pyDir(variableName)
    for (o in pydir){
        po <- paste(c(variableName, o), collapse=".")
        if (pyIsCallable(po)){
            ##cat("function:", o , "\n")
            cfun <- sprintf(callFun, paste(variableName, o, collapse="."))
            ##pyobject$set("public", o, eval(parse(text=fun)))
            pyMethods[[o]] <- eval(parse(text=cfun))
        }else{
            ##cat("active:", o , "\n")
            afun <- sprintf(activeFun, variableName, o, o, variableName)
            pyActive[[o]] <- eval(parse(text=afun))
        }
    }

    ## Choose names with a '.' since a point would violate the python
    ## name convention! This leaves me to take care of initialize and
    ## print where I can't chane the name. Therefore if a object 
    ## has a member with the name print it is renamed to py.print
    ## and initialize to py.initialize
    for (n in c("print", "initialize")){
        names(pyMethods)[names(pyMethods) == n] <- sprintf("py.%s", n)
        names(pyActive)[names(pyActive) == n] <- sprintf("py.%s", n)
    }

    if ( (!is.null(objectName)) & (!is.null(type)) ){
        className <- sprintf("%s.%s", type, objectName)
    }else if (is.null(objectName)){
        className <- type
    }else if (is.null(type)){ # should never happen since everything should have a type
        className <- objectName
    }else{
        className <- "?"
    }

    if (regFinalizer){
        pyobject <- R6Class(className,
                    portable = TRUE,
                    inherit = PythonInR_Object,
                    public = pyMethods,
                    active = pyActive)
    }else{
        pyobject <- R6Class(className,
                    portable = TRUE,
                    inherit = PythonInR_ObjectNoFinalizer,
                    public = pyMethods,
                    active = pyActive)
        class(pyobject) <- class(pyobject)[-2]
    }

    pyobject$new(variableName, objectName, type)
}

PythonInR_Object <- R6Class(
    "PythonInR_Object",
    public=list(
        portable=TRUE,
        py.variableName=NA,
        py.objectName="",
        py.type="",
        py.del = function(){
            pyExec(sprintf("del(%s)", self$py.variableName))
        },
        initialize = function(variableName, objectName, type) {
            if (!missing(variableName)) self$py.variableName <- variableName
            if (!missing(objectName)) self$py.objectName <- objectName
            if (!missing(type)) self$py.type <- type
            reg.finalizer(self, pyObjectFinalize, onexit = TRUE)
        },
        # #print = function(){pyExecp(self$py.variableName)}
        ## This should better handle unicode.
        print = function() pyPrint(self$py.variableName)
        ))

PythonInR_ObjectNoFinalizer <-
    R6Class("PythonInR_Object",
            portable = TRUE,
            inherit = PythonInR_Object,
            public = list(
                initialize = function(variableName, objectName, type) {
                    if (!missing(variableName)) self$py.variableName <- variableName
                    if (!missing(objectName)) self$py.objectName <- objectName
                    if (!missing(type)) self$py.type <- type
                }
            ))

pyFunction <- function(variableName){
    cfun <- sprintf(callFun, variableName)
    eval(parse(text=cfun))
}

print.pyFunction <- function(x, ...) pyExecp(attr(x, "name"))