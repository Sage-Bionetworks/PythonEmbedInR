#  -----------------------------------------------------------
#  pySource
#  ========
#'
#'
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

BEGIN.Python <- function(returnCode=TRUE){
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
    if (returnCode) return(pyCode)
    invisible(NULL)
}