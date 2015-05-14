library(testthat)

# cat(deparse(dir()[grep(".R$", dir())]))
test_this <- c("001_load_package.R", "002_basic_functions.R",  "003_set_get.R",
               "004_execute_string.R", "005_execute_file.R",  "006_call_methods.R",
               "007_utf8.R")#, "008_memory_profiling.R")

for (i in test_this){
    cat(i, "\n")
    test_file(i)
    cat("\n\n")
}

print("Finished Testing!")

