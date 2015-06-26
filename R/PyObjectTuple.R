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
#' @title create a virtual Python list
#'
#' @description The function pyList 
#' @param key 
#' @param ...
#' @details 
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
pyTuple <- function(variableName, value, regFinalizer = FALSE){
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(variableName)

    ## TODO: here belogs more checking!
    if (!missing(value)){
        ## create a new object
        pySetSimple(variableName, value)
        ## TODO: maybe use the list to tuple function
        pyExec(sprintf('%s = tuple(%s)', variableName, variableName))
    }
    
    if (!pyVariableExists(variableName))
        stop(sprintf("'%s' does not exist in the global namespace",
             variableName))
    vIsTuple <- pyGet(sprintf("isinstance(%s, tuple)", variableName))
    if (!vIsTuple)
        stop(sprintf("'%s' is not an instance of tuple"), variableName)

    if (regFinalizer){
        py_tuple <- PythonInR_Tuple$new(variableName, NULL, "tuple")
    }else{
        py_tuple <- PythonInR_TupleNoFinalizer$new(variableName, NULL, "tuple")
        class(py_tuple) <- class(py_tuple)[-2]
    }
    return(py_tuple)
}

