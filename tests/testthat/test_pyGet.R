## Testing how values are converted from python to r

context("pyGet")

### single element vector

test_that("bool value converts to r logical", {
  pyExec("py_value = True")
  expect_output(pyExecp("type(py_value)"), "bool")
  r_value <- pyGet("py_value")
  expect_equal("logical", class(r_value))
  expect_equal(TRUE, r_value)
})

test_that("int value converts to r numeric", {
  pyExec("py_value = pow(2,65)")
  expect_output(pyExecp("type(py_value)"), "int")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(36893488147419103232, r_value)
})

test_that("float value converts to r numeric", {
  pyExec("py_value = 3.4")
  expect_output(pyExecp("type(py_value)"), "float")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(3.4, r_value)
})

test_that("float Inf value converts to r Inf", {
  pyExec("py_value = float('Inf')")
  expect_output(pyExecp("type(py_value)"), "float")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(Inf, r_value)
})

test_that("float NaN value converts to r NaN", {
  pyExec("py_value = float('NaN')")
  expect_output(pyExecp("type(py_value)"), "float")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(NaN, r_value)
})

test_that("string value converts to r character", {
  pyExec("py_value = 'some string'")
  expect_output(pyExecp("type(py_value)"), "str")
  r_value <- pyGet("py_value")
  expect_equal("character", class(r_value))
  expect_equal('some string', r_value)
})

test_that("None converts to r NULL", {
  pyExec("py_value = None")
  expect_output(pyExecp("type(py_value)"), "NoneType")
  r_value <- pyGet("py_value")
  expect_equal("NULL", class(r_value))
  expect_equal(NULL, r_value)
})

## list

test_that("empty list converts to vector in r", {
  pyExec("py_list = []")
  expect_output(pyExecp("type(py_list)"), "list")
  r_value <- pyGet("py_list")
  expect_equal("logical", class(r_value))
  expect_equal(logical(0), r_value)
})

test_that("list of None values converts to logical vector in R", {
  pyExec("pylist = [None]")
  expect_output(pyExecp("type(pylist)"), "list")
  r_value <- pyGet("pylist")
  expect_equal("logical", class(r_value))
  expect_equal(c(NA), r_value)
})

## list of the same type

test_that("list of bool values converts to logical vector in r", {
  pyExec("py_list = [True, False]")
  expect_output(pyExecp("type(py_list)"), "list")
  r_value <- pyGet("py_list")
  expect_equal("logical", class(r_value))
  expect_equal(c(TRUE, FALSE), r_value)
})

test_that("list of bool values with None converts to logical vector in r", {
  pyExec("py_list = [None, True, False]")
  expect_output(pyExecp("type(py_list)"), "list")
  r_value <- pyGet("py_list")
  expect_equal("logical", class(r_value))
  expect_equal(c(NA, TRUE, FALSE), r_value)
})

test_that("list of int values converts to numeric vector in r", {
  pyExec("py_list = [1507236276000, 1507236276001]")
  expect_output(pyExecp("type(py_list)"), "list")
  r_value <- pyGet("py_list")
  expect_equal("numeric", class(r_value))
  expect_equal(c(1507236276000, 1507236276001), r_value)
})

test_that("list of int values with None converts to numeric vector in r", {
  pyExec("py_list = [None, 1507236276000, 1507236276001]")
  expect_output(pyExecp("type(py_list)"), "list")
  r_value <- pyGet("py_list")
  expect_equal("numeric", class(r_value))
  expect_equal(c(NA, 1507236276000, 1507236276001), r_value)
})

test_that("list of float values converts to numeric vector in r", {
  pyExec("py_list = [3.4, float('Inf'), float('NaN')]")
  expect_output(pyExecp("type(py_list)"), "list")
  r_value <- pyGet("py_list")
  expect_equal("numeric", class(r_value))
  expect_equal(c(3.4, Inf, NaN), r_value)
})

