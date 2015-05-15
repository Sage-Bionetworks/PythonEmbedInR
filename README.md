# PythonInR - Makes accessing Python from within R as easy as pie.

The main page of the documentation is located at [http://pythoninr.bitbucket.org/](http://pythoninr.bitbucket.org/).

## Dependencies

**Python** >= 2.7.0
**R** >= 2.15.0
 
**R-packages:**   
- pack


### Linux
**Python headers** 

On **Debian** and Debian-based Linux distributions (including **Ubuntu**
and other derivatives) the *"Python Development Headers"* can be installed
by typing the following into the terminal.

```bash
    apt-get install python-dev
```    

For **Red Hat Enterprise Linux** , **Fedora**, and other **Red Hat
Linux-based** distributions, use the following for installation.

```bash
    yum install python-devel
```

### Windows
There are no additional dependencies on Windows.

## Installation
```r
    install.packages("PythonInR")
#   or
    install_bitbucket("Floooo/PythonInR")
```

## NOTES
### Python 3
Through api changes in Python 3 the function `execfile` is no longer available,
the PythonInR package provides a `execfile` function following the typical
[workaround](http://www.diveintopython3.net/porting-code-to-python-3-with-2to3.html#execfile).
```python
def execfile(filename):
    exec(compile(open(filename, 'rb').read(), filename, 'exec'), globals())
```

## Type Casting
### R to Python (pySet)

| R                  | length (n) | Python  |
| ------------------ | ---------- | ------- |
| NULL               |            |    None |
| any type           |          0 |    None |
| logical            |          1 | boolean |
| integer            |          1 | integer |
| numeric            |          1 | double  |
| character          |          1 | unicode |
| logical            |      n > 1 |    list |
| integer            |      n > 1 |    list |
| numeric            |      n > 1 |    list |
| character          |      n > 1 |    list |
| list without names |      n > 0 |    list |
| list with names    |      n > 0 |    dict |
| matrix             |      n > 0 |    dict |
| data.frame         |      n > 0 |    dict |

**NOTE (named lists):**   
When executing `pySet("x", list(b=3, a=2))` and `pyGet("x")` the order 
of the elements in x will change. This is not a special behavior of **PythonInR**
but the default behavior of Python.

**NOTE (matrix):**   
Matrices are either transformed to an dictionary with the keys    
- *matrix* the matrix stored as list of lists   
- *rownames* the row names of the matrix   
- *colnames* the column names of the matrix   
- *dim* the dimension of the matrix   
or to an numpy array (if the option useNumpy is set to TRUE).


**NOTE (data.frame):**   
Data frames are either transformed to an dictionary with the keys    
- *data.frame* the data.frame stored as a dictionary    
- *rownames* the rownames of the data.frame    
- *dim* the dimension of the data.frame     
of to an pandas data.frame (if the option usePandas is set to TRUE).


### R to Python (pyGet)
| Python  | R                    | simplify     |
| ------- | -------------------- | ------------ |
| None    | NULL                 | TRUE / FALSE |
| boolean | logical              | TRUE / FALSE |
| integer | integer              | TRUE / FALSE |
| double  | numeric              | TRUE / FALSE |
| string  | character            | TRUE / FALSE |
| unicode | character            | TRUE / FALSE |
| bytes   | character            | TRUE / FALSE |
| tuple   | list                 | FALSE        |
| tuple   | list or vector       | TRUE         |
| list    | list                 | FALSE        |
| list    | list or vector       | TRUE         |
| dict    | named list           | FALSE        |
| dict    | named list or vector | TRUE         |


**NOTE (bytes):**   
In short, in Python 3 the data type string was replaced by the data type bytes.
More information can be found [here](http://www.diveintopython3.net/strings.html).


## Cheat Sheet

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
