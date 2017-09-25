context("test pyCall returns data.frame")

test_that("pyCall() returns r data.frame for pandas DataFrame", {
  use_pandas()

  # creating test data
  df <- data.frame(c(1,2,3), c(T,F,F))
  expect_equal(class(df), "data.frame")
  
  pySet("df", df)
  expect_output(pyExecp("type(df)"), "pandas.core.frame.DataFrame")

  # define a test function in python
  pyExec("return_df = lambda: df")

  df2 <- pyCall("return_df")
  expect_equal(class(df2), "data.frame")
})