test_that("list of float values with None converts to numeric vector in r", {
  pyExec("py_list = [3.4, float('Inf'), float('NaN'), None]")
  expect_output(pyExecp("type(py_list)"), "list")
  r_value <- pyGet("py_list")
  expect_equal("numeric", class(r_value))
  expect_equal(c(3.4, Inf, NaN, NA), r_value)
})

test_that("list of str values converts to character vector in R", {
  pyExec("py_list = ['a', 'b', 'c']")
  expect_output(pyExecp("type(py_list)"), "list")
  r_value <- pyGet("py_list")
  expect_equal("character", class(r_value))
  expect_equal(c('a', 'b', 'c'), r_value)
})

test_that("list of str values with None converts to character vector in R", {
  pyExec("py_list = [None, 'a', 'b', 'c']")
  expect_output(pyExecp("type(py_list)"), "list")
  r_value <- pyGet("py_list")
  expect_equal("character", class(r_value))
  expect_equal(c(NA, 'a', 'b', 'c'), r_value)
})

## list of different types

test_that("list of different type converts to list of list in r", {
  pyExec("pylist = [float('NaN'), 'abc']")
  expect_output(pyExecp("type(pylist)"), "list")
  list <- pyGet("pylist")
  expect_equal(list(NaN, 'abc'), list)
})

test_that("list of different type with None converts to list of list in r", {
  pyExec("pylist = [float('NaN'), 'abc', None]")
  expect_output(pyExecp("type(pylist)"), "list")
  list <- pyGet("pylist")
  expect_equal(list(NaN, 'abc', NULL), list)
})

# tuple

test_that("empty tuple converts to a logical vector in r", {
  pyExec("py_value = ()")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("py_value")
  expect_equal("logical", class(r_value))
  expect_equal(logical(0), r_value)
})

test_that("tuple of None value converts to NULL in r", {
  pyExec("py_value = (None)")
  expect_output(pyExecp("type(py_value)"), "NoneType")
  r_value <- pyGet("py_value")
  expect_equal("NULL", class(r_value))
  expect_equal(NULL, r_value)
})

test_that("tuple of None values converts to logical vector in r", {
  pyExec("py_value = (None, None)")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("py_value")
  expect_equal("logical", class(r_value))
  expect_equal(c(NA, NA), r_value)
})

## tuple of the same type values

test_that("tuple of bool values converts to logical vector in r", {
  pyExec("py_value = (True, False)")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("py_value")
  expect_equal("logical", class(r_value))
  expect_equal(c(TRUE, FALSE), r_value)
})

test_that("tuple of bool values with None converts to logical vector in r", {
  pyExec("py_value = (True, False, None)")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("py_value")
  expect_equal("logical", class(r_value))
  expect_equal(c(TRUE, FALSE, NA), r_value)
})

test_that("tuple of int values converts to numeric vector in r", {
  pyExec("py_value = (1507236276000, 1507236276001)")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(1507236276000, 1507236276001), r_value)
})

test_that("tuple of int values with None converts to numeric vector in r", {
  pyExec("py_value = (1507236276000, 1507236276001, None)")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(1507236276000, 1507236276001, NA), r_value)
})

test_that("tuple of float values converts to numeric vector in r", {
  pyExec("py_value = (3.4, float('Inf'), float('NaN'))")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(3.4, Inf, NaN), r_value)
})

test_that("tuple of float values with None converts to numeric vector in r", {
  pyExec("py_value = (3.4, float('Inf'), float('NaN'), None)")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("py_value")
  expect_equal("numeric", class(r_value))
  expect_equal(c(3.4, Inf, NaN, NA), r_value)
})

test_that("tuple of str values converts to character vector in r", {
  pyExec("pylist = ('a', 'b', 'c')")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("pylist")
  expect_equal("character", class(r_value))
  expect_equal(c('a', 'b', 'c'), r_value)
})

