##  
##  pyDict
##
##
##  PythonInR_Dict
##      class definition

PythonInR_Dict <-
  R6Class(
    "PythonInR_Dict",
    portable = TRUE,
    inherit = PythonInR_Object,
    public = list(
      print = function() pyExecp(self$py.variableName),
      clear = function(){
          cable <- sprintf("%s.clear", self$py.variableName)
          pyCall(cable)},
      copy = function(){
          cable <- sprintf("%s.copy", self$py.variableName)
          pyCall(cable)},
      fromkeys = function(seq, value){
          cable <- sprintf("%s.fromkeys", self$py.variableName)
          if (missing(value)) pyCall(cable, list(seq))
          else pyCall(cable, list(seq, value))},
      get = function(key, default){
          cable <- sprintf("%s.get", self$py.variableName)
          if (missing(value)) pyCall(cable, list(key))
          else pyCall(cable, list(key, default))},
      has_key = function(key){
          cable <- sprintf("%s.has_key", self$py.variableName)
          pyCall(cable, list(key))},
      items = function(){
          cable <- sprintf("%s.items", self$py.variableName)
          pyCall(cable)},
      keys = function(key){
          cable <- sprintf("%s.keys", self$py.variableName)
          pyCall(cable)},
      pop = function(key, default){
          cable <- sprintf("%s.pop", self$py.variableName)
          if (missing(value)) pyCall(cable, list(key))
          else pyCall(cable, list(key, default))},
      popitem = function(){
          cable <- sprintf("%s.popitem", self$py.variableName)
          pyCall(cable)},
      setdefault = function(key, default){
          cable <- sprintf("%s.setdefault", self$py.variableName)
          if (missing(value)) pyCall(cable, list(key))
          else pyCall(cable, list(key, default))},
      update = function(dict){
          cable <- sprintf("%s.update", self$py.variableName)
          pyCall(cable, list(dict))},
      values = function(){
          cable <- sprintf("%s.values", self$py.variableName)
          pyCall(cable)},
      viewitems = function(){
          cable <- sprintf("%s.viewitems", self$py.variableName)
          pyCall(cable)},
      viewkeys = function(){
          cable <- sprintf("%s.viewkeys", self$py.variableName)
          pyCall(cable)},
      viewvalues = function(){
          cable <- sprintf("%s.viewvalues", self$py.variableName)
          pyCall(cable)}
    ))

PythonInR_DictNoFinalizer <-
    R6Class("PythonInR_Dict",
            portable = TRUE,
            inherit = PythonInR_Dict,
            public = list(
                initialize = function(variableName, objectName, type) {
                    if (!missing(variableName)) self$py.variableName <- variableName
                    if (!missing(objectName)) self$py.objectName <- objectName
                    if (!missing(type)) self$py.type <- type
                }
            ))

`[.PythonInR_Dict` <- function(x, i){
    slice <- deparse(i)
    pyGet(sprintf("%s[%s]", x$py.variableName, slice))
}


`[<-.PythonInR_Dict` <- function(x, i, value){
    txt <- "" # TODO:
    checkType(environment(), txt, i='character', value='list')
    if (length(i) != length(value)) stop("len differs") #TODO
    x$update(setNames(value, i))
    x
}

pyDict <- function(variableName, value, regFinalizer = TRUE){
    if ( pyConnectionCheck() ) return(invisible(NULL))
    check_string(variableName)

    if (!missing(value)){
        ## create a new object
        pySetSimple(variableName, value)
    }

    if (!pyVariableExists(variableName))
        stop(sprintf("'%s' does not exist in the global namespace",
             variableName))
    vIsDict <- pyGet(sprintf("isinstance(%s, dict)", variableName))
    if (!vIsDict)
        stop(sprintf("'%s' is not an instance of dict"), variableName)

    if (regFinalizer){
      py_dict <- PythonInR_Dict$new(variableName, NULL, "dict")
    }else{
      py_dict <- PythonInR_DictNoFinalizer$new(variableName, NULL, "dict")
    }
    return(py_dict)
}
