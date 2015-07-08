#' # pyOptions
require(testthat)
require(PythonInR)
invisible(capture.output(pyConnect()))

## PySource
tmpfile <- tempfile()
writeLines(c("x <- 3", "BEGIN.Python()", 
             "x=3**3", "print(3*u'Hello R!\\n')", 
             "END.Python"), tmpfile)
expect_that(pySource(tmpfile), prints_text("Hello R!"))

