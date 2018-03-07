import inspect
import gateway

def isFunctionOrRoutine(member):
    return inspect.isfunction(member) or inspect.isroutine(member)

def argspecContent(argspec):
    return {'args':argspec.args, 'varargs':argspec.varargs,
        'keywords':argspec.keywords, 'defaults':argspec.defaults}
    
def getCleanedDoc(member):
    doc = inspect.getdoc(member)
    if doc is None:
        return None
    else:
        return inspect.cleandoc(doc)

def methodAttributes(name, method):
    argspec = inspect.getargspec(method)
    args = argspecContent(argspec)
    cleaneddoc = getCleanedDoc(method)
    return({'name':name, 'args':args, 'doc':cleaneddoc, 'module':method.__module__})

def getFunctionInfo(module):
    result = []
    for member in inspect.getmembers(module, isFunctionOrRoutine):
        name = member[0]
        if name.startswith("_"):
            continue
        method = member[1]
        result.append(methodAttributes(name, method))
    return result

def getClassInfo(module):
    result = []
    for member in inspect.getmembers(module, inspect.isclass):
        name = member[0]
        classdefinition = member[1]
        constructorArgs=None
        methods = []
        # let's go through all the functions
        for classmember in inspect.getmembers(classdefinition, inspect.isfunction):
            methodName = classmember[0]
            if methodName=='__init__':
                constructorArgs = argspecContent(inspect.getargspec(classmember[1]))
            elif (not methodName.startswith("_")) and classmember[1].__module__==classdefinition.__module__:
                # this is a non-private, non-inherited function defined in the class
                methodArgs = argspecContent(inspect.getargspec(classmember[1]))
                methodDescription = getCleanedDoc(classmember[1])
                methods.append({'name':methodName, 'doc':methodDescription, 'args':methodArgs})
        if constructorArgs is None:
            continue
        cleaneddoc = getCleanedDoc(classdefinition)
        # insert the constructor itself as the first thing in the list
        methods.insert(0, {'name':name, 'doc':cleaneddoc, 'args':constructorArgs})
        result.append({'name':name, 'constructorArgs':constructorArgs, 'doc':cleaneddoc, 'methods':methods})
    return result

