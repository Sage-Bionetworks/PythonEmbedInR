#  -----------------------------------------------------------------------------
#  pyOptions
#  =========
#' @title a options object
#' @description Set options.
#' @param option TODO
#' @param value TODO
#' @details Hash options.
#  -----------------------------------------------------------------------------   
pyOptions <-
local({
    options <- list(quote = TRUE, hash = TRUE, openbounds = "()")
    function(option, value) {
        if (missing(option)) return(options)
        if (missing(value))
            options[[option]]
        else
            options[[option]] <<- value
    }
})

