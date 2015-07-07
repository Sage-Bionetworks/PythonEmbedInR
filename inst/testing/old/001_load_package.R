#' # Try to connect to Python <br/>

#' ## Load packages
require(testthat)
require(PythonInR)
invisible(capture.output(pyConnect()))

#' ## Test if R is connected to Python
expect_that(pyIsConnected(), equals(TRUE))

#' ## Close the connection and reconnect
expect_that(pyExit(), equals(NULL))
expect_that(pyIsConnected(), equals(FALSE))

#' ## Reconnect
for (i in 1:10){
    pyConnect()
    expect_that(pyIsConnected(), equals(TRUE))
    expect_that(pyExit(), equals(NULL))
    expect_that(pyIsConnected(), equals(FALSE))
}

pyConnect()

