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

a = MyClass()')
  r_class <- pyObject("MyClass")

  # test r_class name
  expect_equal("MyClass", r_class$py.objectName)

  # test that r_class is an environment
  expect_true(is.environment(r_class))
  expect_true(environmentIsLocked(r_class))
  expect_true(exists("increment", r_class))

  # test that r_object is initialized
  r_object = pyObject("a")
  r_object$increment()
  expect_true(exists("x", r_object))
  expect_equal(1, r_object$x)

  # test private methods
  expect_false(exists("__init__", r_class))
  expect_error(r_object$`__init__`())
  expect_false(exists("_do_increment", r_class))
  expect_error(r_object$`_do_increment`())

  # test private non-methods
  expect_false(exists("__dict__", r_class))
  expect_error(r_object$`__dict__`)
  expect_false(exists("__doc__", r_class))
  expect_error(r_object$`__doc__`)
  expect_false(exists("__module__", r_class))
  expect_error(r_object$`__module__`)
  expect_false(exists("__weakref__", r_class))
  expect_error(r_object$`__weakref__`)
})

