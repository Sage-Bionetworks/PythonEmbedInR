# <<<TODO: Add red background to error boxes "background-color:#FF0000 
# require(knitr)
# require(markdown) # required for md to html 
# markdownToHTML('001_load_package.md', '001_load_package.html')
# >>>    
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
    expect_that(pyConnect(), prints_text("Initialize Python"))
    expect_that(pyIsConnected(), equals(TRUE))
    expect_that(pyExit(), equals(NULL))
    expect_that(pyIsConnected(), equals(FALSE))
}

expect_that(pyConnect(), prints_text("Initialize Python"))

