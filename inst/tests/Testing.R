
testConnectExit <- function(){
    require(testthat)
    require(PythonInR)

    #' ## Test if R is connected to Python
    expect_that(pyIsConnected(), equals(TRUE))

    #' ## Close the connection and reconnect
    expect_that(pyExit(), equals(NULL))
    expect_that(pyIsConnected(), equals(FALSE))

    #' ## Reconnect
    for (i in 1:100){
        expect_that(pyConnect(), prints_text("Initialize Python"))
        expect_that(pyIsConnected(), equals(TRUE))
        expect_that(pyExit(), equals(NULL))
        expect_that(pyIsConnected(), equals(FALSE))
    }

    expect_that(pyConnect(), prints_text("Initialize Python"))
}

#' # Test the auxiliary functions
testBasicFunctions <- function(dll=NULL){
    require(testthat)
    require(PythonInR)
    
    if (!is.null(dll)) pyConnect(dll)
    cat("Python Info:\n")
    print(pyInfo())
    expect_that(pyHelp("string"), prints_text("DESCRIPTION"))
    expect_that(mean(table(unlist(lapply(1:5, function(x) pyDir())))), equals(5))
        
    expect_that(pyType('__builtins__'), equals("module"))
}

#' ## Define some auxilary functions
#' ### buildAscii
# The function build Ascii generates a charcter vector of length len with clen
# number of characters.
# example usage: buildAscii(3, 2)
buildAscii <- function(len, clen=100){
    fun <- function(x) paste(rawToChar(as.raw(sample(33:126, clen, replace=TRUE)), multiple=TRUE), collapse="")
    sapply(1:len, fun)
}

is.identical <- function(x, y){
    if (class(x) == "list" || class(y) == "list"){
        xv <- rapply(x, function(z) z)
        xc <- rapply(x, function(z) class(z))
        xt <- rapply(x, function(z) typeof(z))
        yv <- rapply(y, function(z) z)
        yc <- rapply(y, function(z) class(z))
        yt <- rapply(y, function(z) typeof(z))
    }else{
        xv <- x
        xc <- class(x)
        xt <- typeof(x)
        yv <- y
        yc <- class(y)
        yt <- typeof(y)
    }
    if ( all(xv == yv) & all(xc == yc) & all(xt == yt) ) return(TRUE)
    FALSE
}

# a function to generate test values
genVal <- function(i=-1){
    if (i<0) i <- sample(1:4, 1)
    n <- sample(1:100, 1)
    if (i == 1){
        x <- as.list(as.logical(sample(c(0,1), n, replace=TRUE)))
    }else if (i == 2) {
        x <- as.list(sample(1:1000000, n))
    }else if (i == 3) {
        x <- as.list(rnorm(n) * 1000000)
    }else {
        x <- as.list(sapply(1:n, function(x) intToUtf8(sample(1:1000, 100, replace=TRUE))))
    }
    return(x)
}

genNamedList <- function(difficult=TRUE){
    val <- genVal()
    if (difficult){
        fun <- function(x) intToUtf8(sample(32:256, 10))
    }else{
        fun <- function(x) paste(sample(LETTERS, 10), collapse="")
    }
    nam <- sapply(1:length(val), fun)
    names(val) <- nam
    val
}

