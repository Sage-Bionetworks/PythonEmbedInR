library(testthat)
library(PythonEmbedInR)

# Note:  The following doesn't help because it happens too late.  Needs to 
# happen before running devools::test()
# ensure shared object is in the location required to load the package
sourceFolder<-system.file("src", package="PythonEmbedInR")
sourceFolderExists<-nzchar(sourceFolder)
if (sourceFolderExists) {
	sharedObjectFileName<-paste0("PythonEmbedInR", .Platform$dynlib.ext)
	from <- file.path(sourceFolder, sharedObjectFileName)
	targetFolder<-file.path(sourceFolder, "..", "libs")
	to<-file.path(targetFolder, sharedObjectFileName)
	cat(sprintf("from:  %s exists?  %s\n", from, file.exists(from)))
	cat(sprintf("to:  %s exists?  %s\n", to, file.exists(to)))
	if (file.exists(from) && !file.exists(to)) {
		if (!dir.exists(targetFolder)) dir.create(targetFolder)
		file.copy(from, to)
	}
}

test_check("PythonEmbedInR")

# uninstall pandas
print("Uninstalling pandas ...")
package_dir <- gsub("(PythonEmbedInR).*", "\\1", getwd())
pyExec(sprintf("install_pandas.main('uninstall', '%s')", package_dir))