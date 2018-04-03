# helper that load before tests are run

# determine the package directory path
package_dir <- gsub("(PythonEmbedInR).*", "\\1", getwd())

# import pandas in python
print("Intalling Pandas ...")
pyImport("install_pandas")
pyExec(sprintf("install_pandas.main('install', '%s')", package_dir))

use_pandas <- function() {  
  # tell PythonEmbedInR to use pandas
  pyExec("import pandas as pd")
  pyOptions("usePandas", TRUE)
  pyOptions("pandasAlias", "pd")
}
