library(testthat)
library(PythonEmbedInR)

# determine the testthat path
package_dir <- gsub("(PythonEmbedInR).*", "\\1", getwd())
testthat_dir <- file.path(package_dir, "tests", "testthat")

pyImport("sys")
pyExecp("sys.path")
# clean up sys.path to ensure that testthat does not use user's installed packages
pyExec(sprintf("sys.path = [x for x in sys.path if x.startswith(\"%s\") or \"PythonEmbedInR\" in x]", package_dir))
# add testthat to python search path
pyExec(sprintf("sys.path.insert(0, \"%s\")", testthat_dir))
pyExecp("sys.path")

test_check("PythonEmbedInR")

# uninstall pandas
pyExit()
print("Uninstalling pandas ...")
pyExec(sprintf("install_pandas.main('uninstall', '%s')", package_dir))