testGetSet <- function(dll=NULL){
    require(testthat)
    require(PythonInR)
    if (!is.null(dll)) pyConnect(dll)
    
    #' ## Empty Elements
    #' <<<TODO: Das hab ich bis jetzt vergessen!>>>
    x <- list(logical(), numeric(), integer(), character(), list(), data.frame(), matrix())
    for (i in 1:length(x)){
        pySet(sprintf("r%i", i), x[[i]])
        print(pyGet(sprintf("r%i", i)))
    }

    #' ## One dimensional elements
    x <- list(logical=TRUE, integer=1, double=pi,
              ascii = paste(LETTERS, collapse=" "),
              utf8 = "Some text with some Utf8 characters at the end! äöüß")
    for (i in 1:length(x)){
        print(sprintf("%s", names(x)[i]))
        pySet(sprintf("r%i", i), x[[i]])
        expect_that(pyGet(sprintf("r%i", i)), equals(x[[i]]))
    }

    #' ## Objects with length bigger than: 1
    x <- list(logical=as.logical(sample(c(0,1), 1000, replace=TRUE)),
              integer=sample(1:1000000, 1000),
              double=rnorm(1000) * 1000000,
              ascii=buildAscii(1000),
              utf8=sapply(1:1000, function(x) intToUtf8(sample(1:1000, 1000, replace=TRUE)))
              )
    for (i in 1:length(x)){
        print(names(x)[i])
        pySet(sprintf("r%i", i), x[[i]])
        expect_that(pyGet(sprintf("r%i", i)), equals(x[[i]]))
    }

    #' ## Lists
    #' ### simple lists
    x <- list(list1=list(1),
              list2=setNames(list(intToUtf8(sample(1:1000, 1000, replace=TRUE))), "charList")
              )
    for (i in 1:length(x)){
        pySet(sprintf("r%i", i), x[[i]])
        expect_that(pyGet(sprintf("r%i", i), simplify=FALSE), is_identical_to(x[[i]]))
    }

    #' ### more complicated lists
    # The comparison is a little bit complicated since Python dictonaries change
    # the order of the elements therefore the order of the elements must be ignored.
    x <- list(A=genVal(1),
              B=genVal(2),
              C=genVal(3),
              D=as.list(buildAscii(1000)),
              E=genVal(4)
             )
    for (i in 1:length(x)){
        pySet(sprintf("r%i", i), x[[i]])
        expect_that(pyGet(sprintf("r%i", i), simplify=FALSE), is_identical_to(x[[i]]))
    }

    #' ### nested lists with names
    d <- FALSE
    x <- list(genNamedList(d), genNamedList(d), genNamedList(d), 
              genNamedList(d), 
              list(genNamedList(d), 
                   list(genNamedList(d)),  genNamedList(d))
              )
    expect_that(pySet("r", x), equals(0))
    expect_that(is.identical(sort(names(unlist(x))),
                             sort(names(unlist(pyGet("r"))))), equals(TRUE))

    #' ## Matrices
    x <- matrix(1:8, 4, 2)
    rownames(x) <- paste0("row", (1:dim(x)[1]))
    colnames(x) <- paste0("col", (1:dim(x)[2]))
    expect_that(pySet("r", x), equals(0))
    expect_that(pyGet("r"), is_identical_to(x))
    M <- as.matrix(cars)
    rownames(M) <- paste0("row", (1:dim(M)[1]))
    expect_that(pySet("rmatrix", M), equals(0))
    expect_that(pyGet("rmatrix"), is_identical_to(M))

    #' ## Data.Frame
    rownames(cars) <- buildAscii(dim(cars)[1], 5)
    expect_that(pySet("r", cars), equals(0))
    # NOTE: since Python dict changes the order of the columns I can't translate it 1:1
    expect_that(pyGet("r")[,colnames(cars)], is_identical_to(cars))  
}

