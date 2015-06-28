
importPythonFunctions <- function(as="R"){
    .C("python_in_r_init_methods")
    pyExecp(sprintf("import PythonInR as %s", as))
}
