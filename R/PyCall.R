# ------------------------------------------------------------------------------ 
#
#   PyCall
#
# ------------------------------------------------------------------------------

#  -----------------------------------------------------------
#  pyCall
#  ======
#' @title call a callable Python object from within R
#'
#' @description Call a callable Python object from within R.
#' @param callableObj a character string giving the name of the desired callable 
#'                    Python object.
#' @param args an optional list of arguments passed to the callable. 
#' @param kwargs an optional list of named arguments passed to the callable.
#' @param namespace an optional string specifying the namespace.
#' @param simplify an optional logical value, if TRUE R converts Python lists 
#'                 into R vectors whenever possible, else it translates Python 
#'                 lists always to R lists.
#' @return Returns the result of the function call, converted into an R object.
#' @details The args and kwargs are transformed to Python variables by the 
#'          default conversion. More information about the type conversion can 
#'          be found in the vignette.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' # due changes in Python 3 the namespace name of the builtins differs between
#' # Python 3 and Python 2
#' if (pyIsConnected()){
#'     if (as.integer(pyExecg("x=sys.version[0]")[[1]]) == 2){
#'         pyCall("sum", args=list(1:3))
#'     }else{
#'         pyCall("sum", args=list(1:3))
#'     }
#' }
#' pyExec('
#' def fun(**kwargs):
#'     return([(key, value) for key, value in kwargs.items()])
#' ')
#' pyCall("fun", kwargs=list(a=1, f=2, x=4))
#  -----------------------------------------------------------
pyCall <- function(callableObj, args=NULL, kwargs=NULL, autoTypecast=TRUE, simplify=TRUE){
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(callableObj)
    
    if (getOption("winPython364")){
        returnValue <- try(.Call("py_call_obj", callableObj, args, kwargs, simplify, autoTypecast), 
                           silent=TRUE)
        msg <- makeErrorMsg()
        if (!is.null(msg)) stop(msg)
    }else{
        returnValue <- .Call("py_call_obj", callableObj, args, kwargs, simplify, autoTypecast)
    }
    return(pyTransformReturn(returnValue))
}