testExecuteString <- function(dll=NULL){
    require(testthat)
    require(PythonInR)
    if (!is.null(dll)) pyConnect(dll)
    
    #' ## Test pyExec
    #' pyExec can execute multiple lines printed values are shown in the R stdout
    #' evaluated values not.
cmd <- "
x = 3
y = 4
z = x * y
print(z)
"
    expect_that(pyExec(cmd), prints_text("12"))
    cat("passed 1 / 20 tests!\n")

    #' ### Test error handling
    expect_that(expect_that(pyExec("x=4/0"), prints_text("ZeroDivisionError")), throws_error())
    cat("passed 2 / 20 tests!\n")

    #' ## Test pyExecp
    #' pyExecp executes a single line, every evaluated statement is printed in the R stdout
    expect_that(pyExecp("z"), prints_text("12"))
    cat("passed 3 / 20 tests!\n")
    #' ### Test error handling
    expect_that(expect_that(pyExecp("x=4/0"), prints_text("ZeroDivisionError")), throws_error())
    cat("passed 4 / 20 tests!\n")
    
    #' ## Differences between pyExec and pyExecp
    #' pyExecp executes only a the first line of the code the others are obmitted
    #' pyExecp is intended to behave more like the Python terminal
pyExec('
def fun():
    return("Hello R!")
')
    expect_that(pyExec("fun()"), prints_text("^([A-Z]+)?$", perl = TRUE))
    cat("passed 5 / 20 tests!\n")
    expect_that(pyExecp("fun()"), prints_text("Hello R"))
    cat("passed 6 / 20 tests!\n")

    #' ## Test pyExecg
    #' pyExecg executes the provided code and returns the during the execution assigned values
    expect_that(pyExecg('x = 5*5')[['x']], equals(25))
    cat("passed 7 / 20 tests!\n")
    #' ### Test error handling
    expect_that(expect_that(pyExecg("x=4/0"), prints_text("ZeroDivisionError")), throws_error())
    cat("passed 8 / 20 tests!\n")
    
    #' ### Test different options of pyExecg
    expect_that(pyExecg("x=fun()")[['x']], equals("Hello R!"))
    cat("passed 9 / 20 tests!\n")
    #' #### returnToR
    expect_that(pyExecg("x=4", returnToR=FALSE)[['x']], equals(NULL))
    cat("passed 10 / 20 tests!\n")
    #' #### mergeNamespaces 
    expect_that(pyExecg("some_new_variable=4", mergeNamespaces=TRUE)[[1]], equals(4))
    cat("passed 11 / 20 tests!\n")
    expect_that(pyPrint(some_new_variable), prints_text("4"))
    cat("passed 12 / 20 tests!\n")
    #' #### override
    expect_that(pyExecg("some_new_variable=1", mergeNamespaces=TRUE, override=FALSE)[[1]], equals(1))
    cat("passed 13 / 20 tests!\n")
    # should be still 4 since override is FALSE
    expect_that(pyPrint(some_new_variable), prints_text("4"))
    cat("passed 14 / 20 tests!\n")
    expect_that(pyExecg("some_new_variable2=5", mergeNamespaces=TRUE, override=FALSE)[[1]], equals(5))
    cat("passed 15 / 20 tests!\n")
    # show that the variable get's assigned when it doesn't already exits
    expect_that(pyPrint(some_new_variable2), prints_text("5"))
    cat("passed 16 / 20 tests!\n")
    expect_that(pyExecg("some_new_variable=1", mergeNamespaces=TRUE)[[1]], equals(1))
    cat("passed 17 / 20 tests!\n")
    # should be 1 since override is TRUE
    expect_that(pyPrint(some_new_variable), prints_text("1"))
    cat("passed 18 / 20 tests!\n")
    
    #' ### Test error handling
cmd <- '
a = "this is a multi line test"
b = 3
b = 4/0
b = 5
'
    expect_that(
        expect_that(
            pyExecg(cmd, mergeNamespaces=TRUE),
            prints_text("ZeroDivisionError")
            ),
        throws_error()
        )
    cat("passed 19 / 20 tests!\n")
    
    #' ***NOTE:*** since all the commands are executed in a new namespace
    #' non of the script will have any effect since the function will exit before
    #' the namespaces are merged
    expect_that(
        expect_that(
            pyPrint(b),
            prints_text("NameError")
            ),
        throws_error())
    cat("passed 20 / 20 tests!\n")
}

testExecFile <- function(dll=NULL){
    require(testthat)
    require(PythonInR)
    if (!is.null(dll)) pyConnect(dll)
    filename <- file.path(path.package("PythonInR"), "tests/Test_cases.py")
    pyExecfile(filename)
    
    myInt = 6
    myDouble = 3.14
    myString = "Test String!"
    # <<< NOTE: This is necessary since my test cases are written in Linux (utf-8)
    #           when I run them on Windows, Windows will assume that the file has
    #           the local encoding and produce an error (since the encoding of the
    #           reference variable is messed up) even when the encoding in Python
    #           is correct. (This worked on Windows with latin1 as default encoding) >>>
    myUnicode = iconv('Äöüß 945 hdfji')
        
    myList = list(2, 3, "Hallo")
    myTuple = list(1, 2, "Hallo")
    mySet = list(myTuple)

    expect_that(pyGet("myInt"), equals(myInt))
    expect_that(pyGet("myDouble"), equals(myDouble))
    expect_that(pyGet("myString"), equals(myString))
    expect_that(pyGet("myUnicode"), equals(myUnicode))
    expect_that(pyGet("myList"), equals(myList))
    expect_that(pyGet("myTuple"), equals(myTuple))
}

testFunctionCalls <- function(dll=NULL){
    #' # Test function calls in python
    require(testthat)
    require(PythonInR)
    if (!is.null(dll)) pyConnect(dll)
    
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
    cat("No Error!\n")
}

testEncoding <- function(dll=NULL){
    #' # Test utf-8
    #' This test is mainly interesting for windows
    require(testthat)
    require(PythonInR)
    if (!is.null(dll)) pyConnect(dll)

    rAscii <- "abcABC"
    pySet("ascii", rAscii)
    expect_that(pyGet("ascii"), equals(rAscii))

    # is necessary for more info see 005_execute_file.R
    rUtf8 <- iconv("äöüßÄöü", from="latin1")
        
    pySet("utf8", rUtf8)
    expect_that(pyGet("utf8"), equals(rUtf8))
    
    cat("No Error!\n")
}

# non of the other python packages could handle this test
testMessyDataTransfer <- function(dll=NULL){
    require(PythonInR)

    require('corpus.Project.Euclid')
    data("Project_Euclid")

    pySet("pe", Project_Euclid)
    pe <- pyGet("pe")
    expect_that(class(pe), equals(class(Project_Euclid)))
    expect_that(dim(pe), equals(dim(Project_Euclid)))
    
    fuzzyEqual <- function(x, y){
        if (!(length(x) + length(y))) return(TRUE)
        all.equal(x, y)
    }
   
    selection <- sample(1:dim(Project_Euclid)[1], 100)
    allEqual <- all(mapply(fuzzyEqual, pe[selection,], Project_Euclid[selection,]))  
    expect_that(allEqual, equals(TRUE))
    cat("No Error!\n")
}

testConnectExit()
dll="python33.dll"
testBasicFunctions(dll)
testGetSet(dll)
testExecuteString(dll)
testExecFile(dll)
testFunctionCalls(dll)
testEncoding(dll)
testMessyDataTransfer(dll)

pyExecp("dir()")

