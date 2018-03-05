## Testing pyObject

context("pyObject")

test_that("an python object can be converted into an R6 object", {
  pyExec('
class MyClass:
  def __init__(self):
    self.x = 0
  def _do_increment(self):
    self.x += 1
  def increment(self):
    self._do_increment()

a = MyClass()
def myFunc():
  b = MyClass()
  b.increment()
  return b
')
  r_class <- pyObject("MyClass")

  # test that r_class is an environment
  expect_true(is.environment(r_class))
  expect_false(environmentIsLocked(r_class))
  expect_true(exists("increment", r_class))

  # test that r_object is initialized
  r_object = pyObject("a")
  r_object$increment()
  expect_true(exists("x", r_object))
  expect_equal(1, r_object$x)
  expect_true(exists("py.variableName", r_class))
  expect_equal("a", r_object$`py.variableName`)

  # test private methods
  expect_false(exists("__init__", r_class))
  expect_error(r_object$`__init__`())
  expect_false(exists("_do_increment", r_class))
  expect_error(r_object$`_do_increment`())
  expect_false(exists("py.del", r_class))
  expect_error(r_object$`py.del`())

  # test private non-methods
  expect_false(exists("__dict__", r_class))
  expect_null(r_object$`__dict__`)
  expect_false(exists("__doc__", r_class))
  expect_null(r_object$`__doc__`)
  expect_false(exists("__module__", r_class))
  expect_null(r_object$`__module__`)
  expect_false(exists("__weakref__", r_class))
  expect_null(r_object$`__weakref__`)
  expect_false(exists("py.objectName", r_class))
  expect_null(r_object$`py.objectName`)
  expect_false(exists("py.type", r_class))
  expect_null(r_object$`py.type`)

  returnValue <- pyCall("myFunc")
  expect_equal("MyClass", class(returnValue)[1])
})

test_that("a pyObject can have a new field added", {

    pyExec('
class MyClass:
  def __init__(self):
    self.x = 0
  def increment(self):
    self.x += 1

myObj=MyClass()
')

x<-pyGet("myObj")
x$foo<-"bar"

#expect_equal(pyGet("myObj")$foo, "bar")

})

