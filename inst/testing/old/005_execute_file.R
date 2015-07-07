#' # Test file execution
require(testthat)
require(PythonInR)
invisible(capture.output(pyConnect()))

pyExecfile(file.path(path.package("PythonInR"), "tests/Test_cases.py"))

myInt = 6
myDouble = 3.14
myString = "Test String!"
# <<< NOTE: This is necessary since my test cases are written in Linux (utf-8)
#           when I run them on Windows, Windows will assume that the file has
#           the local encoding and produce an error (since the encoding of the
#           reference variable is messed up) even when the encoding in Python
#           is correct. (This worked on Windows with latin1 as default encoding) >>>
myUnicode = iconv('Äöüß 945 hdfji', from="UTF-8")
    
myList = list(2, 3, "Hallo")
myTuple = list(1, 2, "Hallo")
mySet = list(myTuple)

expect_that(pyGet("myInt"), equals(myInt))
expect_that(pyGet("myDouble"), equals(myDouble))
expect_that(pyGet("myString"), equals(myString))
expect_that(pyGet("myUnicode"), equals(myUnicode))
expect_that(pyGet("myList"), equals(myList))
expect_that(pyGet("myTuple"), equals(myTuple))

