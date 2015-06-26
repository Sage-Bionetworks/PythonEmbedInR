## -----------------------------------------------------------------------------
##
##  pyTransformReturn 
##
##    I can do the same in pyGet with pyGetPoly but the idea is that
##    this transformations should be reuseable for pyCall and pyExecg
##  
## -----------------------------------------------------------------------------

pyTransformReturn <- function(obj) obj

setGeneric("pyTransformReturn")


setClass("PythonObject")
setMethod("pyTransformReturn", signature(obj = "PythonObject"),
          function(obj){
    variableName <- sprintf("__R__.namespace[%i]", obj$id)
    ## TODO: update the return of py_to_r
    #print(variableName)
    if (obj$isCallable){
        return(pyFunction(variableName))
    }else if ( obj$type == "list" ){
        return(pyList(variableName, regFinalizer = TRUE))
    }else if ( obj$type == "dict" ){
        return(pyDict(variableName, regFinalizer = TRUE))
    }else{
        return(pyObject(variableName, regFinalizer = TRUE))
    }
})