test_that("tuple of str values with None converts to character vector in r", {
  pyExec("pylist = (None, 'a', 'b', 'c')")
  expect_output(pyExecp("type(py_value)"), "tuple")
  r_value <- pyGet("pylist")
  expect_equal("character", class(r_value))
  expect_equal(c(NA, 'a', 'b', 'c'), r_value)
})

## tuple of different types

test_that("tuple of different type converts to list of list in r", {
  pyExec("t = (float('NaN'), 'abc')")
  expect_output(pyExecp("type(t)"), "tuple")
  list <- pyGet("t")
  expect_equal(list(NaN, 'abc'), list)
})

test_that("tuple of different type with None converts to list of list in r", {
  pyExec("t = (float('NaN'), 'abc', None)")
  expect_output(pyExecp("type(t)"), "tuple")
  list <- pyGet("t")
  expect_equal(list(NaN, 'abc', NULL), list)
})

## dict

test_that("empty dict converts to logical vector in r", {
  pyExec("py_dict = {}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("logical", class(r_value))
  expected <- logical(0)
  names(expected) <- logical(0)
  expect_equal(expected, r_value)
})

test_that("dict with None value converts to named logical vector in r", {
  pyExec("py_dict = {'a':None}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("logical", class(r_value))
  expected <- c(NA)
  names(expected) <- c('a')
  expect_equal(expected['a'], r_value['a'])
})

## dict that have values of the same type

test_that("dict of bool values converts to named logical vector in r", {
  pyExec("py_dict = {'a': True, 'b':False}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("logical", class(r_value))
  expected <- c(TRUE, FALSE)
  names(expected) <- c('a', 'b')
  expect_equal(expected['a'], r_value['a'])
  expect_equal(expected['b'], r_value['b'])
})

test_that("dict of bool values with None converts to named logical vector in r", {
  pyExec("py_dict = {'a': True, 'b':False, 'c':None}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("logical", class(r_value))
  expected <- c(TRUE, FALSE, NA)
  names(expected) <- c('a', 'b', 'c')
  expect_equal(expected['a'], r_value['a'])
  expect_equal(expected['b'], r_value['b'])
  expect_equal(expected['c'], r_value['c'])
})

test_that("dict of int values converts to named numeric vector in r", {
  pyExec("py_dict = {'now': 1507236276000, 'later':1507236276001}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("numeric", class(r_value))
  expected <- c(1507236276000, 1507236276001)
  names(expected) <- c('now', 'later')
  expect_equal(expected['now'], r_value['now'])
  expect_equal(expected['later'], r_value['later'])
})

test_that("dict of int values with None converts to named numeric vector in r", {
  pyExec("py_dict = {'now': None, 'later':1507236276001, 'whenever':1507236276000}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("numeric", class(r_value))
  expected <- c(NA, 1507236276000, 1507236276001)
  names(expected) <- c('now', 'later', 'whenever')
  expect_equal(expected['now'], r_value['now'])
  expect_equal(expected['later'], r_value['later'])
  expect_equal(expected['whenever'], r_value['whenever'])
})

test_that("dict of float values converts to named numeric vector in r", {
  pyExec("py_dict = {'a': 3.4, 'b':float('Inf'), 'c':float('NaN')}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("numeric", class(r_value))
  expected <- c(3.4, Inf, NaN)
  names(expected) <- c('a', 'b', 'c')
  expect_equal(expected['a'], r_value['a'])
  expect_equal(expected['b'], r_value['b'])
  expect_equal(expected['c'], r_value['c'])
})

test_that("dict of float values with None converts to named numeric vector in r", {
  pyExec("py_dict = {'a': 3.4, 'b':float('Inf'), 'c':float('NaN'), 'd':None}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("numeric", class(r_value))
  expected <- c(3.4, Inf, NaN, NA)
  names(expected) <- c('a', 'b', 'c', 'd')
  expect_equal(expected['a'], r_value['a'])
  expect_equal(expected['b'], r_value['b'])
  expect_equal(expected['c'], r_value['c'])
  expect_equal(expected['d'], r_value['d'])
})

test_that("dict of string values converts to named character vector in r", {
  pyExec("py_dict = {'a': 'apple', 'b':'bee'}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("character", class(r_value))
  expected <- c("apple", "bee")
  names(expected) <- c('a', 'b')
  expect_equal(expected['a'], r_value['a'])
  expect_equal(expected['b'], r_value['b'])
})

test_that("dict of string values with None converts to named character vector in r", {
  pyExec("py_dict = {'a': 'apple', 'b':'bee', 'c':None}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("character", class(r_value))
  expected <- c("apple", "bee", NA)
  names(expected) <- c('a', 'b', 'c')
  expect_equal(expected['a'], r_value['a'])
  expect_equal(expected['b'], r_value['b'])
  expect_equal(expected['c'], r_value['c'])
})

test_that("dict with None key can be converts to named vector with NA name in r", {
  pyExec("py_dict = {None: True, 'b':False}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("logical", class(r_value))
  expected <- c(TRUE, FALSE)
  names(expected) <- c(NA, 'b')
  expect_equal(expected['b'], r_value['b'])
})

test_that("dict of different values converts to named list in r", {
  pyExec("py_dict = {'a': 'apple', 'b':2}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("list", class(r_value))
  expected <- list("apple", 2)
  names(expected) <- c('a', 'b')
  expect_equal(expected['a'], r_value['a'])
  expect_equal(expected['b'], r_value['b'])
})

test_that("dict of list values can be converted to r", {
  skip("PythonEmbedInR does not support recursive conversion")
  pyExec("py_dict = {'a': [1, 2, 3], 'b': [True, False, True]}")
  expect_output(pyExecp("type(py_dict)"), "dict")
  r_value <- pyGet("py_dict")
  expect_equal("list", class(r_value))
  expected <- list(c(1, 2, 3), c(True, False, True))
  names(expected) <- c('a', 'b')
  expect_equal(expected['a'], r_value['a'])
  expect_equal(expected['b'], r_value['b'])
})

# set

test_that("set of Logical values converts to logical vector in r", {
  skip("PythonEmbedInR does not support python set")
  pyExec("py_set = {True}")
  expect_output(pyExecp("type(py_set)"), "set")
  r_value <- pyGet("py_set")
  expect_equal("logical", class(r_value))
  expect_equal(c(TRUE), r_value)
})

## OrderedDict

test_that("OrderedDict converts to named list in r", {
  skip("skipping OrderedDict")
  pyImport("OrderedDict", from="collections")
  pyExec("od = OrderedDict([('pear', 1), ('apple', 4), ('orange', 2), ('banana', 3)])")
  r_value <- pyGet("od")
  expect_equal("numeric", class(r_value))
  expected <- c(1, 4, 2, 3)
  names(expected) <-c('pear', 'apple', 'orange', 'banana')
  expect_equal(expected, r_value)
})

test_that("OrderedDict with None value converts to named list in r", {
  skip("skipping OrderedDict")
  pyImport("OrderedDict", from="collections")
  pyExec("od = OrderedDict([('pear', 1), ('apple', 4), ('orange', 2), ('banana', None)])")
  r_value <- pyGet("od")
  expect_equal("numeric", class(r_value))
  expected <- c(1, 4, 2, NA)
  names(expected) <-c('pear', 'apple', 'orange', 'banana')
  expect_equal(expected, r_value)
})

test_that("OrderedDict with None key converts to named list in r", {
  skip("skipping OrderedDict")
  pyImport("OrderedDict", from="collections")
  pyExec("od = OrderedDict([('pear', 1), ('apple', 4), (None, 2), ('banana', 3)])")
  r_value <- pyGet("od")
  expect_equal("numeric", class(r_value))
  expected <- c(1, 4, 2, 3)
  names(expected) <-c('pear', 'apple', NA, 'banana')
  expect_equal(expected, r_value)
})
