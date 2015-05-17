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
    
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(key)

    #NOTE: polyClass is only needed to generate a different behavior when numpy is available
    polyClass <- vector()
    if (useNumpy & (class(value) == "matrix")){
        class(polyClass) <- "ndarray"
    }else if (usePandas & (class(value) == "data.frame")){
        class(polyClass) <- "DataFrame"
    }else if (class(value) == "matrix"){
        # matrix checks if length(attr(x, "dim")) == 2, as soon as 
        # attr(x, "dim") <- c(0,0) class changes from vector to matrix
        polyClass <- matrix()
    }else{
        class(polyClass) <- class(value)
    }

    #print(sprintf("class value: %s", class(value)))
    #print(sprintf("class polyClass: %s", class(polyClass)))
    returnValue <- pySetPoly(key, value, polyClass)
    invisible(returnValue)
}

# pySetSimple is a wrapper over the C function that users can
# ===========
# create new generic functions by using the function PythonInR:::pySetSimple
pySetSimple <- function(key, value){
    namespace <- "__main__" #NOTE: I fixed it since I never used it
    splittedName <- unlist(strsplit(key, ".", fixed=TRUE))
    # returns 0 on success -1 on failure
    .Call("py_assign", namespace, splittedName, key, value)
}

# pySetPoly is a polymorphic function
# =========
# The goal is to provide a part which can easily modified by the user. 
pySetPoly <- function(key, value, polyClass){
    value <- pySetSimple(key, value)
    NULL
}

setGeneric("pySetPoly")

# ----------------------------------------------------------
# vector
# ----------------------------------------------------------
pySetVector <- function(key, value){
    success <- pySetSimple(key, list(vector=unname(value), names=names(value), rClass=class(value)))
    cmd <- sprintf("%s = PythonInR.prVector(%s['vector'], %s['names'], %s['rClass'])", 
                   key, key, key, key)
    pyExec(cmd)
}

# logical
setMethod("pySetPoly", signature(key="character", value = "logical", polyClass = "logical"),
          function(key, value, polyClass) pySetVector(key, value))

# integer
setMethod("pySetPoly", signature(key="character", value = "integer", polyClass = "integer"),
          function(key, value, polyClass) pySetVector(key, value))

# numeric
setMethod("pySetPoly", signature(key="character", value = "numeric", polyClass = "numeric"),
          function(key, value, polyClass) pySetVector(key, value))

# character
setMethod("pySetPoly", signature(key="character", value = "character", polyClass = "character"),
          function(key, value, polyClass) pySetVector(key, value))

# ----------------------------------------------------------
# matrix
# ----------------------------------------------------------
# prMatrix (a pretty reduced matrix class)
# ========
setMethod("pySetPoly", signature(key="character", value = "matrix", polyClass = "matrix"),
          function(key, value, polyClass){
    rnam <- rownames(value)
    cnam <- colnames(value)
    xdim <- dim(value)
    rownames(value) <- NULL
    colnames(value) <- NULL
    value <- apply(value, 1, function(x) as.list(x))
    value <- list(matrix=value, rownames=rnam, colnames=cnam, dim=xdim)
    
    success <- pySetSimple(key, value)

    cmd <- sprintf("%s = PythonInR.prMatrix(%s['matrix'], %s['rownames'], %s['colnames'], %s['dim'])", 
                   key, key, key, key, key)
    pyExec(cmd)
})

# numpy.ndarray
# =============
setClass("ndarray")
setMethod("pySetPoly", signature(key="character", value = "matrix", polyClass = "ndarray"),
          function(key, value, polyClass){
    rownames(value) <- NULL
    colnames(value) <- NULL
    value <- apply(value, 1, function(x) as.list(x))
    
    success <- pySetSimple(key, value)

    cmd <- sprintf("%s = %s.array(%s)",
                   key, getOption("numpyAlias"), key)
    pyExec(cmd)
})

# ----------------------------------------------------------
# data.frame
# ----------------------------------------------------------
# prDataFrame
# ===========
setMethod("pySetPoly", signature(key="character", value = "data.frame", polyClass = "data.frame"),
          function(key, value, polyClass){
    rnam <- rownames(value)
    cnam <- colnames(value)
    xdim <- dim(value)
    rownames(value) <- NULL
    value <- list(data.frame=lapply(value, "["), rownames=rnam, colnames=cnam, dim=xdim)

    success <- pySetSimple(key, value)

    cmd <- sprintf("%s = PythonInR.prDataFrame(%s['data.frame'], %s['rownames'], %s['colnames'], %s['dim'])", 
                   key, key, key, key, key)
    pyExec(cmd)
})

# pandas.DataFrame
# ================
setClass("DataFrame")
setMethod("pySetPoly", signature(key="character", value = "data.frame", polyClass = "DataFrame"),
          function(key, value, polyClass){
    rnam <- rownames(value)
    xdim <- dim(value)
    rownames(value) <- NULL
    value <- list(data.frame=lapply(value, "["), rownames=rnam)

    success <- pySetSimple(key, value)

    cmd <- sprintf("%s = %s.DataFrame(%s['data.frame'], index=%s['rownames'])",
                               key, getOption("pandasAlias"), key, key)
    pyExec(cmd)
})
