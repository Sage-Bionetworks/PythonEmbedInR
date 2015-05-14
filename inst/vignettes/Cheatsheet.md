# PythonInR Cheat Sheet

| Command          | Short Description                                  | Example Usage                                                        |
| ---------------- | ----------------------------------------------     | -------------------------------------------------------------------- |
| pyCall           | Call a callable Python object                      | `pyCall("pow", list(2,3), namespace="math")`                         |
| pyConnect        | Connect R to Python                                | `pyConnect()`                                                        |
| pyDir            | The Python function dir (similar to ls)            | `pyDir()`                                                            |
| pyExec           | Execute Python code                                | `pyExec('some_python_code = "executed"')`                            |
| pyExecfile       | Execute a file (like source)                       | `pyExecfile("myPythonFile.py")`                                      |
| pyExecg          | Execute Python code and get all assigned variables | `pyExecg('some_python_code = "executed"')`                           |
| pyExecp          | Execute and print Python Code                      | `pyExecp('"Hello" + " " + "R!"')`                                    |
| pyExit           | Close Python                                       | `pyExit()`                                                           |
| pyGet            | Get a Python variable                              | `pyGet('myPythonVariable')`                                          |
| pyHelp           | Python help                                        | `pyHelp("help")`                                                     |
| pyImport         | Import a Python module                             | `pyImport("numpy", "np")`                                            |
| pyIsConnected    | Check if R is connected to Python                  | `pyIsConnected()`                                                    |
| pyPrint          | Print a Python variable from within R              | `pyPrint("somePythonVariable")`                                      |
| pySet            | Set a R variable in Python                         | `pySet("pi", pi)`                                                    |
| pyType           | Get the type of a Python variable                  | `pyType("sys")`                                                      |
| pyVersion        | Returns the version of Python                      | `pyVersion()`                                                        |
