## Testing how values are converted from python to r

context("pyGet")

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

test_that("list of timestamp values can be converted to r", {
  pyExec("py_value = [1507236276000, 1507236276001]")
  expect_output(pyExecp("type(py_value)"), "list")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(1507236276000, 1507236276001), r_value)
})

test_that("tuple of timestamp values can be converted to r", {
  pyExec("py_value = (1507236276000, 1507236276001)")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(1507236276000, 1507236276001), r_value)
})

test_that("dict of timestamp values can be converted to r", {
  pyExec("py_value = {'now': 1507236276000, 'later':1507236276001}")
  expect_output(pyExecp("type(py_value)"), "dict")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expected <- c(1507236276000, 1507236276001)
  names(expected) <- c('now', 'later')
  expect_equal(expected['now'], r_value['now'])
  expect_equal(expected['later'], r_value['later'])
})

test_that("list of different type converted to list of list", {
  pyExec("l = [float('NaN'), 'abc']")
  expect_output(pyExecp("type(l)"), "list")
  expect_output(pyExecp("len(l)"), "2")

  list <- pyGet("l")
  expect_equal(class(list), "list")
  expect_equal(c(1, 1), lengths(list))
})
