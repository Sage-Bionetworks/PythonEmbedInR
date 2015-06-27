#  -----------------------------------------------------------
#  pySource
#  ========
#' @title Read mixed R and Python code from a file
#'
#' @description The function BEGIN.Python allows interactive development
#'              but doesn't work 
#' @param file see documentation of source
#' @param local see documentation of source
#' @param echo see documentation of source
#' @param print.eval see documentation of source
#' @param verbose see documentation of source
#' @param prompt.echo see documentation of source
#' @param max.deparse.length see documentation of source
#' @param chdir see documentation of source
#' @param encoding see documentation of source
#' @param continue.echo see documentation of source
#' @param skip.echo see documentation of source
#' @param keep.source see documentation of source
#' @details The function pySource workes exactly like source but code 
#'          which is in closed between BEGIN.Python and END.Python is
#'          replaced by pyExec and the quoted version of the code.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' \dontrun{
#' writeLines(c("x <- 3", "BEGIN.Python()", 
#'              "x=3**3", "print(3*u'Hello R!\\n')", 
#'              "END.Python"), "myMixedCode.R")
#' pySource("myMixedCode.R")
#' }
#  -----------------------------------------------------------
pySource <- function(file, local = FALSE, echo = verbose, print.eval = echo, 
    verbose = getOption("verbose"), prompt.echo = getOption("prompt"), 
    max.deparse.length = 150, chdir = FALSE, encoding = getOption("encoding"), 
    continue.echo = getOption("continue"), skip.echo = 0, 
    keep.source = getOption("keep.source")){
    code <- readLines(file)
    temp <- tempfile()
    code <- paste(code, collapse="\n")

    m <- unlist(regmatches(code,
                           gregexpr("BEGIN\\.Python\\(\\)(.*?)END\\.Python", code)))
    repl <- gsub("END.Python", "", gsub("BEGIN.Python()", "", m, fixed=T), fixed=T)
    repl <- sprintf("pyExec(%s)", shQuote(repl))
    for (i in 1:length(m)){
        code <- sub(m[i], repl[i], code, fixed=TRUE)
    }

    writeLines(code, temp)
    source(temp, local, echo, print.eval, verbose, prompt.echo, 
           max.deparse.length, chdir, encoding, continue.echo, skip.echo,
           keep.source)
}

#  -----------------------------------------------------------
#  BEGIN.Python
#  ============
#' @title Execute Python interactively from within R
#'
#' @description The function BEGIN.Python starts an interactive
#'              execute, print loop.
#' @details BEGIN.Python emulates the behavior of the Python terminal
#'          and therefore allows interactive Python code development
#'          from within R.
#' @return Returns the entered code back to R, code lines which throw an
#'         exception are obmitted.
#' @examples
#' \dontshow{PythonInR:::pyCranConnect()}
#' \dontrun{
#' code <-
#' BEGIN.Python()
#' import os
#' os.getcwd()
#' dir(os)
#' x = 3**3
#' END.Python
#' pyGet0("x")
#' }
#  -----------------------------------------------------------
BEGIN.Python <- function(){
    f <- file("stdin")
    open(f)
    cat("py> ")
    pyCode <- character()
    while(TRUE) {
        line <- readLines(f,n=1)
        if (grepl("END.Python", line, fixed=TRUE)) break
        tryCatch({pyExecp(line)
                  pyCode <- c(pyCode, line)
                 },
                 warning=function(w){ print(w) },
                 error=function(e){ print(e) }
                )
        cat("py> ")
    }
    return(invisible(pyCode))
}

