#' # Test the auxiliary functions

require(testthat)
require(PythonInR)
invisible(capture.output(pyConnect()))

#' ## pyInfo
pyInfo()

#' ## pyHelp
expect_that(pyHelp("string"), prints_text("DESCRIPTION"))

#' ## pyDir()
#' I do 5 times the same count the occurence and take the mean which should be 5
expect_that(mean(table(unlist(lapply(1:5, function(x) pyDir())))), equals(5))

#' ## pyType
pyExec("x=3")
pyType('x')
