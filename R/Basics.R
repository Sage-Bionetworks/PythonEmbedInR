# ------------------------------------------------------------------------------ 
#
#   Basics
#
# ------------------------------------------------------------------------------

#  -----------------------------------------------------------
#  pyDir
#  =====
#' @title is a convenience function to call the Python function \strong{dir}
#'
#' @description A convenience function to call the Python function \strong{dir}.
#' @param objName an optional string specifying the name of the Python object.
#' @return Returns the list of names in the global scope if no object name is 
#'         provided, otherwise a list of valid attributes for the specified object.
#' @details The Python function dir is similar to the R function ls.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' pyDir()
#' pyDir("sys")
#  -----------------------------------------------------------
pyDir <- function(objName=NULL){
    if ( is.null(objName) ){
        cmd <- '__tmp__=dir()'
    }else{
        check_string(objName)
        cmd <- sprintf('__tmp__=dir(%s)', objName)
    }
    # Looks redundant but is necessary because of the different namespaces!
    # If I would call pyExecg("x=dir()"), I would only get the elements of
    # the temporary namespace.
    pyExec(cmd)
    retv = pyExecg("__tmp__=__tmp__")[[1]]
    pyExec("__tmp__=None;del(__tmp__)")
    retv
}

#  ----------------------------------------------------------- 
#  pyHelp
#  ======
#' @title is a convenience function to access the Python \strong{help} system
#'
#' @description A convenience function to access the Python \strong{help} system.
#' @param topic A string specifying name or topic for which help is sought.
#' @return Prints the help to the given string.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' pyHelp("abs")
#  -----------------------------------------------------------
pyHelp <- function(topic){
    check_string(topic)
    pyExecp(sprintf("help('%s')", topic))
}

#  -----------------------------------------------------------
#  pyType
#  ======
#' @title is a convenience function to call the Python function \strong{type}
#'
#' @description Convenience function to call the Python function \strong{type}.
#' @param objName A string specifying the name of the Python object.
#' @return The type of the specified object.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' pyExec("x = dict()")
#' pyType("x")
#  -----------------------------------------------------------
pyType <- function(objName){
    check_string(objName)
    #cmd <- sprintf("x=str(type(%s))", objName)
    cmd <- sprintf("x=%s.__class__.__name__", objName)
    pyExecg(cmd)[["x"]]
}

#  -----------------------------------------------------------
#  pyImport
#  ========
#' @title is a convenience function to call the Python function \bold{import}
#'
#' @description A convenience function to call the Python function \bold{import}.
#' @param module A string specifying the name of the Python module.
#' @param alias an optional string defining a alias for the module name.
#' @details The function pyImport has a special behavior for the packages numpy 
#'          and pandas. For these two packages pyImport does not only import 
#'          numpy but also register their alias in the options. To be found when
#'          pyGet and pySet is used with the option useNumpy set to TRUE.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' pyImport("os")
#' \dontrun{
#' #NOTE: The following does not only import numpy but also register the
#' #      alias in the options under the name "numpyAlias". 
#' #      The same is done for pandas, the default alias for pandas and numpy 
#' #      are respectively "pandas" and "numpy". The numpyAlias is used 
#' #      when calling pyGet or pySet with the option useNumpy set to TRUE.
#' pyImport("numpy", "np")
#' pyImport("pandas", "pd")
#' }
# -----------------------------------------------------------
pyImport <- function(module=character(), alias=""){
    # <<<TODO: Hier waeren noch mehr optionen moeglich! wie from, ...>>>
    check_string(module)
    if (alias == ""){
        cmd <- sprintf("import %s", module)
    }else{
        if (module=="numpy") options(numpyAlias=alias)
        if (module=="pandas") options(pandasAlias=alias)
        cmd <- sprintf("import %s as %s", module, alias)
    }
    pyExec(cmd)
}

