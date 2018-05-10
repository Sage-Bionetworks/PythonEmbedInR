import sys   
import os
import tempfile

# Note abbreviateStackTrace is no longer used but is kept as a parameter for backwards compatibility
def stdouterrCapture(function, abbreviateStackTrace=False):
    origStdout=sys.stdout
    origStderr=sys.stderr 
    
    stdoutFilepath=tempfile.mkstemp()[1]
    stdoutFilehandle = open(stdoutFilepath, 'w', encoding="utf-8")
    sys.stdout = stdoutFilehandle
    
    stderrFilepath=tempfile.mkstemp()[1]
    stderrFilehandle = open(stderrFilepath, 'w', encoding="utf-8")
    sys.stderr = stderrFilehandle
     
    try:
        return function()
    finally:
        sys.stdout=origStdout
        sys.stderr=origStderr
        try:
            stdoutFilehandle.flush()
            stderrFilehandle.flush()
            stdoutFilehandle.close()
            stderrFilehandle.close()
        except:
            pass # nothing to do
        with open(stdoutFilepath, 'r') as f:
            print(f.read())
        with open(stderrFilepath, 'r') as f:
            print(f.read())

       