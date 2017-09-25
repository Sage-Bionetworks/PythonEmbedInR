# helper that load before tests are run

# determine the package directory path
package_dir <- gsub("(PythonEmbedInR).*", "\\1", getwd())
# determine the testthat path
testthat_dir <- file.path(package_dir, "tests", "testthat")

# import pandas in python
print("Intalling Pandas ...")
pyExec(sprintf("sys.path.append(\"%s\")", testthat_dir))
pyImport("install_pandas")
pyExec(sprintf("install_pandas.main('install', '%s')", package_dir))

use_pandas <- function() {  
  # tell PythonEmbedInR to use pandas
  pyExec("import pandas as pd")
  pyOptions("usePandas", TRUE)
  pyOptions("pandasAlias", "pd")
}
