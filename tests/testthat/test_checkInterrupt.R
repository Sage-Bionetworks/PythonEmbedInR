context("checkInterrupt")

test_that("checkInterrupt", {
	pyImport("ctypes")
	# may have to use WinDLL() in place of CDLL() on Windows.  See: https://docs.python.org/3/library/ctypes.html
	libraryName<-sprintf("PythonEmbedInR%s", .Platform$dynlib.ext)
	if(.Platform$OS.type == "windows") {
		sharedLibrary<-libraryName
	} else {
		sharedLibraryLocation<-system.file("libs", package="PythonEmbedInR")
		sharedLibrary<-file.path(sharedLibraryLocation, libraryName)
	}
	pyExec(sprintf("peirModule=ctypes.CDLL('%s')", sharedLibrary))
	pyExec("result=peirModule.checkInterrupt()")
	expect_equal(0, pyGet("result"))
})
