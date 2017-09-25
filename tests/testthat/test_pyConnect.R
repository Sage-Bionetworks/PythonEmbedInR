context("test pyConnect")

test_that("R is connected to python", {
  pyConnect()
  expect_true(pyIsConnected())
})
