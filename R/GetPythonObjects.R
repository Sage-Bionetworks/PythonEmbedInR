# ------------------------------------------------------------------------------ 
#
#   GetPythonObjects
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
#' @param namespace an optional string providing the name of the namespace.
#' @param simplify an optional logical value, if TRUE R converts Python lists 
#'        into R vectors whenever possible, else it translates Python lists 
#'        always into R lists.
#' @details Since any Python object can be transformed into one of the basic 
#'          data types it is up to the user to do so up front. More information
#'          about the type conversion can be found in the README file or at
#'          \url{http://pythoninr.bitbucket.org/}.
#' @return Returns the specified Python object converted into an R object if
#'         possible, else a warning is issued and the string representation
#'         of the object is returned.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' pyGet("__name__")
#' pyGet("path", "sys")
#' pyExec("
#' from datetime import date
#' today = date.today()
#' ")
#' pyExecp("today")
#' pyPrint("today")
#' pyGet("today")
# -----------------------------------------------------------
pyGet <- function(key, namespace="__main__", simplify=TRUE){
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(key)
    splittedName <- unlist(strsplit(key, ".", fixed=TRUE))

    # special conversions based on the type
    type <- .Call("py_get_type", splittedName, namespace)
    if ( grepl("pandas.*DataFrame", type) ){
        x <- pyExecg(sprintf("x = %s.to_dict()", key))[["x"]]
        return( as.data.frame(x, stringsAsFactors=FALSE) )
    }
    if ( grepl("numpy", type) ){
        x <- pyExecg(sprintf("x = %s.tolist()", key))[['x']]
        return( do.call(rbind, x) )
    }

    if (getOption("winPython364")){
        x <- try(.Call("py_get", splittedName, namespace, simplify), silent = TRUE)
        msg <- makeErrorMsg()
        if (!is.null(msg)) stop(msg)
    }else{
        x <- .Call("py_get", splittedName, namespace, simplify)
    }   

    if ( is.null(names(x)) ) return(x)

    # special conversions based on the names of the list retrieved
    type2 <- paste(sort(names(x)), collapse="")
    if ( type2 == "colnamesdimmatrixrownames" ){
        M <- do.call(rbind, x[['matrix']])
        rownames(M) <- x[['rownames']]
        colnames(M) <- x[['colnames']]
        return(M)
    }else if( type2 == "data.framedimrownames" ){
        df <- as.data.frame(unname(x['data.frame']), stringsAsFactors=FALSE)
        rownames(df) <- x[['rownames']]
        return(df)
    }

    return(x)
}

