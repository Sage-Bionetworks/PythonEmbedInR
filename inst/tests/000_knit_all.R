library(testthat)
library(knitr)

test_this <- c("001_load_package.R", "002_basic_functions.R",  "003_set_get.R",
               "004_execute_string.R", "005_execute_file.R",  "006_call_methods.R",
               "007_utf8.R")#, "008_memory_profiling.R")


for (i in test_this){
    cat(i, "\n")
    spin(i)
    cat("\n\n")
}

