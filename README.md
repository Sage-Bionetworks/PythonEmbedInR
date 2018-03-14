## PythonEmbedInR - Access a private copy of Python embedded in this R package.

This package is a modification of [PythonInR](https://bitbucket.org/Floooo/pythoninr) which embeds a private copy of Python, isolated from any Python installation that might be on the host system. The documentation of the original package follows. 


## PythonInR - Makes accessing Python from within R as easy as pie.

More documentation can be found at [https://bitbucket.org/Floooo/pythoninr](https://bitbucket.org/Floooo/pythoninr) and [http://pythoninr.bitbucket.org/](http://pythoninr.bitbucket.org/).


## Dependencies

**R** >= 2.15.0

**R-packages:**
- pack
- R6
- rjson
- methods
- stats


## Installation
```r
install.packages("PythonEmbedInR", repos=c("http://cran.fhcrc.org", "https://sage-bionetworks.github.io/ran"))
# (Use your favorite CRAN mirror above.  See https://cran.r-project.org/mirrors.html for a list of available mirrors.)
```


## NOTES
### Python 3
Due to api changes in Python 3 the function `execfile` is no longer available.
The PythonInR package provides a `execfile` function following the typical
[workaround](http://www.diveintopython3.net/porting-code-to-python-3-with-2to3.html#execfile).
```python
def execfile(filename):
    exec(compile(open(filename, 'rb').read(), filename, 'exec'), globals())
```


## Type Casting
### R to Python (pySet)
To allow a nearly one to one conversion from R to Python, PythonInR provides
Python classes for vectors, matrices and data.frames which allow 
an easy conversion from R to Python and back. The names of the classes are PrVector,
PrMatrix and PrDataFrame.


#### Default Conversion
| R                  | length (n) | Python      |
| ------------------ | ---------- | ----------- |
| NULL               |            | None        |
| logical            |          1 | boolean     |
| integer            |          1 | integer     |
| numeric            |          1 | double      |
| character          |          1 | unicode     |
| logical            |      n > 1 | PrVector    |
| integer            |      n > 1 | PrVector    |
| numeric            |      n > 1 | PrVector    |
| character          |      n > 1 | PrVector    |
| list without names |      n > 0 | list        |
| list with names    |      n > 0 | dict        |
| matrix             |      n > 0 | PrMatrix    |
| data.frame         |      n > 0 | PrDataFrame |


#### Change the predefined conversion of pySet
PythonInR is designed in way that the conversion of types can easily be added or changed.
This is done by utilizing polymorphism: if pySet is called, pySet calls pySetPoly
which can be easily modified by the user. The following example shows how pySetPoly 
can be used to modify the behavior of pySet on the example of integer vectors.

The predefined type casting for integer vectors at an R level looks like the following:
```r
setMethod("pySetPoly", signature(key="character", value = "integer"),
          function(key, value){
    success <- pySetSimple(key, list(vector=unname(value), names=names(value), rClass=class(value)))
    cmd <- sprintf("%s = PythonInR.prVector(%s['vector'], %s['names'], %s['rClass'])", 
                   key, key, key, key)
    pyExec(cmd)
})
```

To change the predefined behavior one can simply use setMethod again.
```r
pySetPoly <- PythonInR:::pySetPoly
showMethods("pySetPoly")

pySet("x", 1:3)
pyPrint(x)
pyType("x")

setMethod("pySetPoly",
          signature(key="character", value = "integer"),
          function(key, value){
    PythonInR:::pySetSimple(key, value)
})

pySet("x", 1:3)
pyPrint(x)
pyType("x")
```

**NOTE PythonInR:::pySetSimple**
The functions **pySetSimple** and **pySetPoly** shouldn't be used **outside** the function
**pySet** since they do not check if R is connected to Python. If R is not connected
to Python this can **yield** to **segfault** !


**NOTE (named lists):**
When executing `pySet("x", list(b=3, a=2))` and `pyGet("x")` the order
of the elements in x will change. This is not a special behavior of **PythonInR**
but the default behavior of Python for dictionaries.

**NOTE (matrix):**
Matrices are either transformed to an object of the class PrMatrix or
to an numpy array (if the option useNumpy is set to TRUE).


**NOTE (data.frame):**
Data frames are either transformed to an object of the class PrDataFrame
or to a pandas DataFrame (if the option usePandas is set to TRUE).


### R to Python (pyGet)

| Python      | R                    | simplify     |
| ----------- | -------------------- | ------------ |
| None        | NULL                 | TRUE / FALSE |
| boolean     | logical              | TRUE / FALSE |
| integer     | numeric              | TRUE / FALSE |
| double      | numeric              | TRUE / FALSE |
| string      | character            | TRUE / FALSE |
| unicode     | character            | TRUE / FALSE |
| bytes       | character            | TRUE / FALSE |
| tuple       | list                 | FALSE        |
| tuple       | list or vector       | TRUE         |
| list        | list                 | FALSE        |
| list        | list or vector       | TRUE         |
| dict        | named list           | FALSE        |
| dict        | named list or vector | TRUE         |
| PrVetor     | vector               | TRUE / FALSE |
| PrMatrix    | matrix               | TRUE         |
| PrDataFrame | data.frame           | TRUE         |


#### Change the predefined conversion of pyGet
Similar to pySet the behavior of pyGet can be changed by utilizing pyGetPoly.
The predefined version of pyGetPoly for an object of class PrMatrix looks like the following:
```r
setMethod("pyGetPoly", signature(key="character", autoTypecast = "logical", simplify = "logical", pyClass = "PrMatrix"),
          function(key, autoTypecast, simplify, pyClass){
    x <- pyExecg(sprintf("x = %s.toDict()", key), autoTypecast = autoTypecast, simplify = simplify)[['x']]
    M <- do.call(rbind, x[['matrix']])
    rownames(M) <- x[['rownames']]
    colnames(M) <- x[['colnames']]
    return(M)
})
```

For objects of type "type" no conversion is defined. Therefore, PythonInR doesn't know how
to transform it into an R object so it will return a PythonInR_Object. This is kind of a
nice example since the return value of type(x) is a function therefore PythonInR will
return an object of type pyFunction.
```r
pyGet("type(list())")
```

One can define a new function to get elements of type "type" as follows.
```r
pyGetPoly <- PythonInR:::pyGetPoly
setClass("type")
setMethod("pyGetPoly", signature(key="character", autoTypecast = "logical", simplify = "logical", pyClass = "type"),
          function(key, autoTypecast, simplify, pyClass){
    pyExecg(sprintf("x = %s.__name__", key))[['x']]
})
pyGet("type(list())")
```

**NOTE pyGetPoly**
The functions **pyGetPoly** should not be used **outside** the function
**pyGet** since it does not check if R is connected to Python. If R is not connected
to Python this will **yield** to **segfault** !


**NOTE (bytes):**
In short, in Python 3 the data type string was replaced by the data type bytes.
More information can be found [here](http://www.diveintopython3.net/strings.html).


## Cheat Sheet

| Command          | Short Description                                  | Example Usage                                                        |
| ---------------- | -------------------------------------------------- | -------------------------------------------------------------------- |
| BEGIN.Python     | Start a Python read\-eval\-print loop              | `BEGIN.Python() print("Hello" + " " + "R!") END.Python`              |
| pyAttach         | Attach a Python object to an R environment         | `pyAttach("os.getcwd", .GlobalEnv)`                                  |
| pyCall           | Call a callable Python object                      | `pyCall("pow", list(2,3), namespace="math")`                         |
| pyConnect        | Connect R to Python                                | `pyConnect()`                                                        |
| pyDict           | Create a representation of a Python dict in R      | `myNewDict = pyDict('myNewDict', list(p=2, y=9, r=1))`               |
| pyDir            | The Python function dir (similar to ls)            | `pyDir()`                                                            |
| pyExec           | Execute Python code                                | `pyExec('some_python_code = "executed"')`                            |
| pyExecfile       | Execute a file (like source)                       | `pyExecfile("myPythonFile.py")`                                      |
| pyExecg          | Execute Python code and get all assigned variables | `pyExecg('some_python_code = "executed"')`                           |
| pyExecp          | Execute and print Python Code                      | `pyExecp('"Hello" + " " + "R!"')`                                    |
| pyExit           | Close Python                                       | `pyExit()`                                                           |
| pyFunction       | Create a representation of a Python function in R  | `pyFunction(key)`                                                    |
| pyGet            | Get a Python variable                              | `pyGet('myPythonVariable')`                                          |
| pyGet0           | Get a Python variable                              | `pyGet0('myPythonVariable')`                                         |
| pyHelp           | Python help                                        | `pyHelp("help")`                                                     |
| pyImport         | Import a Python module                             | `pyImport("numpy", "np")`                                            |
| pyIsConnected    | Check if R is connected to Python                  | `pyIsConnected()`                                                    |
| pyList           | Create a representation of a Python list in R      | `pyList(key)`                                                        |
| pyObject         | Create a representation of a Python object in R    | `pyObject(key)`                                                      |
| pyOptions        | A function to get and set some package options     | `pyOptions("numpyAlias", "np")`                                      |
| pyPrint          | Print a Python variable from within R              | `pyPrint("somePythonVariable")`                                      |
| pySet            | Set a R variable in Python                         | `pySet("pi", pi)`                                                    |
| pySource         | A modified BEGIN.Python aware version of source    | `pySource("myFile.R")`                                               |
| pyTuple          | Create a representation of a Python tuple in R     | `pyTuple(key)`                                                       |
| pyType           | Get the type of a Python variable                  | `pyType("sys")`                                                      |
| pyVersion        | Returns the version of Python                      | `pyVersion()`                                                        |


# Wrapping python packages

The following tools help generate R functions wrapping Python functions along with reference documentation (.Rd files) for the wrapper functions, the documentation being generated from the Sphinx-based Python doc-strings.

Preconditions:
* The Python package is downloaded and installed on the machine
* The Python package is available on python search path

A Python package may have multiple modules, each with its namespace. Each module has its own functions, classes, and variables. Each function or class has its own local namespace. In R, all functions and classes within the same package share a package namespace. To avoid the namespace collisions and allow customization to the wrapping package, we provide the following functions to help you pick which modules, functions, and classes to expose in R:

* `generateRWrappers`
* `generateRdFiles`

The .Rd file generation must happen at the time the package is built, not at the time the package is loaded. The R function and contructor wrappers must happen at the time the package is loaded. These functions should be called with the similar params to ensure that all R wrapped functions have corresponding reference documentation.

## Examples:

In this example, I will demonstrate how we generate `synapser` and `synapserutils` packages by wrapping Python package `synapsePythonClient`.

`synapsePythonClient` has the following structure:
```
synapsePythonClient package
    module: synapseclient
        module: client
            class: Synapse
                function: get
                function: login
        module: entity
            class: Entity
                function: get
                function: privateGet
            class: File
                function: get
                function: privateGet
            class: Folder
                function: get
                function: privateGet
        module: table
            function: Table
            function: column_ids
            class: Column
            class: CsvFileTable
        module: cache
            function: set
    module: synapseutils
        module: copy
            function: copy
            function: copyWiki
            function: copyFileHandles
        module: sync
            function: syncToSynapse
            function: syncFromSynapse
        module: monitor
            function: notifyMe
```

### Expose all functions and classes within a Python module

For the R package `synapserutils`, our first attempt is to exposing all functions under `synapseutils` Python module. In `.configure` file, we execute an R script that calls `generateRdFiles` as following:
```r
generateRdFiles(srcRootDir,
                pyPkg = "synapseutils",
                module = "synapseutils")
```
Where `srcRootDir` is the path to `synapserutils` directory, `pyPkg` is the name of the Python package, and `module` is the name of the Python module. In this case, `pyPkg` and `module` has the same name. In later examples, we will use different names for `pyPkg` and `module`.

Then in `.onLoad` under `synapserutils/R/zzz.R`, we add the following:
```r
callback <- function(name, def) {
  setGeneric(name, def)
}
generateRWrappers(pyPkg = "synapseutils",
                  module = "synapseutils",
                  setGenericCallback = callback)
```
For the R wrappers to be available in `synapserutils` package namespace, `setGeneric` must be defined in the `synapserutils` package. Therefore, we need to define it in `synapserutils` and pass it through `generateRWrappers`.

For more information about how to use `setGeneric`, please view its reference documentation by:
```r
?setGeneric
```

### Expose a subset of functions within a Python module

For many reasons, some Python functions are only meaningful to Python users. We would not want to expose those functions in our R package.

Let's omit the following functions from `synapseutils` module:
* `copyFileHandles`
* `notifyMe`

You would need to specify a function like `selectFunctions` below in a shared .R file:
```r
toOmit <- c("copyFileHandles", "notifyMe")
selectFunctions <- function(x) {
    if (any(x$name == toOmit)) {
        return(NULL)
    }
    x
}
```

Then from the R script that generates .Rd files, update `generateRdFiles` as following:
```r
generateRdFiles(srcRootDir,
                pyPkg = "synapseutils",
                module = "synapseutils",
                modifyFunctions = selectFunctions)
```

And in your `.onLoad`, update `generateRWrappers` as following:
```r
generateRWrappers(pyPkg = "synapseutils",
                  module = "synapseutils",
                  setGenericCallback = callback,
                  modifyFunctions = selectFunctions)
```

### Expose a subset of classes within a Python module

Now let's try a more complicated example where we want to expose the following functions and classes from `synapseclient.entity` module:
```
  class: File
      function: get
  class: Folder
      function: get
```

Note that we do not want the following from the `synapseclient.entity` module:
* `function: privateGet` from any of the class
* `class: Entity`

First, define your `selectClasses` in the shared .R file:
```r
methodsToOmit <- "privateGet"
classToSkip <- "Entity"
selectClasses <- function(class) {
    if (any(class$name == classToSkip)) {
        return(NULL)
    }
    if (!is.null(class$methods)) {
        culledMethods <- lapply(X = class$methods, function(x) {
            if (any(x$name == methodsToOmit)) NULL else x;
        })
        # Now remove the nulls
        nullIndices <- sapply(culledMethods, is.null)
        if (any(nullIndices)) {
            class$methods <- culledMethods[-which(nullIndices)]
        }
    }
    class
}
```

Then call `generateRdFiles` and `generateRWrappers` as following:
```r
generateRdFiles(srcRootDir,
                pyPkg = "synapseclient",
                module = "synapseclient.entity",
                modifyClasses = selectClasses)
```
```r
generateRWrappers(pyPkg = "synapseclient",
                  module = "synapseclient.entity",
                  setGenericCallback = callback,
                  modifyClasses = selectClasses)
```

### Expose functions within a singleton object

In rare cases, we want to expose Python functions under `synapseclient.client.Synapse` without exposing the `Synapse` object itself.

In a Python session, we would do the following:
```
  syn = synapseclient.Synapse()
  syn.login()
  syn.get()
```

And in R, users would not need to know about the `Synapse` object:
```
  synLogin()
  synGet()
```

Note that:
* all function calls in R access the same underlying Python object `Synapse`
* the functions name in R has a `syn` prefix

To do this, one would specifying `pyObjectName` and `functionPrefix` params as following:

```r
generateRdFiles(srcRootDir,
                pyPkg = "synapseclient",
                module = "synapseclient.client.Synapse",
                pyObjectName = "syn",
                functionPrefix = "syn")
```
```r
generateRWrappers(pyPkg = "synapseclient",
                  module = "synapseclient.client.Synapse",
                  setGenericCallback = callback,
                  pyObjectName = "syn",
                  functionPrefix = "syn")
```

Then in the same `.onLoad`, create the Python object:
```r
pyImport("synapseclient")
pyExec("syn = synapseclient.Synapse()")
```

### Overwrite the returned object in R

For many reasons, a returned object from an R wrapper function does not have the R-friendly bahaviors. As an author of an R package, one may want to modify the returned object. Here is a simple example using `transformReturnObject` param:
```r
objectDefinitionHelper <- function(object) {
  if (grepl("^GeneratorWrapper", class(object)[1])) {
    class(object)[1] <- "GeneratorWrapper"
  }
  object
}

generateRWrappers(pyPkg = "synapseclient",
                  module = "synapseclient.client.Synapse",
                  setGenericCallback = callback,
                  functionPrefix = "syn",
                  pyObjectName = "syn",
                  transformReturnObject = objectDefinitionHelper)
```

### Notes on `generateRdFiles`

This helper function can be used to convert Python [Sphinx](http://www.sphinx-doc.org/en/master/) docs into Rd files. It only supports a subset of Sphinx tags, including:
- title
- description
- usage
- arguments
- value
- examples


# Usage Examples
## Dynamic Documents
  + **PythonInR and KnitR** [Example](https://gist.github.com/kohske/3e438a7962cacfef9d32)

## Data and Text Mining   
  + **PythonInR and word2vec** [Example](https://speakerdeck.com/yamano357/tokyor51-lt)
    The word2vec tool takes a text corpus as input and produces the word vectors as output. More information can be found [here](https://code.google.com/p/word2vec/).  
    [T Mikolov, K Chen, G Corrado, J Dean . "Efficient estimation of word representations in vector space." arXiv preprint arXiv:1301.3781 (2013).](http://arxiv.org/pdf/1301.3781.pdf)  
    For word2vec also R-packages are available [tmcn (A Text mining toolkit especially for Chinese)](https://r-forge.r-project.org/R/?group_id=1571) and [wordVectors](https://github.com/bmschmidt/wordVectors). An example application of *wordVectors* can be found [here](http://yamano357.hatenadiary.com/entry/2015/11/04/000332).
    Furthermore it seems to be soon available in [h2o-3](https://github.com/h2oai/h2o-3/blob/master/h2o-r/h2o-package/R/word2vec.R).


  + **PythonInR and Glove** [Example](https://gist.github.com/yamano357/8a31b2dc0c7a20a30d36)  
    GloVe is an unsupervised learning algorithm for obtaining vector representations for words. More information can be found [here](http://nlp.stanford.edu/projects/glove/).   
    [Jeffrey Pennington, Richard Socher, and Christopher D. Manning. "Glove: Global vectors for word representation." Proceedings of the Empiricial Methods in Natural Language Processing (EMNLP 2014) 12 (2014): 1532-1543.](http://nlp.stanford.edu/pubs/glove.pdf)


  + **PythonInR and TensorFlow** [Example](http://qiita.com/yamano357/items/66272759fc29a5a2dd01)  
    TensorFlow is an open source software library for numerical computation using data flow graphs. More information can be found [here](http://www.tensorflow.org/).  
    [Martín Abadi, Ashish Agarwal, Paul Barham, Eugene Brevdo, Zhifeng Chen, Craig Citro, Greg S. Corrado, Andy Davis, Jeffrey Dean, Matthieu Devin, Sanjay Ghemawat, Ian Goodfellow, Andrew Harp, Geoffrey Irving, Michael Isard, Rafal Jozefowicz, Yangqing Jia, Lukasz Kaiser, Manjunath Kudlur, Josh Levenberg, Dan Mané, Mike Schuster, Rajat Monga, Sherry Moore, Derek Murray, Chris Olah, Jonathon Shlens, Benoit Steiner, Ilya Sutskever, Kunal Talwar, Paul Tucker, Vincent Vanhoucke, Vijay Vasudevan, Fernanda Viégas, Oriol Vinyals, Pete Warden, Martin Wattenberg, Martin Wicke, Yuan Yu, and Xiaoqiang Zheng. "TensorFlow: Large-scale machine learning on heterogeneous systems." (2015).](http://download.tensorflow.org/paper/whitepaper2015.pdf)
