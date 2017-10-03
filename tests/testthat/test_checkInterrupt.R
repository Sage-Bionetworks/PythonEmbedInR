context("checkInterrupt")

test_that("checkInterrupt", {
	pyImport("ctypes")
	# may have to use WinDLL() in place of CDLL() on Windows.  See: https://docs.python.org/3/library/ctypes.html
	pyExec(sprintf("peirModule=ctypes.CDLL('PythonEmbedInR%s')", .Platform$dynlib.ext))
	pyExec("result=peirModule.checkInterrupt()")
	expect_equal(0, pyGet("result"))
})
