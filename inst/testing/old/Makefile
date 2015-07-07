
test001k:
	R -e 'library(knitr); spin ("001_load_package.R")'

test002k:
	R -e 'library(knitr); spin ("002_basic_functions.R")'

test003k:
	R -e 'library(knitr); spin ("003_set_get.R")'

test004k:
	R -e 'library(knitr); spin ("004_execute_string.R")'

test005k:
	R -e 'library(knitr); spin ("005_execute_file.R")'

test006k:
	R -e 'library(knitr); spin ("006_call_methods.R")'

test007k:
	R -e 'library(knitr); spin ("007_utf8.R")'

testA:
	R -e 'require("testthat"); test_file("001_load_package.R")'

testAll:
	R -e 'library(knitr); spin ("001_load_package.R")' \
	R -e 'library(knitr); spin ("002_basic_functions.R")' \
	R -e 'library(knitr); spin ("003_set_get.R")' \
	R -e 'library(knitr); spin ("004_execute_string.R")' \
	R -e 'library(knitr); spin ("005_execute_file.R")' \
	R -e 'library(knitr); spin ("006_call_methods.R")' \
	R -e 'library(knitr); spin ("007_utf8.R")'

cleanMd:
	rm *.md

cleanHtml:
	rm *.html
cleanAll:
	rm *.md *.html
