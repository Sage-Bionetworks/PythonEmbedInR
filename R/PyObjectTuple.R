##  
##  pyTuple
##
##
##  [TODO] methods like reverse should return a new object
##         or save reversed self!

##
##  PythonInR_Tuple
##      class definition

PythonInR_Tuple <-
    R6Class("PythonInR_Tuple",
            portable = TRUE,
            inherit = PythonInR_Object,
            public = list(
                print = function() pyExecp(self$py.variableName),
                index = function(x){
                    cable <- sprintf("%s.index", self$py.variableName)
                    pyCall(cable, args=list(x))},
                count = function(x){
                    cable <- sprintf("%s.count", self$py.variableName)
                    pyCall(cable, args=list(x))}
                ))

PythonInR_TupleNoFinalizer <-
    R6Class("PythonInR_Tuple",
            portable = TRUE,
            inherit = PythonInR_Tuple,
            public = list(
                initialize = function(variableName, objectName, type) {
                    if (!missing(variableName)) self$py.variableName <- variableName
                    if (!missing(objectName)) self$py.objectName <- objectName
                    if (!missing(type)) self$py.type <- type
                }
            ))

    

`[.PythonInR_Tuple` <- function(x, i){
    pyGet(sprintf("%s[%s]", x$py.variableName, deparse(i)))
}

`[<-.PythonInR_Tuple` <- function(x, i, value){
    stop("'tuple' object does not support item assignment", call. = FALSE)
}

#  ---------------------------------------------------------
#  pyTuple
#  ======
#' @title create a virtual Python tuple
#'
#' @description The function pyTuple
#' @param key 
#' @param value 
#' @param regFinalizer
#' @details TODO
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' pyExec('myPyTuple = (1, 2, 5, "Hello R!")')
#' # create a virtual Python tuple for an existing tuple
#' myTuple <- pyTuple("myPyTuple")
#' myTuple[0]
#' myTuple[1] <- "should give an error since tuple are not mutable"
#' myTuple
#' # create a new Python list and virtual list
#' newTuple <- pyTuple('myNewTuple', list(1:3, 'Hello Python'))
#' newTuple[1]
#  ---------------------------------------------------------
pyTuple <- function(key, value, regFinalizer = FALSE){
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(key)

    if (!missing(value)){
        if ( !is.vector(value) ) stop("'value' has to be a vector or list")
        if (length(value) < 1) value <- as.list(value)
        class(value) <- "pyTuple"
        pySetSimple(key, value)       
    }
    
    if (!pyVariableExists(key))
        stop(sprintf("'%s' does not exist in the global namespace",
             key))
    vIsTuple <- pyGet(sprintf("isinstance(%s, tuple)", key))
    if (!vIsTuple)
        stop(sprintf("'%s' is not an instance of tuple"), key)

    if (regFinalizer){
        py_tuple <- PythonInR_Tuple$new(key, NULL, "tuple")
    }else{
        py_tuple <- PythonInR_TupleNoFinalizer$new(key, NULL, "tuple")
        class(py_tuple) <- class(py_tuple)[-2]
    }
    return(py_tuple)
}

