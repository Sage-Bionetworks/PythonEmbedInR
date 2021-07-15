context("testPyPkgWrapper generate R wrappers")

# insert current dir to python search path
pyImport("sys")
pyExec("sys.path.insert(0, \".\")")

callback <- function(name, def) {
  setGeneric(name, def)
}

.namespace <- environment()
assignEnumCallback <- function(name, keys, values) {
  assign(name, setNames(values, keys), .namespace)
}

test_that("defineEnum", {
  pyImport("gateway")
  keys = c("BLACK", "WHITE")
  values = c("#000000", "#FFFFFF")
  PythonEmbedInR:::defineEnum(assignEnumCallback = assignEnumCallback,
                             name = "COLOR",
                             keys = keys,
                             values = values)
  expect_equal(COLOR, setNames(values, keys))
})

test_that("defineConstructor", {
  pyImport("testPyPkgWrapper")
  pyImport("gateway")
  pyParams = list(args=c('self'))
  PythonEmbedInR:::defineConstructor(module = "testPyPkgWrapper",
                                     setGenericCallback = callback,
                                     name = "MyObj",
                                     pyParams = pyParams)
  obj <- MyObj()
  expect_equal(obj$print(), 0)
  expect_equal(obj$inc(), 1)
})

test_that("defineFunction with same name", {
  pyImport("testPyPkgWrapper")
  pyImport("gateway")
  pyParams = list(args=c('input'), varargs=NULL, keywords=NULL, defaults=c())
  PythonEmbedInR:::defineFunction(rName = "myFun",
                                  pyName = "myFun",
                                  pyParams = pyParams,
                                  functionContainerName = "testPyPkgWrapper",
                                  setGenericCallback = callback)
  expect_equal(myFun(-4), 4)
  expect_equal(myFun(4), 4)
})

test_that("defineFunction with different name", {
  pyImport("testPyPkgWrapper")
  pyImport("gateway")
  pyParams = list(args=c('n'), varargs=NULL, keywords=NULL, defaults=c())
  PythonEmbedInR:::defineFunction(rName = "myRFunc",
                                  pyName = "myFun",
                                  pyParams = pyParams,
                                  functionContainerName = "testPyPkgWrapper",
                                  setGenericCallback = callback)
  expect_equal(myRFunc(-4), 4)
  expect_equal(myRFunc(4), 4)
})

test_that("defineFunction complex signature", {
  pyImport("testPyPkgWrapper")
  pyImport("gateway")
  pyParams = list(args=c('a', 'b', 'c'), varargs=NULL, keywords='**kwargs', defaults=c(2, 3))
  PythonEmbedInR:::defineFunction(rName = "myRFuncComplexArgs",
                                  pyName = "myFunComplexArgs",
                                  pyParams = pyParams,
                                  functionContainerName = "testPyPkgWrapper",
                                  setGenericCallback = callback)
  expect_equal(myRFuncComplexArgs(1, d=4), 10)
  expect_equal(myRFuncComplexArgs(1, b=3, c=5), 9)

  # also confirm formals are assigned to the wrapper
  expected_formals <- alist(a=, b=2, c=3, ...=)
  expect_equal(names(expected_formals), names(formals(myRFuncComplexArgs)))
  expect_equal(unlist(expected_formals, use.names=FALSE), unlist(formals(myRFuncComplexArgs), use.names=FALSE))
})

test_that("GeneratorWrapper", {
  pyImport("testPyPkgWrapper")
  pyImport("gateway")
  pyParams = list(args=c(), varargs=NULL, keywords=NULL, defaults=c())
  PythonEmbedInR:::defineFunction(rName = "myGenerator",
                                  pyName = "myGenerator",
                                  pyParams = pyParams,
                                  functionContainerName = "testPyPkgWrapper",
                                  setGenericCallback = callback)
  generator <- myGenerator()
  expect_equal("GeneratorWrapper", class(generator)[1])
  expect_equal(0, generator$nextElem())
  expect_equal(1, generator$nextElem())
  expect_error(generator$nextElem())
})

test_that("defineFunction with transform return object", {
  pyImport("testPyPkgWrapper")
  pyImport("gateway")
  inc <- function(x) {
    x + 1
  }
  pyParams = list(args=c('n'), varargs=NULL, keywords=NULL, defaults=c())
  PythonEmbedInR:::defineFunction(rName = "myFun",
                                  pyName = "myFun",
                                  pyParams = pyParams,
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
                    container = "testPyPkgWrapper",
                    setGenericCallback = callback,
                    assignEnumCallback = assignEnumCallback,
                    functionFilter = removeIncObj,
                    functionPrefix = "test")
  obj = MyObj()
  expect_equal(obj$print(), 0)
  expect_equal(obj$inc(), 1)
  expect_equal(5, testGetValue(DIGIT$FIVE))
  expect_equal(testMyFun(-4), 4)
})

test_that("generateRWrappers with mismatch params", {
  expect_error(generateRWrappers(pyPkg = "testPyPkgWrapper",
                                 container = "testPyPkgWrapper.MyObj",
                                 setGenericCallback = callback,
                                 assignEnumCallback = assignEnumCallback
  ))
  expect_error(generateRWrappers(pyPkg = "testPyPkgWrapper",
                                 container = "testPyPkgWrapper",
                                 setGenericCallback = callback,
                                 assignEnumCallback = assignEnumCallback,
                                 pySingletonName = "myObj"
  ))
  expect_error(generateRWrappers(pyPkg = "testPyPkgWrapper",
                                 container = "testPyPkgWrapper",
                                 setGenericCallback = callback,
                                 enumFilter = function(x){x}))
})


test_that("generateRWrappers with singleton object", {
  generateRWrappers(pyPkg = "testPyPkgWrapper",
                    container = "testPyPkgWrapper.MyObj",
                    setGenericCallback = callback,
                    assignEnumCallback = assignEnumCallback,
                    pySingletonName = "myObj")
  pyImport("testPyPkgWrapper")
  pyExec("myObj = testPyPkgWrapper.MyObj()")
  expect_equal(print(), 0)
  expect_equal(inc(), 1)
})

test_that("generateRdFiles", {
  dir <- getwd()
  generateRdFiles(srcRootDir = dir,
                  pyPkg = "testPyPkgWrapper",
                  container = "testPyPkgWrapper")
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
                  container = "testPyPkgWrapper",
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
  # first select MyObj container only
  generateRdFiles(srcRootDir = dir,
                  pyPkg = "testPyPkgWrapper",
                  container = "testPyPkgWrapper",
                  functionFilter = remove,
                  classFilter = selectMyObj)
  expect_true(file.exists(file.path(dir, "auto-man")))
  expect_false(file.exists(file.path(dir, "auto-man", "myFun.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj-class.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj.Rd")))
  # now select myFun only, but do not wipe out MyObj
  generateRdFiles(srcRootDir = dir,
                  pyPkg = "testPyPkgWrapper",
                  container = "testPyPkgWrapper",
                  functionFilter = selectmyFun,
                  classFilter = remove,
                  keepContent = TRUE)
  expect_true(file.exists(file.path(dir, "auto-man")))
  expect_true(file.exists(file.path(dir, "auto-man", "myFun.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj-class.Rd")))
  expect_true(file.exists(file.path(dir, "auto-man", "MyObj.Rd")))
})
