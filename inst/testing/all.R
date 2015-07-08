q("no")
R

library(testthat)
require(PythonInR)

test_this <- c("Basics.R", "PyAttach.R", "PyCall.R", "PyExec.R", "PyFunction.R", 
               "PyGetSet.R", "PyObject.R", "PyOptions.R", "PySource.R", 
               "Utf8.R", "PyImport.R")

fpath <- file.path(path.package("PythonInR"), "testing")

for (i in test_this){
    cat(i, "\n")
    fname <- file.path(fpath, i)
    test_file(i)
    cat("\n\n")
}

print("Finished Testing!")
