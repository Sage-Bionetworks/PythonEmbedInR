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

test_that("pyCall() returns named list for OrderedList", {
  pyImport("OrderedDict", from="collections")
  pyExec("od = OrderedDict([('pear', 1), ('apple', 4), (None, 2), ('banana', None)])")
  # define a test function in python
  pyExec("return_named_list = lambda: od")
  r_value <- pyCall("return_named_list")
  expect_equal("numeric", class(r_value))
  expect_equal("character", class(names(r_value)))
  expected <- c(1, 4, 2, NA)
  names(expected) <-c('pear', 'apple', NA, 'banana')
  expect_equal(expected, r_value)
})
