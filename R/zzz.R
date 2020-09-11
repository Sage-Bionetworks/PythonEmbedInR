
pathToPythonLibraries<-function(libname, pkgname) {
  # Note: 'pythonLibs' is defined in configure.win
  # removing the '/' from '/x64' or '/i386'
  arch <- substring(Sys.getenv("R_ARCH"), 2)
  pathToPythonLibraries<-file.path(libname, pkgname, paste0("pythonLibs", arch))
  pathToPythonLibraries<-gsub("/", "\\", pathToPythonLibraries, fixed=T)
  pathToPythonLibraries
}

# NOTE:  This is one of several places the version is hard coded.  See also AutodetectPython.R, configure, configure.win 
PYTHON_VERSION<-"3.6"

.onLoad <- function(libname, pkgname) {
  packageRootDir<-file.path(libname, pkgname)
  library.dynam.unload("PythonEmbedInR", packageRootDir)

  if (Sys.info()['sysname']=="Windows"){
    # add python libraries to Path
    extendedPath <- sprintf("%s%s%s", Sys.getenv("PATH"), .Platform$path.sep, pathToPythonLibraries(libname, pkgname))
    Sys.setenv(PATH=extendedPath)

    arch <- substring(Sys.getenv("R_ARCH"), 2)
    pythonPathEnv<-paste(file.path(packageRootDir, paste0("pythonLibs", arch)), file.path(packageRootDir, paste0("pythonLibs", arch), "Lib\\site-packages"), sep=";")
  } else {
    pythonPathEnv<-file.path(packageRootDir, "lib")
  }

  Sys.setenv(PYTHONHOME=packageRootDir)
  Sys.setenv(PYTHONPATH=pythonPathEnv)

  library.dynam("PythonEmbedInR", pkgname, libname, local=FALSE)

  if (Sys.info()['sysname']=='Darwin') {
    sharedObjectFile <- system.file("lib/libcrypto.1.0.0.dylib", package="PythonEmbedInR")
    dyn.load(sharedObjectFile, local=FALSE)
    sharedObjectFile <- system.file("lib/libssl.1.0.0.dylib", package="PythonEmbedInR")
    dyn.load(sharedObjectFile, local=FALSE)
    Sys.setenv(SSL_CERT_FILE = system.file(paste0("lib/python", PYTHON_VERSION, "/site-packages/pip/_vendor/requests/cacert.pem"), package="PythonEmbedInR"))
  }
  if (Sys.info()['sysname']=="Linux") {
    # if we build a static library, libpythonX.Xm.a, instead of a dynamically linked one,
    # libpythonX.Xm.so.1.0, then don't do the following
    sharedObjectFile<-system.file(paste0("lib/libpython", PYTHON_VERSION, "m.so.1.0"), package = "PythonEmbedInR")
    if (file.exists(sharedObjectFile)) {
      dyn.load(sharedObjectFile, local = FALSE)
    }
  }

  pyConnect()
  tryCatch({
    pyImport("pip")
  }, error = function(e) {
    stop("ERROR: Missing system dependencies. Please make sure that your machine has the required dependencies listed in the SystemRequirements field of the DESCRIPTION file: https://github.com/Sage-Bionetworks/PythonEmbedInR/blob/master/DESCRIPTION")
  })
  pyImport("sys")
  pyExec(sprintf("sys.path.insert(0, \"%s\")", file.path(packageRootDir, "python")))
  invisible(NULL)
}

.onUnload <- function( libpath ){
  pyExit()
  library.dynam.unload( "PythonEmbedInR", libpath )
}

