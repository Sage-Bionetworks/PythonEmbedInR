# ------------------------------------------------------------------------------ 
#
#   Utility.r
#
# ------------------------------------------------------------------------------

pyIsCallable <- function(x){
    ## TODO: Test for 3 <= python < 3.2
    ## NOTE: I don't use try execpt since I wan't to see
    ##       the error if one occurs
    pyGet(sprintf('callable(%s)', x))
}

## if it exists it should have a type
pyVariableExists <- function(key){
cmd <- '
try:
    x = type(%s)
    x=True
except:
    x=False
'
    pyExecg(sprintf(cmd, key))[['x']]
}

## a small function to check if a variable name or a expression
isVariableName <- function(x){
    x = gsub("^[a-zA-Z\\_][a-zA-Z0-9\\_\\.]*", "", x, perl=TRUE)
    nchar(x) == 0
}

isBasic <- function(x){
    if (!is.null(dim(x))) return(FALSE)
    if (length(x) > 1) return(FALSE)
    if (is.list(x)) return(FALSE)
    TRUE
}

## variable
## variable name
## sollType
checkType <- function(penv, parentInfo, ...){
    x <- list(...)
    nam <- names(x)
    type <- as.character(x)
    b <- nam %in% ls(penv)
    if ( !all(b) ){
        varNames <- paste(nam[!b], collapse="', '")
        stop("the following variable names could not be found '",
             varNames, "'", call.=FALSE)
    }
    errMsg <- "in %s: argument '%s' must be of type 's'"
    for (i in 1:length(nam)){
        if (! inherits(penv[[nam[i]]], type[i]) ){
            stop(sprintf(errMsg, parentInfo, nam[i], type[i]), call.=FALSE)
        }
    }
    return(NULL)
}

# check_string 
#    checks the provided
## TODO: (change this to something nicer)
##       the function is not conistent any more
check_string <- function(x, minlen=1){
    vname <- deparse(substitute(x))
    errMes <- sprintf('argument "%s" must be a character vector of length 1', vname)
    if ( typeof(x) !=  "character" | length(x) != 1) stop(errMes)
    errMes <- sprintf('argument "%s" must have at least %i character', vname, minlen)
    if ( nchar(x) < minlen) stop(errMes)
}

# printStoutErr
#     Is a small work around which fixes the issue with Python 3 64-bit and MinGW
makeErrorMsg <- function(){
    err = pyGetSimple('__getStderr()')
    if ( !is.null(err) ){
        if (nchar(err) > 0){
            # compile a error message and raise an error
            return(paste(c("", sprintf("   %s", unlist(strsplit(err, '\n')))), collapse="\n"))
        }
    }
    return(NULL)
}

guessDllVersion <- function(dllPath){
    f <- file(dllPath, "rb")
    if (readChar(f, 2) != "MZ") return(-2)
    seek(f, 60, rw="rb")
    b = readBin(f, "raw", 4)
    header_offset <- unpack("V", b)[[1]]
    seek(f, header_offset+4, rw="rb")
    b = readBin(f, "raw", 2)
    bv <- unpack("V", b)[[1]]
    bit <- -1
    if (bv %in% c(332)){
        bit <- 32
    }else if (bv %in% c(512, 34404)){
        bit <- 64
    }
    close(f)
    return(bit)
}

# Guess the path to python.exe utilizing the locations in 
# the environment variable path.
# Returns: A character vector containing candidates, on success
#          NULL otherwise.
guessPythonExePathEnvironmentVariables <- function(){
    pythonExePaths <- NULL
    path <- unlist(strsplit(Sys.getenv("PATH"), ";", fixed=TRUE))
    pyCandidates <- grep("python", path, value=TRUE, ignore.case=TRUE)
	if (length(pyCandidates) == 0) return(NULL)
    fun <- function(x) any(grepl("^python.exe", dir(x), ignore.case=TRUE))
    b <- sapply(pyCandidates, fun)
    pyCandidates <- pyCandidates[b]
    if (sum(b) > 0){
        # some one could get the idea to rename python.exe to Python.exe
        fun <- function(x) grep("^python.exe", dir(x), ignore.case=TRUE, value=TRUE)
        pyExeNames <- sapply(pyCandidates, fun)
        pythonExePaths <- normalizePath(file.path(pyCandidates, pyExeNames))
    }
    pythonExePaths
}

getPandasDataFrame <- function(key){
  pyExec(sprintf("x = %s.to_dict(orient='list')", key))
  return( as.data.frame(pyGet("x"), optional=TRUE, stringsAsFactors=FALSE) )
}

getOrderedDict <- function(key){
  pyExec(sprintf("keys = list(%s.keys())", key))
  pyExec(sprintf("values = list(%s.values())", key))
  keys <- pyGet("keys")
  values <- pyGet("values")
  names(values) <- keys
  return(values)
}

# ------------------------------------------------------------------------------
#
#   Helpers for wrapping python functions
#
# ------------------------------------------------------------------------------

#' Determines args and kwargs
#'
#' This function determines args and kwargs for a given list of values.
#'
#' @param ... the input values
#' @return A list of args and kwargs
determineArgsAndKwArgs <- function(...) {
  values <- list(...)
  valuenames <- names(values)
  n <- length(values)
  args <- list()
  kwargs <- list()
  if (n > 0) {
    positionalArgument <- TRUE
    for (i in 1:n) {
      if (is.null(valuenames) || length(valuenames[[i]]) == 0 || nchar(valuenames[[i]]) == 0) {
        # it's a positional argument
        if (!positionalArgument) {
          stop("positional argument follows keyword argument")
        }
        if (is.null(values[[i]])) {
          # inserting a value into a list at best is a no-op, at worst removes an existing value
          # to get the desired insertion we must wrap it in a list
          args[length(args) + 1] <- list(NULL)
        } else {
          args[[length(args) + 1]] <- values[[i]]
        }
      } else {
        # It's a keyword argument.  All subsequent arguments must also be keyword arg's
        positionalArgument <- FALSE
        # a repeated value will overwite an earlier one
        if (is.null(values[[i]])) {
          # inserting a value into a list at best is a no-op, at worst removes an existing value
          # to get the desired insertion we must wrap it in a list
          kwargs[valuenames[[i]]] <- list(NULL)
        } else {
          kwargs[[valuenames[[i]]]] <- values[[i]]
        }
      }
    }
  }
  list(args = args, kwargs = kwargs)
}

#' Clean up stack trace
#'
#' This function clean up stack trace for a callable.
#'
#' @param callable the callable to be called
#' @param args the input to be passed to callable
#' @return the result of calling callable with args after cleaning up the stack trace
cleanUpStackTrace <- function(callable, args) {
  conn <- textConnection("outputCapture", open = "w")
  sink(conn)
  tryCatch({
    result <- do.call(callable, args)
    sink()
    close(conn)
    cat(paste(outputCapture, collapse = ""))
    result
  },
  error = function(e) {
    sink()
    close(conn)
    errorToReport <- paste(c(outputCapture, e$message), collapse = "\n")
    if (!getOption("verbose")) {
      # extract the error message
      splitArray <- strsplit(errorToReport, "exception-message-boundary", fixed = TRUE)[[1]]
      if (length(splitArray) >= 2) errorToReport <- splitArray[2]
    }
    stop(errorToReport)
  }
  )
}