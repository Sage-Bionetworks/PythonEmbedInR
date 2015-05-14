#' # Memory Profiling
#' To detect leaks.
q("no")
require(PythonInR)
invisible(capture.output(pyConnect()))

pyCodeJunks <- c(
    "x=range(1,1000)",
    "dir()")

pyImport("os")

pyExec("
def memory_usage_ps():
    import subprocess
    out = subprocess.Popen(['ps', 'v', '-p', str(os.getpid())], stdout=subprocess.PIPE).communicate()[0].split('\\n')
    vsz_index = out[0].split().index('RSS')
    mem = float(out[1].split()[vsz_index]) / 1024
    return mem")



mem.profile <- function(){
    pyExecp("memory_usage_ps()")
}

mem.profile()

for (i in 1:10000){
    x <- pyExecg(pyCodeJunks[1])
    mem.profile()
}



