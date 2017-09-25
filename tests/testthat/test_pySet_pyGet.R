context("test pySet and pyGet")

test_that("data.frame can be converted to PrDataFrame and back", {
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
  use_pandas()

  # creating test data
  df <- data.frame(c(1,2,3), c(T,F,F))
  expect_equal(class(df), "data.frame")

  pySet("df", df)
  expect_output(pyExecp("type(df)"), "pandas.core.frame.DataFrame")
  
  df2 <- pyGet("df")
  expect_equal(class(df2), "data.frame")
})
