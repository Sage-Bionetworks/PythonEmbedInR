#' # Test function calls in python
require(testthat)
require(PythonInR)
invisible(capture.output(pyConnect()))

#' ## get/set current working directory
# by default
expect_that(pyCall("chdir", args=list(getwd()), namespace="os"), equals(NULL))
expect_that(gsub("\\", "/", pyCall("getcwd", namespace="os"), fixed=TRUE), equals(getwd()))

#' ## test builtins functions (__builtins__)
pyImport("sys")
if (pyExecg("x=sys.version_info.major")[[1]] > 2){
    builtinNsp <- "builtins"
}else{
    builtinNsp <- "__builtin__"
}
expect_that(pyCall("abs", args=list(-5), namespace=builtinNsp), equals(5))
expect_that(pyCall("sum", args=list(1:5), namespace=builtinNsp), equals(sum(1:5)))
#' NOTE: since all integer variables are translated to long by default
#' the following code produces an error
expect_that(
    expect_that(
        pyCall("hex", args=list(255), namespace=builtinNsp),
        prints_text("TypeError")
    ),
    throws_error()
)

