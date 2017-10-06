context("test pySet and pyGet")

test_that("data.frame can be converted to PrDataFrame and back", {
  pyOptions("usePandas", FALSE)
  
  # creating rest data
  df <- data.frame(c(1507236276000,1507236276001,1507236276002), c(T,F,F))
  expect_equal(class(df), "data.frame")
  
  pySet("df", df)
  expect_output(pyExecp("type(df)"), "__main__.PythonInR.PrDataFrame")

  df2 <- pyGet("df")
  expect_equal(class(df2), "data.frame")
})

test_that("data.frame can be converted to pandas DataFrame and back", {
  use_pandas()

  # creating test data
  df <- data.frame(c(1507236276000,1507236276001,1507236276002), c(T,F,F))
  expect_equal(class(df), "data.frame")

  pySet("df", df)
  expect_output(pyExecp("type(df)"), "pandas.core.frame.DataFrame")
  
  df2 <- pyGet("df")
  expect_equal(class(df2), "data.frame")
})

test_that("big int value can be converted to r", {
  pyExec("py_value = pow(2,65)")
  expect_output(pyExecp("type(py_value)"), "int")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(36893488147419103232, r_value)
})

test_that("timestamp value can be converted to r", {
  pyExec("py_value = 1507236276000")
  expect_output(pyExecp("type(py_value)"), "int")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(1507236276000, r_value)
})

test_that("vector of timestamp values can be converted to r", {
  pyExec("py_value = [1507236276000, 1507236276001]")
  expect_output(pyExecp("type(py_value)"), "list")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(1507236276000, 1507236276001), r_value)
})

test_that("timestamp value can make a round trip to python and back", {
  r_value <- 1507236276000
  expect_equal("numeric", class(r_value))
  pySet("py_value", r_value)
  expect_output(pyExecp("type(py_value)"), "float")
  x <- pyGet("py_value")
  expect_equal("numeric", class(x))
})

