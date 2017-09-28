context("checkInterrupt")

test_that("checkInterrupt", {
	pyImport("ctypes")
	pyExec("peirModule=ctypes.CDLL('PythonEmbedInR.so')")
	pyExec("result=peirModule.checkInterrupt()")
	expect_equal(0, pyGet("result"))
})
