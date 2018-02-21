##  -----------------------------------------------------------
##  pyTransformReturn
##  =================
##
##  Is used to transform the return values.
##  It is being used by both pyGet and pyCall.
##
## -----------------------------------------------------------

# if the object is a primitive (e.g. a vector or a list) 
# pyTransformReturn simply returns the value
pyTransformReturn <- function(obj) obj

setGeneric("pyTransformReturn")

setClass("PythonObject")
setMethod("pyTransformReturn", signature(obj = "PythonObject"),
          function(obj){
    variableName <- sprintf("__R__.namespace[%i]", obj$id)
    if (obj$isCallable){
        return(pyFunction(variableName, regFinalizer = TRUE))
    }else if ( obj$type == "list" ){
        return(pyList(variableName, regFinalizer = TRUE))
    }else if ( obj$type == "dict" ){
        return(pyDict(variableName, regFinalizer = TRUE))
    }else if ( obj$type == "DataFrame" ){
      return( getPandasDataFrame(variableName))
    }else if ( obj$type == "collections.OrderedDict" ){
      return( getOrderedDict(variableName))
    }else{
        return(pyObject(variableName, regFinalizer = TRUE))
    }
})

# recurively apply to list
setMethod("pyTransformReturn", signature(obj = "list"),
          function(obj) {
	lapply(obj, function(x) {pyTransformReturn(x)})
})

# this stops data frames from being treated like lists
setMethod("pyTransformReturn", signature(obj = "data.frame"),
          function(obj) {
	obj
})
