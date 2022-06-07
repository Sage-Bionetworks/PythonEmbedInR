# helper that load before tests are run

# determine the package directory path
wd = getwd()
package_dir <- gsub("(PythonEmbedInR).*", "\\1", wd)

# import pandas in python
print("Intalling Pandas ...")

# explicitly include the absolute current working directory in the python path
# in order to pick up install_pandas.py across platforms
pyImport("sys")
pyExec(paste("if '", wd, "' not in sys.path: sys.path.append('", wd ,"');", sep=""))

pyImport("install_pandas")

pyExec(sprintf("install_pandas.main('install', '%s')", package_dir))
print("finish")
use_pandas <- function() {  
  # tell PythonEmbedInR to use pandas
  pyExec("import pandas as pd")
  pyOptions("usePandas", TRUE)
  pyOptions("pandasAlias", "pd")
}
