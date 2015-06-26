# ------------------------------------------------------------------------------ 
#
#   Creates Python Virtual Python Objects for existing Python Objects.
#
# ------------------------------------------------------------------------------

#  -----------------------------------------------------------
#  pyLend
#  ======
#' @title creates an R representation of an Python object
#'
#' @description The function pyLend  
#' @param key 
#' @details
#' @return Returns the specified Python object converted into an R object if
#'         possible, else a warning is issued and the string representation
#'         of the object is returned.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
# -----------------------------------------------------------
pyLend <- function(key){
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(key)

    pyClass <- pyType(key)
    
    if (is.null(pyClass)){
        stop(sprintf('"%s" does not exist', key))
    }

    if ( pyClass %in% c("bool", "int", "long", "float", "str", "bytes", "unicode")){
        return(pyGet(key))
    }else if (pyIsCallable(key)){
        return(pyFunction(key))
    }else if ( pyClass == "tuple" ){
        return(pyTuple(key, regFinalizer = FALSE))
    }else if ( pyClass == "list" ){
        return(pyList(key, regFinalizer = FALSE))
    }else if ( pyClass == "dict" ){
        return(pyDict(key, regFinalizer = FALSE))
    }else{
        return(pyObject(key, regFinalizer = FALSE))
    }

}