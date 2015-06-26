# ------------------------------------------------------------------------------ 
#
#   PyGet (New Reference)
#
# ------------------------------------------------------------------------------

#  -----------------------------------------------------------
#  pyGet
#  =====
#' @title gets Python objects by name and transforms them into R objects
#'
#' @description The function pyGet gets Python objects by name and transforms 
#'              them into R objects. 
#' @param key a string specifying the name of a Python object.
#' @param simplify an optional logical value, if TRUE R converts Python lists 
#'        into R vectors whenever possible, else it translates Python lists 
#'        always into R lists.
#' @details Since any Python object can be transformed into one of the basic 
#'          data types it is up to the user to do so up front. More information
#'          about the type conversion can be found in the README file or at
#'          \url{http://pythoninr.bitbucket.org/}. \cr
#' @note pyGet always returns a new object, if you want to create a R representation
#'       of an existing Python object please use pyLend.
#'       PyObject, PyTuple, PyList, PyDict, PyFunction
#' @return Returns the specified Python object converted into an R object if
#'         possible, else a warning is issued and the string representation
#'         of the object is returned.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' pyGet("__name__")
#' pyGet("sys.path")
#' pyExec("
#' from datetime import date
#' today = date.today()
#' ")
#' pyExecp("today")
#' pyPrint("today")
#' pyGet("today")
# -----------------------------------------------------------
pyGet <- function(key, autoTypecast=TRUE, simplify=TRUE){
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(key)

    pyClass <- pyExecg(sprintf("try:\n\tx=type(%s).__name__\nexcept:\n\tx=None", key))[['x']]
    class(pyClass) <- pyClass

    if (getOption("winPython364")){
        # TODO: Test this!
        x <- tryCatch(pyGetPoly(key, autoTypecast, simplify, pyClass), 
                      error = function(e) e, 
                      finally = {msg <- makeErrorMsg()
                                 if (!is.null(msg)) stop(msg)})
    }else{
        x <- pyGetPoly(key, autoTypecast, simplify, pyClass)
    }

    return(pyTransformReturn(x))
}

pyGetSimple <- function(key, autoTypecast=TRUE, simplify = TRUE){
  .Call("PythonInR_Run_String", key, 258L, autoTypecast, FALSE, FALSE, 1L, simplify)
}

pyGetPoly <- function(key, autoTypecast, simplify, pyClass){
  pyGetSimple(key, autoTypecast, simplify)
}

setGeneric("pyGetPoly")

setClass("PrVector")
setMethod("pyGetPoly", signature(key = "character", autoTypecast = "logical", simplify = "logical", pyClass = "PrVector"),
          function(key, autoTypecast, simplify, pyClass){
    x <- pyExecg(sprintf("x = %s.toDict()", key), autoTypecast = autoTypecast, simplify = simplify)[['x']]
    y <- setNames(x[['vector']], x[['names']])
    if (is.null(y)) class(y) <- x[['rClass']]
    y
})

setClass("PrMatrix")
setMethod("pyGetPoly", signature(key="character", autoTypecast = "logical", simplify = "logical", pyClass = "PrMatrix"),
          function(key, autoTypecast, simplify, pyClass){
    x <- pyExecg(sprintf("x = %s.toDict()", key), autoTypecast = autoTypecast, simplify = simplify)[['x']]
    M <- do.call(rbind, x[['matrix']])
    rownames(M) <- x[['rownames']]
    colnames(M) <- x[['colnames']]
    return(M)
})

setClass("ndarray")
setMethod("pyGetPoly", signature(key="character", autoTypecast = "logical", simplify = "logical", pyClass = "ndarray"),
          function(key, autoTypecast, simplify, pyClass){
    x <- pyExecg(sprintf("x = %s.tolist()", key), autoTypecast = autoTypecast, simplify = simplify)[['x']]
    return( do.call(rbind, x) )
})

setClass("PrDataFrame")
setMethod("pyGetPoly", signature(key="character", autoTypecast = "logical", simplify = "logical", pyClass = "PrDataFrame"),
          function(key, autoTypecast, simplify, pyClass){
    x <- pyExecg(sprintf("x = %s.toDict()", key), autoTypecast = autoTypecast, simplify = simplify)[['x']]
    df <- as.data.frame(unname(x['data.frame']), stringsAsFactors=FALSE)
    rownames(df) <- x[['rownames']]
    return(df)
})

setClass("DataFrame")
setMethod("pyGetPoly", signature(key="character", autoTypecast = "logical", simplify = "logical", pyClass = "DataFrame"),
          function(key, autoTypecast, simplify, pyClass){
    x <- pyExecg(sprintf("x = %s.to_dict()", key), autoTypecast = autoTypecast, simplify = simplify)[["x"]]
    return( as.data.frame(x, stringsAsFactors=FALSE) )
})
