context("test generate R wrappers")

callback <- function(name, def) {
  setGeneric(name, def)
}

test_that("defineConstructor", {
  pyImport("test")
  pyImport("gateway")
  PythonEmbedInR:::defineConstructor(module = "test",
                                     setGenericCallback = callback,
                                     name = "MyObj")
  obj <- MyObj()
  expect_equal(obj$print(), 0)
  expect_equal(obj$inc(), 1)
})

test_that("defineFunction with same name", {
  pyImport("test")
  pyImport("gateway")
  PythonEmbedInR:::defineFunction(rName = "myFun",
                                  pyName = "myFun",
                                  functionContainerName = "test",
                                  setGenericCallback = callback)
  expect_equal(myFun(-4), 4)
  expect_equal(myFun(4), 4)
})

test_that("defineFunction with different name", {
  pyImport("test")
  pyImport("gateway")
  PythonEmbedInR:::defineFunction(rName = "myRFunc",
                                  pyName = "myFun",
                                  functionContainerName = "test",
                                  setGenericCallback = callback)
  expect_equal(myRFunc(-4), 4)
  expect_equal(myRFunc(4), 4)
})

test_that("defineFunction with transform return object", {
  pyImport("test")
  pyImport("gateway")
  inc <- function(x) {
    x + 1
  }
  PythonEmbedInR:::defineFunction(rName = "myFun",
                                  pyName = "myFun",
                                  functionContainerName = "test",
                                  setGenericCallback = callback,
                                  transformReturnObject = inc)
  expect_equal(myFun(-4), 5)
  expect_equal(myFun(4), 5)
})

test_that("defineFunction with replace param", {
  pyImport("test")
  pyImport("gateway")
  pyExec("x = test.MyObj()")
  PythonEmbedInR:::defineFunction(rName = "incObj",
                                  pyName = "incObj",
                                  functionContainerName = "test",
                                  setGenericCallback = callback,
                                  replaceParam = "x")
  expect_equal(incObj(), 1)
  expect_equal(incObj(), 2)
})

test_that("generateRWrappers", {
  removeIncObj <- function(x) {
    if (any(x$name == "incObj")) {
      NULL
    }
    x
  }
  generateRWrappers(pyPkg = "test",
                    module = "test",
                    setGenericCallback = callback,
                    modifyFunctions = removeIncObj,
                    functionPrefix = "test")
  obj = MyObj()
  expect_equal(obj$print(), 0)
  expect_equal(obj$inc(), 1)
  expect_equal(testMyFun(-4), 4)
})
