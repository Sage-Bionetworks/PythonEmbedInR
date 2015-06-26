##  
##  pyList
##
##
##  PythonInR_List
##      class definition

PythonInR_List <-
    R6Class("PythonInR_List",
            portable = TRUE,
            inherit = PythonInR_Object,
            public = list(
                print = function() pyExecp(self$py.variableName),
                append = function(x){
                    cable <- sprintf("%s.append", self$py.variableName)
                    pyCall(cable, args=list(x))},
                extend = function(L){
                    cable <- sprintf("%s.extend", self$py.variableName)
                    pyCall(cable, args=list(L))},
                insert = function(i, x){
                    cable <- sprintf("%s.insert", self$py.variableName)
                    pyCall(cable, args=list(as.integer(i), x))},
                remove = function(x){
                    cable <- sprintf("%s.remove", self$py.variableName)
                    pyCall(cable, args=list(x))},
                pop = function(i){
                    cable <- sprintf("%s.pop", self$py.variableName)
                    pyCall(cable, args=list(as.integer(i)))},
                index = function(x){
                    cable <- sprintf("%s.index", self$py.variableName)
                    pyCall(cable, args=list(x))},
                count = function(x){
                    cable <- sprintf("%s.count", self$py.variableName)
                    pyCall(cable, args=list(x))},
                reverse = function(){
                    ## returns a new reference
                    pyGet(sprintf("%s.reverse()", self$py.variableName), autoTypecast=FALSE)
                },
                sort = function(){
                    ## returns a new reference
                    pyGet(sprintf("%s.sort()", self$py.variableName), autoTypecast=FALSE)
                },
                setslice = function(start, stop, value){
                    cable <- sprintf("%s.__setslice__", self$py.variableName)
                    checkType(environment(), cable, start='integer', stop='integer', value='list')
                    pyCall(cable, args=list(start, stop, value))
                }
                ))

PythonInR_ListNoFinalizer <-
    R6Class("PythonInR_List",
            portable = TRUE,
            inherit = PythonInR_List,
            public = list(
                initialize = function(variableName, objectName, type) {
                    if (!missing(variableName)) self$py.variableName <- variableName
                    if (!missing(objectName)) self$py.objectName <- objectName
                    if (!missing(type)) self$py.type <- type
                }
            ))

`[.PythonInR_List` <- function(x, i){
    slice <- if (is.character(i)) i else deparse(i)
    pyGet(sprintf("%s[%s]", x$py.variableName, slice))
}

`[<-.PythonInR_List` <- function(x, i, value){
    slice <- deparse(i)
    if (grepl(":", slice, fixed=TRUE)){
        slice <- as.integer(unlist(strsplit(slice, ':', fixed=TRUE)))
        x$setslice(slice[1], slice[2], value)
    }else{
        x$pop(i)   
        x$insert(i, value)
    }
    x
}

#  ---------------------------------------------------------
#  pyList
#  ======
#' @title create a virtual Python list
#'
#' @description The function pyList 
#' @param key 
#' @param ...
#' @details 
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' pyExec('myPyList = [1, 2, 5, "Hello R!"]')
#' # create a virtual Python list for an existing list
#' myList <- pyList("myPyList")
#' myList[0]
#' myList[1] <- "changed"
#' myList
#' # create a new Python list and virtual list
#' pyList('myNewList', list(1:3, 'Hello Python'))
#' pyList[1]
#  ---------------------------------------------------------
pyList <- function(variableName, value, regFinalizer = TRUE){
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(variableName)

    if (!missing(value)){
        if ( !is.vector(value) ) stop("'value' has to be a vector or list")
        if (length(value) < 1) value <- as.list(value)
        pySetSimple(variableName, unname(value))
    }
    
    if (!pyVariableExists(variableName))
        stop(sprintf("'%s' does not exist in the global namespace",
             variableName))
    vIsList <- pyGet(sprintf("isinstance(%s, list)", variableName))
    if (!vIsList)
        stop(sprintf("'%s' is not an instance of list"), variableName)

    if (regFinalizer){
        py_list <- PythonInR_List$new(variableName, NULL, "list")
    }else{
        py_list <- PythonInR_ListNoFinalizer$new(variableName, NULL, "list")
        class(py_list) <- class(py_list)[-2]
    }
    return(py_list)
}
