## Testing pyDict

context("pyDict")

test_that("pyDict", {
  pyExec('myPyDict = {"a":1, "b":2, "c":3}')
  myDict <- pyDict("myPyDict")
  expect_equal(myDict$get("a"), 1)
  expect_equal(myDict$pop("a"), 1)
  myDict$setdefault("a", "A") #previously this threw an error
})

