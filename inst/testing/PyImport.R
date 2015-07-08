#' # pyImport
require(testthat)
require(PythonInR)
invisible(capture.output(pyConnect()))

## import 0 
expect_that(pyImport("os"), equals(NULL))
expect_that("os" %in% pyDir(), equals(TRUE))
expect_that("os" %in% ls(), equals(TRUE))

## import + as 1 
expect_that(pyImport("xml", as="xm"), equals(NULL))
expect_that("xm" %in% pyDir(), equals(TRUE))
expect_that("xm" %in% ls(), equals(TRUE))

## import + from 2 
expect_that(pyImport(from="mmap", import="mmap"), equals(NULL))
expect_that(all("mmap" %in% pyDir()), equals(TRUE))
expect_that(all("mmap" %in% ls()), equals(TRUE))

expect_that(pyImport(from="datetime", import="*"), equals(NULL))
expect_that(all(c("date", "time") %in% pyDir()), equals(TRUE))
expect_that(all(c("date", "time") %in% ls()), equals(TRUE))

expect_that(pyImport(from="popen2", import=c("popen2", "popen3")), equals(NULL))
expect_that(all(c("popen2", "popen3") %in% pyDir()), equals(TRUE))
expect_that(all(c("popen2", "popen3") %in% ls()), equals(TRUE))

## import + as + from 3
expect_that(pyImport(from="difflib", import=c('ndiff', 'reduce', 'restore'),
                     as=c('x_ndiff', 'y_reduce', 'z_restore')), equals(NULL))
expect_that(all(c('x_ndiff', 'y_reduce', 'z_restore') %in% pyDir()), equals(TRUE))
expect_that(all(c('x_ndiff', 'y_reduce', 'z_restore') %in% ls()), equals(TRUE))

expect_that(pyImport(from="zlib", import=c("compress", "compressobj", "crc32", "decompress"), as="zl"), equals(NULL))
expect_that(all(c("compress", "compressobj", "crc32", "decompress") %in% pyDir("zl")), equals(TRUE))
expect_that(all(paste("zl", c("compress", "compressobj", "crc32", "decompress"), sep=".") %in% ls()), equals(TRUE))
