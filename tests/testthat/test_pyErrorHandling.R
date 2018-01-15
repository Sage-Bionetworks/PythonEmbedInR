context("test python error handling")

# this python code replaces '__getStderr' with a mock fcn that returns None
mock__getStderr<-'
orig__getStderr=__getStderr
def __getStderr():
 return None
'

errorGenDef<-'
def errorGen():
 raise Exception("This is an error!")
'

isWindows<-.Call( "isDllVersion")

if (isWindows) {
	setup(pyExec(mock__getStderr))

	test_that("pyExec errors are correctly turned into R errors", {
		# On Windows, the unmodified PythonInR code returns an integer error code rather than raising an exception
		expect_error(pyExec("raise Exception('foo')"))
	})
	
	test_that("pyCall errors are correctly turned into R errors", {
		# On Windows, the unmodified PythonInR code returns a try-error rather than raising an exception
		pyExec(errorGenDef)
		expect_error(pyCall("errorGen"))
	})
	
	# this python code restores __getStderr
	restore__getStderr<-'__getStderr=orig__getStderr'
	teardown(pyExec(restore__getStderr))
}
