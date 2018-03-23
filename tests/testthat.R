library(testthat)
library(PythonEmbedInR)

# determine the testthat path
package_dir <- gsub("(PythonEmbedInR).*", "\\1", getwd())
testthat_dir <- file.path(package_dir, "tests", "testthat")

# add testthat to python search path
pyImport("sys")
pyExec(sprintf("sys.path.insert(0, \"%s\")", testthat_dir))

test_check("PythonEmbedInR")

# uninstall pandas
pyExit()
print("Uninstalling pandas ...")
pyExec(sprintf("install_pandas.main('uninstall', '%s')", package_dir))