library(testthat)
library(PythonEmbedInR)

test_check("PythonEmbedInR")

# uninstall pandas
pyExit()
print("Uninstalling pandas ...")
package_dir <- gsub("(PythonEmbedInR).*", "\\1", getwd())
pyExec(sprintf("install_pandas.main('uninstall', '%s')", package_dir))
