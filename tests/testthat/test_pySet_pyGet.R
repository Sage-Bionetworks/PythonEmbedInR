context("test pySet and pyGet")

test_that("data.frame can be converted to PrDataFrame and back", {
  # making sure that R connected to python
  pyConnect()
  expect_true(pyIsConnected())

  pyOptions("usePandas", FALSE)
  
  # creating rest data
  df <- data.frame(c(1,2,3), c(T,F,F))
  expect_equal(class(df), "data.frame")
  
  pySet("df", df)
  expect_output(pyExecp("type(df)"), "__main__.PythonInR.PrDataFrame")

  df2 <- pyGet("df")
  expect_equal(class(df2), "data.frame")
})

test_that("data.frame can be converted to pandas DataFrame and back", {
  # making sure that R connected to python
  pyConnect()
  expect_true(pyIsConnected())

  # import pandas
  baseDir <- getwd()
  pyExec(sprintf("sys.path.append(\"%s\")", file.path(baseDir, "test", "testthat")))
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
  
  df2 <- pyGet("df")
  expect_equal(class(df2), "data.frame")
})
