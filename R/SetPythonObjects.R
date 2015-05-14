# ------------------------------------------------------------------------------ 
#
#   SetPythonObjects
#
# ------------------------------------------------------------------------------

#  ---------------------------------------------------------
#  pySet
#  =====
#' @title assign R objects to Python
#'
#' @description The function pySet allows to assign R objects to the Python 
#'              namespace, the conversion from R to Python is done automatically.
#' @param key a string specifying the name of the Python object.
#' @param value an R object which is assigned to Python. 
#' @param useNumpy an optional logical, default is FALSE, to control if numpy 
#'                 should be used for the type conversion of matrices.
#' @param usePandas an optional logical, default is FALSE, to control if pandas 
#'                  should be used for the type conversion of data frames.
#' @details More information about the type conversion can be found in the README 
#'          file or at \url{http://pythoninr.bitbucket.org/}.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' pySet("x", 3)
#' pySet("M", diag(1,3))
#  ---------------------------------------------------------
pySet <- function(key, value,
                   useNumpy=getOption("useNumpy"),
                   usePandas=getOption("usePandas")){
    namespace <- "__main__" #NOTE: I fixed it since I never used it
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(key)
    splittedName <- unlist(strsplit(key, ".", fixed=TRUE))
    rclass <- class(value)
    if (rclass %in% c("matrix", "data.frame")){
        rnam <- rownames(value)
        rownames(value) <- NULL
        xdim <- dim(value)
        if ( rclass == "matrix" ){
            if (useNumpy){
                success <- .Call("py_assign", namespace, splittedName, key, t(value))
                cmd <- sprintf("%s = %s.array(%s).reshape(%i,%i)",
                               key, getOption("numpyAlias"), key, xdim[1], xdim[2])
                pyExec(cmd)
                return( invisible( success ) )
            }else{
                cnam <- colnames(value)
                colnames(value) <- NULL
                value <- apply(value, 1, function(x) as.list(x))
                value <- list(matrix=value, rownames=rnam, colnames=cnam, dim=xdim)
            }
        }else if (rclass == "data.frame"){
            value <- list(data.frame=lapply(value, "["), rownames=rnam, dim=xdim)
            if (usePandas){
                success <- .Call("py_assign", namespace, splittedName, key, value)
                cmd <- sprintf("%s = %s.DataFrame(%s['data.frame'], index=%s['rownames'])",
                               key, getOption("pandasAlias"), key, key)
                pyExec(cmd)
                return( invisible( success ) )
            }
        }
    }
    if (getOption("winPython364")){
        success <- try(.Call("py_assign", namespace, splittedName, key, value), silent = TRUE)
        msg <- makeErrorMsg()
        if (!is.null(msg)) stop(msg)
    }else{
        success <- .Call("py_assign", namespace, splittedName, key, value)
    }
    
    invisible(success)
}

