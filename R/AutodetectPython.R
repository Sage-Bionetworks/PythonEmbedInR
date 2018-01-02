# -----------------------------------------------------------
# autodetectPython
# ================
#' @title Autodetects the settings for Windows
#' 
#' @description Autodetects the settings needed to connect to
#'              the python dll file (\strong{only Windows}).
#' @return Returns a list containing the information necessary to
#'         connect to Python if a compatible Python, version was found,
#'         raises an error otherwise.
#' @examples
#' \dontrun{   
#'   autodetectPython()
#' }
# -----------------------------------------------------------
autodetectPython <- function(){
    if (pyIsConnected()) stop("when Python is connected to R the function autodetectPython doesn't work!")
    pyHome <- NULL
    rArch <- if (grepl("i386", R.version$arch)) '32bit' else '64bit'

		# NOTE:  This is one of several places the version is hard coded.  See also zzz.R, configure, configure.win
		pyMajorVersion <- as.integer(3) # get major version
		pyMinorVersion <- as.integer(5) # get minor version                                
		dllName <- sprintf("python%i%i.dll", pyMajorVersion, pyMinorVersion)
	
		arch <- substring(Sys.getenv("R_ARCH"), 2)
		pythonDllPath <- system.file(file.path(paste0("pythonLibs", arch), dllName), package="PythonEmbedInR")
	  pyArch <- sprintf("%ibit", guessDllVersion(pythonDllPath))
    if (pyArch != rArch) stop(sprintf("Python %s can't be connected with R %s!", pyArch, rArch))
    		
    # For simplicity I will just assume PYTHONHOME is where python.exe
    # is located (Another approach would be to get python path and look
    # which folder is sub folder to most of the other folders. But if
    # if a user thinks it is a good idea to change the python folder
    # structure he should just specify the settings via pyConnectWinDll.
    # Also reading sys.prefix should normally work.)
    pyHome <- dirname(pythonDllPath)
    
    # it would be the easiest to get the dll from the win32api package
    # win32api.GetModuleFileName(sys.dllhandle) but one can not assume
    # that everyone has win32api installed
    #
    # For now I just look in the PYTHONHOME folder which yields to the 
    # following cases:
    # 1) portable python   
    # 2) if python is registered in the path windows will find it
    # 3) the user should register python in the path or provide the folder
    if (any(grepl(dllName, dir(pyHome), fixed=TRUE))){
        dllDir = pyHome
    }else{
        dllDir = NULL
    }
		
    list(dllName=dllName, 
         dllDir=dllDir,
         majorVersion=pyMajorVersion,
         pythonHome=pyHome,
         arch=pyArch)
}

