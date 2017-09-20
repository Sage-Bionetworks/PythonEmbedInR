context("test pyCall returns data.frame")

test_that("pyCall() returns r data.frame for pandas DataFrame", {
  # making sure that R connected to python
  pyConnect()
  expect_true(pyIsConnected())
  
  # import pandas
  baseDir <- getwd()
  pyExec(sprintf("sys.path.append(\"%s\")", file.path(baseDir, "tests", "testthat")))
  pyImport("install_pandas")
  pyExec(sprintf("install_pandas.main('%s')", baseDir))
  
  # tell PythonEmbedInR to use pandas
  pyExec("import pandas as pd")
  pyOptions("usePandas", TRUE)
  pyOptions("pandasAlias", "pd")
  
  # creating rest data
  df <- data.frame(c(1,2,3), c(T,F,F))
  expect_equal(class(df), "data.frame")
  
  pySet("df", df)
  expect_output(pyExecp("type(df)"), "pandas.core.frame.DataFrame")

  # loading a test function in python
  pyExec("import numpy as np")
  pyExec("return_df = lambda: df")

  df2 <- pyCall("return_df")
  expect_equal(class(df2), "data.frame")
  expect_equal(summary(df2), summary(df))
  
})
