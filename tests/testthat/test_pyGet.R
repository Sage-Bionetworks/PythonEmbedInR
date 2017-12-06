## Testing how values are converted from python to r

context("pyGet")

### single element vector

test_that("bool value can be converted to r logical", {
  pyExec("py_value = True")
  expect_output(pyExecp("type(py_value)"), "bool")
  r_value <- pyGet("py_value")
  expect_equal("logical", class(r_value))
  expect_equal(TRUE, r_value)
})

test_that("int value can be converted to r numeric", {
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

test_that("float value can be converted to r numeric", {
  pyExec("py_value = 3.4")
  expect_output(pyExecp("type(py_value)"), "float")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(3.4, r_value)
})

test_that("float Inf value can be converted to r numeric", {
  pyExec("py_value = float('Inf')")
  expect_output(pyExecp("type(py_value)"), "float")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(Inf, r_value)
})

test_that("float NaN can be converted to r numeric", {
  pyExec("py_value = float('NaN')")
  expect_output(pyExecp("type(py_value)"), "float")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(NaN, r_value)
})

test_that("string value can be converted to r character", {
  pyExec("py_value = 'some string'")
  expect_output(pyExecp("type(py_value)"), "str")
  r_value <- pyGet("py_value")
  expect_equal("character", class(r_value))
  expect_equal('some string', r_value)
})

test_that("None can be converted to r NULL", {
  pyExec("py_value = None")
  expect_output(pyExecp("type(py_value)"), "NoneType")
  r_value <- pyGet("py_value")
  expect_equal("NULL", class(r_value))
  expect_equal(NULL, r_value)
})

## list of the same type

test_that("list of bool values can be converted to r", {
  pyExec("pylist = [True, False]")
  r_value <- pyGet("pylist")
  expect_equal("logical", class(r_value))
  expect_equal(c(TRUE, FALSE), r_value)
})

test_that("list of bool values with None can be converted to R", {
  pyExec("pylist = [True, False, None]")
  r_value <- pyGet("pylist")
  expect_equal("logical", class(r_value))
  expect_equal(c(TRUE, FALSE, NA), r_value)
})

test_that("list of int values can be converted to r", {
  pyExec("py_value = [1507236276000, 1507236276001]")
  expect_output(pyExecp("type(py_value)"), "list")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(1507236276000, 1507236276001), r_value)
})

test_that("list of int values with None can be converted to r", {
  skip("None is currently converted to -1 in list of int")
  pyExec("py_value = [1507236276000, 1507236276001, None]")
  expect_output(pyExecp("type(py_value)"), "list")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(1507236276000, 1507236276001, NA), r_value)
})

test_that("list of float values can be converted to r", {
  pyExec("py_value = [3.4, float('Inf'), float('NaN')]")
  expect_output(pyExecp("type(py_value)"), "list")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(3.4, Inf, NaN), r_value)
})

test_that("list of float values with None can be converted to r", {
  skip("None is currently converted to -1.0 in list of int")
  pyExec("py_value = [3.4, float('Inf'), float('NaN'), None]")
  expect_output(pyExecp("type(py_value)"), "list")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(3.4, Inf, NaN, NA), r_value)
})

test_that("list of str values can be converted to R", {
  pyExec("pylist = ['a', 'b', 'c']")
  expect_output(pyExecp("type(py_value)"), "list")
  r_value <- pyGet("pylist")
  expect_equal("character", class(r_value))
  expect_equal(c('a', 'b', 'c'), r_value)
})

test_that("list of str values with None can be converted to R", {
  skip("error thrown for None in list of string")
  pyExec("pylist = ['a', 'b', 'c', None]")
  expect_output(pyExecp("type(py_value)"), "list")
  r_value <- pyGet("pylist")
  expect_equal("character", class(r_value))
  expect_equal(c('a', 'b', 'c', NA), r_value)
})

## list of different types

test_that("list of different type converted to list of list", {
  pyExec("l = [float('NaN'), 'abc']")
  expect_output(pyExecp("type(l)"), "list")
  expect_output(pyExecp("len(l)"), "2")
  
  list <- pyGet("l")
  expect_equal(list(NaN, 'abc'), list)
})

## tuple

test_that("tuple of timestamp values can be converted to r", {
  pyExec("py_value = (1507236276000, 1507236276001)")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(1507236276000, 1507236276001), r_value)
})

## dict

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

## OrderedDict

test_that("OrderedDict convert to named list", {
  pyImport("OrderedDict", from="collections")
  pyExec("od = OrderedDict([('pear', 1), ('apple', 4), (None, 2), ('banana', None)])")
  r_value <- pyGet("od")
  expect_equal("numeric", class(r_value))
  expected <- c(1, 4, 2, NA)
  names(expected) <-c('pear', 'apple', NA, 'banana')
  expect_equal(expected, r_value)
})
