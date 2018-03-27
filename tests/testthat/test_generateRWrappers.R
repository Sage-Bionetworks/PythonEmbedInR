context("testPyPkgWrapper generate R wrappers")

# insert current dir to python search path
pyImport("sys")
pyExec("sys.path.insert(0, \".\")")

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

test_that("generateRdFiles", {
  dir <- getwd()
  generateRdFiles(srcRootDir = dir,
                  pyPkg = "testPyPkgWrapper",
                  module = "testPyPkgWrapper")
  expect_true(file.exists(file.path(dir, "auto-man")))
  expect_true(file.exists(file.path(dir, "auto-man", "incObj.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "myFun.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj-class.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj.Rd")))
})

test_that("generateRdFiles with prefix", {
  dir <- getwd()
  generateRdFiles(srcRootDir = dir,
                  pyPkg = "testPyPkgWrapper",
                  module = "testPyPkgWrapper",
                  functionPrefix = "test")
  expect_true(file.exists(file.path(dir, "auto-man")))
  expect_true(file.exists(file.path(dir, "auto-man", "testIncObj.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "testMyFun.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj-class.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj.Rd")))
})

test_that("generateRdFiles with keep content", {
  dir <- getwd()
  selectMyObj <- function(x) {
    if (any(x$name == "MyObj")) x else NULL
  }
  selectmyFun<- function(x) {
    if (any(x$name == "myFun")) x else NULL
  }
  remove <- function(x) NULL
  # first select MyObj class only
  generateRdFiles(srcRootDir = dir,
                  pyPkg = "testPyPkgWrapper",
                  module = "testPyPkgWrapper",
                  modifyFunctions = remove,
                  modifyClasses = selectMyObj)
  expect_true(file.exists(file.path(dir, "auto-man")))
  expect_false(file.exists(file.path(dir, "auto-man", "myFun.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj-class.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj.Rd")))
  # now select myFun only, but do not wipe out MyObj
  generateRdFiles(srcRootDir = dir,
                  pyPkg = "testPyPkgWrapper",
                  module = "testPyPkgWrapper",
                  modifyFunctions = selectmyFun,
                  modifyClasses = remove,
                  keepContent = TRUE)
  expect_true(file.exists(file.path(dir, "auto-man")))
  expect_true(file.exists(file.path(dir, "auto-man", "myFun.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj-class.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj.Rd")))
})
