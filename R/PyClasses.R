
pyImportPythonInR <- function(){
cmd <-
'
class PythonInR(object):
    def __init__(self):
        self.namespace = dict()

    def addToNamespace(key, value):
        self.namespace[key] = value

    def removeFromNamespace(key):
        try:
            del self.namespace[key]
            return 0
        except:
            return -1

    class PrVector(object): 
        """A pretty rudimentary Vector class!"""
        def __init__(self, vector, names, rClass): 
            if (not (rClass in ("logical", "integer", "numeric", "character"))):
                raise ValueError("rclass is no valid class name in R")
            self.vector = vector
            self.names = names
            self.rClass = rClass

        def __repr__(self):
            s = "prVector"
            s += "\\nnames:  " + str(self.names)
            s += "\\nvalues: " + str(self.vector)
            return s

        __str__ = __repr__

        def toDict(self):
            return {"vector": self.vector, "names": self.names, "rClass": self.rClass}

    class PrMatrix(object): 
        """A pretty rudimentary Matrix class!"""
        def __init__(self, matrix, rownames, colnames, dim): 
            self.matrix = matrix 
            self.rownames = rownames 
            self.colnames = colnames 
            self.dim = tuple(dim)

        def __repr__(self):
             s = "prMatrix:" + "\\n\\t%i columns\\n\\t%i rows\\n" % self.dim
             return s + str(self.matrix)

        __str__ = __repr__

        def toDict(self):
            return {"matrix": self.matrix, "rownames": self.rownames, "colnames": self.colnames, "dim": self.dim}

    class PrDataFrame(object): 
        """A pretty rudimentary DataFrame class!"""
        def __init__(self, dataFrame, rownames, colnames, dim): 
            self.dataFrame = dataFrame
            self.rownames = rownames
            self.colnames = colnames 
            self.dim = tuple(dim)

        def __repr__(self):
             s = "prDataFrame:" + "\\n\\t%i columns\\n\\t%i rows\\n" % self.dim
             return s + str(self.dataFrame)
        
        __str__ = __repr__

        def toDict(self):
            return {"data.frame": self.dataFrame, "rownames": self.rownames, "colnames": self.colnames, "dim": self.dim}
'
pyExec(cmd)
# Define a R object
pyExec("__R__ = PythonInR()")
pyExec("del(PythonInR)")
}
