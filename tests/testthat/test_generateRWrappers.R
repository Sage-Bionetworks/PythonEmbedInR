context("testPyPkgWrapper generate R wrappers")

pyExecp("sys.path")

callback <- function(name, def) {
  setGeneric(name, def)
}

test_that("defineConstructor", {
  pyImport("testPyPkgWrapper")
  pyImport("gateway")
  PythonEmbedInR:::defineConstructor(module = "testPyPkgWrapper",
                                     setGenericCallback = callback,
                                     name = "MyObj")
  obj <- MyObj()
  expect_equal(obj$print(), 0)
  expect_equal(obj$inc(), 1)
})

test_that("defineFunction with same name", {
  pyImport("testPyPkgWrapper")
  pyImport("gateway")
  PythonEmbedInR:::defineFunction(rName = "myFun",
                                  pyName = "myFun",
                                  functionContainerName = "testPyPkgWrapper",
                                  setGenericCallback = callback)
  expect_equal(myFun(-4), 4)
  expect_equal(myFun(4), 4)
})

test_that("defineFunction with different name", {
  pyImport("testPyPkgWrapper")
  pyImport("gateway")
  PythonEmbedInR:::defineFunction(rName = "myRFunc",
                                  pyName = "myFun",
                                  functionContainerName = "testPyPkgWrapper",
                                  setGenericCallback = callback)
  expect_equal(myRFunc(-4), 4)
  expect_equal(myRFunc(4), 4)
})

test_that("defineFunction with transform return object", {
  pyImport("testPyPkgWrapper")
  pyImport("gateway")
  inc <- function(x) {
    x + 1
  }
  PythonEmbedInR:::defineFunction(rName = "myFun",
                                  pyName = "myFun",
                                  functionContainerName = "testPyPkgWrapper",
                                  setGenericCallback = callback,
                                  transformReturnObject = inc)
  expect_equal(myFun(-4), 5)
  expect_equal(myFun(4), 5)
})

test_that("generateRWrappers", {
  removeIncObj <- function(x) {
    if (any(x$name == "incObj")) {
      NULL
    }
    x
  }
  generateRWrappers(pyPkg = "testPyPkgWrapper",
                    module = "testPyPkgWrapper",
                    setGenericCallback = callback,
                    modifyFunctions = removeIncObj,
                    functionPrefix = "test")
  obj = MyObj()
  expect_equal(obj$print(), 0)
  expect_equal(obj$inc(), 1)
  expect_equal(testMyFun(-4), 4)
})
