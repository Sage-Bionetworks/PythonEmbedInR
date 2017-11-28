##  -----------------------------------------------------------
##  pyTransformReturn
##  =================
##
##  Is used to transform the return values.
##  It is being used by both pyGet and pyCall.
##
## -----------------------------------------------------------

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
      pyExec(sprintf("x = %s.to_dict(orient='list')", variableName))
      return( as.data.frame(pyGet("x"), optional=TRUE, stringsAsFactors=FALSE) )
    }else if ( obj$type == "collections.OrderedDict" ){
      pyExec(sprintf("keys = list(%s.keys())", variableName))
      pyExec(sprintf("values = list(%s.values())", variableName))
      keys <- pyGet("keys")
      values <- pyGet("values")
      names(values) <- keys
      return(values)
    }else{
        return(pyObject(variableName, regFinalizer = TRUE))
    }
})
