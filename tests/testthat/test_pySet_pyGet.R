## Testing the round trip from r to python and back

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

test_that("timestamp value can make a round trip to python and back", {
  r_value <- 1507236276000
  expect_equal("numeric", class(r_value))
  pySet("py_value", r_value)
  expect_output(pyExecp("type(py_value)"), "float")
  x <- pyGet("py_value")
  expect_equal("numeric", class(x))
})

test_that("NA can be converted to python and back", {
  r_value <- NA
  expect_equal("logical", class(r_value))
  pySet("py_value", r_value)
  expect_output(pyExecp("type(py_value)"), "<class 'NoneType'>")
  x <- pyGet("py_value")
  expect_equal("NULL", class(x))
})

test_that("NULL can be converted to python and back", {
  r_value <- NULL
  expect_equal("NULL", class(r_value))
  pySet("py_value", r_value)
  expect_output(pyExecp("type(py_value)"), "<class 'NoneType'>")
  x <- pyGet("py_value")
  expect_equal("NULL", class(x))
})

test_that("NaN can be converted to python and back", {
  r_value <- NaN
  expect_equal("numeric", class(r_value))
  pySet("py_value", r_value)
  expect_output(pyExecp("type(py_value)"), "<class 'float'>")
  x <- pyGet("py_value")
  expect_equal("numeric", class(x))
})

test_that("Inf can be converted to python and back", {
  r_value <- Inf
  expect_equal("numeric", class(r_value))
  pySet("py_value", r_value)
  expect_output(pyExecp("type(py_value)"), "<class 'float'>")
  x <- pyGet("py_value")
  expect_equal("numeric", class(x))
})
