# install pandas 

# first import pandas in python
baseDir <- getwd()
pyExec(sprintf("sys.path.append(\"%s\")", file.path(baseDir, "tests", "testthat")))
pyImport("install_pandas")
pyExec(sprintf("install_pandas.main('%s')", baseDir))

# tell PythonEmbedInR to use pandas
pyExec("import pandas as pd")
pyOptions("usePandas", TRUE)
pyOptions("pandasAlias", "pd")
