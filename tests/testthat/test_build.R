context("test build")

test_that("python version is 3.5.3", {
  pyExec('import platform')
  expect_equal('3.5.3', pyGet('platform.python_version()'))
})

test_that("pip can be imported", {
  pyImport('pip')
  pyImport('ssl')
  expect_(pyGet('ssl.OPENSSL_VERSION'), 'OpenSSL')
})

test_that("other package can be installed", {
  testPackage<-'ggplot2'
  try(remove.packages(testPackage), silent=T)
  install.packages(testPackage, repos='https://cran.cnr.berkeley.edu/')
  library(testPackage, character.only=T)
})