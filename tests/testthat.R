library(testthat)
library(PythonEmbedInR)

# determine the testthat path
package_dir <- gsub("(PythonEmbedInR).*", "\\1", getwd())

pyImport("sys")
pyExecp("sys.path")
# insert current dir to python search path
pyExec("sys.path.insert(0, \".\")")
pyExecp("sys.path")

test_check("PythonEmbedInR")

# uninstall pandas
pyExit()
print("Uninstalling pandas ...")
pyExec(sprintf("install_pandas.main('uninstall', '%s')", package_dir))