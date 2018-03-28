# ------------------------------------------------------------------------------
#
#   Helpers for wrapping python packages
#
# ------------------------------------------------------------------------------

# Define an R wrapper for a object constructor in Python
#
# @param module the python module
# @param setGenericCallback the callback to setGeneric defined in the target R package
# @param name the class name
defineConstructor <- function(module, setGenericCallback, name) {
  force(name)
  assign(sprintf(".%s", name), function(...) {
    pyModule <- pyGet(module)
    argsAndKwArgs <- determineArgsAndKwArgs(...)
    functionAndArgs <- append(list(pyModule, name), argsAndKwArgs$args)
    cleanUpStackTrace(
      pyCall,
      list("gateway.invoke",
        args = functionAndArgs,
        kwargs = argsAndKwArgs$kwargs,
        simplify = F
      )
    )
  })
  setGenericCallback(
    name,
    function(...) {
      do.call(sprintf(".%s", name), args = list(...))
    }
  )
}

# Helper function to generate R wrappers for classes in a python module
#
# @param module the python module
# @param setGenericCallback the callback to setGeneric defined in the target R package
# @param classInfo the classes to generate R wrappers for
autoGenerateClasses <- function(module, setGenericCallback, classInfo) {
  for (c in classInfo) {
    defineConstructor(module, setGenericCallback, c$name)
  }
}

# Define an R wrappers for a function in a python module
#
# @param rName the R function name
# @param pyName the Python function name
# @param functionContainerName the function container name in Python
# @param setGenericCallback the callback to setGeneric defined in the target R package
# @param transformReturnObject optional function to change returned values in R
defineFunction <- function(rName,
                           pyName,
                           functionContainerName,
                           setGenericCallback,
                           transformReturnObject = NULL) {
  pyImport("gateway")
  force(rName)
  force(pyName)
  force(functionContainerName)
  rWrapperName <- sprintf(".%s", rName)

  assign(rWrapperName, function(...) {
    functionContainer <- pyGet(functionContainerName, simplify = FALSE)
    argsAndKwArgs <- determineArgsAndKwArgs(...)
    functionAndArgs <- append(
      list(functionContainer, pyName),
      argsAndKwArgs$args
    )
    returnedObject <- cleanUpStackTrace(
      pyCall,
      list("gateway.invoke",
        args = functionAndArgs,
        kwargs = argsAndKwArgs$kwargs,
        simplify = F
      )
    )
    if (!is.null(transformReturnObject)) {
      transformReturnObject(returnedObject)
    } else {
      returnedObject
    }
  })
  setGenericCallback(rName, function(...) {
    do.call(rWrapperName, args = list(...))
  })
}

# Helper function to generate R wrappers for functions in a python module
#
# @param setGenericCallback the callback to setGeneric defined in the target R package
# @param functionInfo the functions to generate R wrappers for
# @param transformReturnObject optional function to change returned values in R
autoGenerateFunctions <- function(setGenericCallback,
                                  functionInfo,
                                  transformReturnObject = NULL) {
  for (f in functionInfo) {
    defineFunction(
      f$rName,
      f$pyName,
      f$functionContainerName,
      setGenericCallback,
      transformReturnObject
    )
  }
}

# Helper function to add prefix to a name
#
# @param name the name to add prefix to
# @param prefix the prefix to add
addPrefix <- function(name, prefix) {
  paste(prefix,
    toupper(substring(name, 1, 1)),
    substring(name, 2, nchar(name)),
    sep = ""
  )
}

# Helper function to remove NULL in a list
#
# @param x the list to remove NULL
removeNulls <- function(x) {
  nullIndices <- sapply(x, is.null)
  if (any(nullIndices)) {
    x <- x[-which(nullIndices)]
  }
  x
}

# Helper function to get a list of Python functions in a given module
#
# @param pyPkg the Python package name
# @param module the Python module
# @param modifyFunctions optional function to modify the returned functions
# @param functionPrefix optional text to add to the name of the functions
# @param pySingletonName optional singleton object in python
getFunctionInfo <- function(pyPkg,
                            module,
                            modifyFunctions = NULL,
                            functionPrefix = NULL,
                            pySingletonName = NULL) {
  pyImport("pyPkgInfo")
  pyImport(pyPkg)
  pyExec(sprintf("functionInfo = pyPkgInfo.getFunctionInfo(%s)", module))
  functionInfo <- pyGet("functionInfo", simplify = F)

  if (!is.null(modifyFunctions)) {
    functionInfo <- lapply(X = functionInfo, modifyFunctions)
  }
  # scrub the nulls
  functionInfo <- removeNulls(functionInfo)

  functionContainerName <- module
  if (!is.null(pySingletonName)) {
    functionContainerName <- pySingletonName
  }

  functionInfo <- lapply(X = functionInfo, function(x) {
    if (!is.null(functionPrefix)) {
      rName <- addPrefix(x$name, functionPrefix)
    } else {
      rName <- x$name
    }
    list(
      pyName = x$name,
      rName = rName,
      functionContainerName = functionContainerName,
      args = x$args,
      doc = x$doc,
      title = rName
    )
  })
  functionInfo
}

# Helper function to get a list of Python classes in a given module
#
# @param pyPkg the Python package name
# @param module the Python module
# @param modifyClasses optional function to modify the returned classes
getClassInfo <- function(pyPkg, module, modifyClasses = NULL) {
  pyImport("pyPkgInfo")
  pyImport(pyPkg)
  pyExec(sprintf("classInfo = pyPkgInfo.getClassInfo(%s)", module))
  classInfo <- pyGet("classInfo", simplify = F)
  if (!is.null(modifyClasses)) {
    classInfo <- lapply(X = classInfo, modifyClasses)
  }
  # scrub the nulls
  removeNulls(classInfo)
}

# Determines args and kwargs
#
# This function takes the list of arguments passed to an R function and groups them
#  into the (1) unnamed / positional arguments and the (2) the named / keyword arguments
#  to pass to the corresponding Python function.
#
# @param ... the list of arguments passed to an R function
# @return The grouping of arguments into 'args' (the unnamed or positional arguments) and
#  'kwargs' (the named or keyword arguments) to be passed to the corresponding Python function.
determineArgsAndKwArgs <- function(...) {
  values <- list(...)
  valuenames <- names(values)
  n <- length(values)
  args <- list()
  kwargs <- list()
  if (n > 0) {
    positionalArgument <- TRUE
    for (i in 1:n) {
      if (is.null(valuenames) ||
        length(valuenames[[i]]) == 0 ||
        nchar(valuenames[[i]]) == 0) {
        # it's a positional argument
        if (!positionalArgument) {
          stop("positional argument follows keyword argument")
        }
        if (is.null(values[[i]])) {
          # inserting a value into a list at best is a no-op, at worst removes an existing value
          # to get the desired insertion we must wrap it in a list
          args[length(args) + 1] <- list(NULL)
        } else {
          args[[length(args) + 1]] <- values[[i]]
        }
      } else {
        # It's a keyword argument.  All subsequent arguments must also be keyword arg's
        positionalArgument <- FALSE
        # a repeated value will overwite an earlier one
        if (is.null(values[[i]])) {
          # inserting a value into a list at best is a no-op, at worst removes an existing value
          # to get the desired insertion we must wrap it in a list
          kwargs[valuenames[[i]]] <- list(NULL)
        } else {
          kwargs[[valuenames[[i]]]] <- values[[i]]
        }
      }
    }
  }
  list(args = args, kwargs = kwargs)
}

# The purpose of this function is to remove the Python stack trace from an error message
#  generated when calling Python from R. This makes the command line response more readable
#  when an error occurs. To support debugging the stack trace truncation can be overridden
#  by setting the global option 'verbose' to TRUE.
#
# @param callable the function to be called
# @param args the arguments to be passed to the function 'callable'
# @return the result of calling the given function with the given arguments
cleanUpStackTrace <- function(callable, args) {
  conn <- textConnection("outputCapture", open = "w", local = TRUE)
  sink(conn)
  tryCatch({
    result <- do.call(callable, args)
    sink()
    close(conn)
    cat(paste(outputCapture, collapse = ""))
    result
  },
  error = function(e) {
    sink()
    close(conn)
    errorToReport <- paste(c(outputCapture, e$message), collapse = "\n")
    if (!getOption("verbose")) {
      # extract the error message
      splitArray <- strsplit(errorToReport,
        "exception-message-boundary",
        fixed = TRUE
      )[[1]]
      if (length(splitArray) >= 2) errorToReport <- splitArray[2]
    }
    stop(errorToReport)
  }
  )
}

#' @title Generate R wrappers for Python classes and functions
#' @description This function generate R wrappers for Python classes and functions
#'   in the given Python module
#'
#' @param pyPkg The Python package name
#' @param module The name of the Python module to be wrapped.
#' @param setGenericCallback The callback to setGeneric defined in the target R package
#' @param modifyFunctions Optional function to modify the returned functions
#' @param modifyClasses Optional function to modify the returned classes
#' @param functionPrefix Optional text to add to the name of the functions
#' @param pySingletonName Optional singleton object in python
#' @param transformReturnObject Optional function to change returned values in R
#' @details
#' * `generateRdFiles` and `generateRWrappers` should be called with similar
#'   params to ensure all R wrappers has sufficient documentation.
#'   
#' * `module` can have the same value as `pyPkg` or a module within the Python package.
#'   The value that is passed to `module` parameter must be a fully qualified name.
#'   
#' * `setGeneric` function must be defined in the same environment that `generateRWrappers`
#'   is called. See example 1.
#'   
#' * `modifyFunctions` and `modifyClasses` are optional function defined by the caller.
#' 
#' * `modifyFunctions` takes an object with the schema: ('name', 'args', 'doc', 'module')
#'   and modifies the list of functions found under `module`. See example 2.
#'   
#' * `modifyClasses` takes an object with the schema: ('name', 'constructorArgs', 'doc', 'methods')
#'   and modifies the list of classes found under `module`. See example 3.
#'   
#' * `pySingletonName` is used to expose a set Python functions which are an object's methods,
#'   but without exposing the object itself. See example 4.
#'   
#' * `transformReturnObject` is used to intercept and modify the values
#'   returned by the auto-generated R functions. It takes an R6 object,
#'   and returned the modified R6 object. See example 5.
#' 
#' @note generateRWrappers should be called in .onLoad()
#' @seealso [generateRdFiles()]
#' @examples
#' 1.
#' ```
#' callback <- function(name, def) {
#'   setGeneric(name, def)
#' }
#' PythonEmbedInR::generateRWrappers(
#'   pyPkg = "pyPackageName",
#'   module = "aModuleInPyPackageName",
#'   setGenericCallback = callback)
#' ```
#' 2.
#' ```
#' myModifyFunctions <- function(x) {
#'   if (any(x$name == "myFun")) NULL else x
#' }
#' PythonEmbedInR::generateRWrappers(
#'   pyPkg = "pyPackageName",
#'   module = "aModuleInPyPackageName",
#'   setGenericCallback = callback,
#'   modifyFunctions = myModifyFunctions)
#' ```
#' 3.
#' ```
#' myModifyClasses <- function(x) {
#'   if (any(x$name == "myFun")) NULL else x
#' }
#' PythonEmbedInR::generateRWrappers(
#'   pyPkg = "pyPackageName",
#'   module = "aModuleInPyPackageName",
#'   setGenericCallback = callback,
#'   modifyClasses = myModifyClasses)
#' ```
#' 4.
#' ```
#' .onLoad <- function(libname, pkgname) {
#'   pyImport("synapseclient")
#'   pyExec("syn = synapseclient.Synapse()")
#'   # `pySingletonName` must be the name of the object defined in Python.
#'   generateRWrappers(pyPkg = "synapseclient",
#'                     module = "synapseclient.client.Synapse",
#'                     setGenericCallback = callback,
#'                     pySingletonName = "syn")
#' }
#' ```
#' 5.
#' ```
#' myTranform <- function(x) {
#'   # replace the object name
#'   class(x) <- "newName"
#' }
#' PythonEmbedInR::generateRWrappers(
#'   pyPkg = "pyPackageName",
#'   module = "aModuleInPyPackageName",
#'   setGenericCallback = callback,
#'   transformReturnObject = myTranform)
#' ```
generateRWrappers <- function(pyPkg,
                              module,
                              setGenericCallback,
                              modifyFunctions = NULL,
                              modifyClasses = NULL,
                              functionPrefix = NULL,
                              pySingletonName = NULL,
                              transformReturnObject = NULL) {
  functionInfo <- getFunctionInfo(
    pyPkg,
    module,
    modifyFunctions,
    functionPrefix,
    pySingletonName
  )
  classInfo <- getClassInfo(
    pyPkg,
    module,
    modifyClasses
  )

  autoGenerateFunctions(
    setGenericCallback,
    functionInfo,
    transformReturnObject
  )
  autoGenerateClasses(
    module,
    setGenericCallback,
    classInfo
  )
}

# ------------------------------------------------------------------------------
#
#   Helpers for generating R docs from python docs
#
# ------------------------------------------------------------------------------

# This is factored out of autoGenerateRdFiles so it can be called during testing
initAutoGenerateRdFiles <- function(templateDir) {
  dictDocString <<- getDictDocString(templateDir)
}

# This function generates R documentation (.Rd) files
#  (https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Rd-format) from
#  Python doc-strings using Sphinx tags (http://www.sphinx-doc.org). The files are
#  written to the directory /auto-man, allowing manual touch up prior to copying to
#  man/ (the standard location for R documentation).
#
# @param srcRootDir is the root directory for the code base (i.e., prior to installation)
# @param functionInfo list of functions for which to generate doc's
# @param classInfo list of classes for which to generate doc's
# @param templateDir (optional) custom templates for the docs
autoGenerateRdFiles <- function(srcRootDir,
                                functionInfo,
                                classInfo,
                                keepContent,
                                templateDir = NULL) {
  if (!file.exists(srcRootDir)) {
    stop(sprintf("%s does not exist.", srcRootDir))
  }
  if (is.null(templateDir)) {
    # use default templates
    templateDir <- system.file("templates", package = "PythonEmbedInR")
  }
  initAutoGenerateRdFiles(templateDir)

  targetFolder <- file.path(srcRootDir, "auto-man")
  if ((!keepContent) || (!file.exists(targetFolder))) {
    # start from a clean slate
    unlink(targetFolder, recursive = T, force = T)
    dir.create(targetFolder)
  }

  # create a list for the constructors that's structured the same as the info for the functions
  constructorInfo <- lapply(X = classInfo, function(x) {
    list(
      rName = x$name,
      args = x$constructorArgs,
      doc = x$doc,
      title = sprintf("Constructor for objects of type %s", x$name),
      returned = sprintf("An object of type %s", x$name)
    )
  })
  # create doc's for all functions and constructors
  for (f in c(functionInfo, constructorInfo)) {
    name <- f$rName
    args <- f$args
    doc <- f$doc
    title <- f$title
    if (is.null(f$returned)) {
      returned <- getReturned(doc)
    } else {
      returned <- f$returned
    }
    tryCatch({
      argDescriptionsFromDoc <- parseArgDescriptionsFromDetails(doc)
      argNames <- args$args
      formatArgsResult <- formatArgsForArgumentSection(
        argNames,
        argDescriptionsFromDoc
      )
      content <- createFunctionRdContent(
        templateDir = templateDir,
        alias = name,
        title = title,
        description = doc,
        usage = usage(
          name,
          args,
          argDescriptionsFromDoc
        ),
        argument = formatArgsResult,
        returned = returned
      )
      # make sure all place holders were replaced
      p <- regexpr("##(title|description|usage|arguments|value|examples)##", content)[1]
      if (p > 0) stop(sprintf("Failed to replace all placeholders in %s.Rd", name))
      writeContent(content, name, targetFolder)
    },
    error = function(e) {
      stop(sprintf("Error generating doc for %s: %s\n", name, e[[1]]))
    }
    )
  }

  for (c in classInfo) {
    tryCatch({
      content <- createClassRdContent(
        templateDir = templateDir,
        alias = paste0(c$name, "-class"),
        title = c$name,
        description = c$doc,
        methods = lapply(
          X = c$methods,
          function(x) {
            argDescriptionsFromDoc <- parseArgDescriptionsFromDetails(x$doc)
            list(
              name = x$name,
              description = x$doc,
              args = x$args,
              argDescriptionsFromDoc = argDescriptionsFromDoc
            )
          }
        )
      )
      p <- regexpr("##(alias|title|description|methods)##", content)[1]
      if (p > 0) stop(sprintf("Failed to replace all placeholders in %s.Rd", name))
      writeContent(content, paste0(c$name, "-class"), targetFolder)
    },
    error = function(e) {
      stop(sprintf("Error generating doc for %s: %s\n", name, e[[1]]))
    }
    )
  }
}

# create the 'usage' section of the doc
# this is also used to document the 'methods' of a class
usage <- function(name, args, argDescriptionsFromDoc) {
  result <- NULL
  argNames <- args$args
  defaults <- args$defaults
  result <- NULL
  if (length(argNames) > 0) {
    # self can be the first arg of a method or function, typ can be the first arg of a constructor
    if (argNames[1] != "self" && argNames[1] != "typ") argStart <- 1 else argStart <- 2
    if (argStart <= length(argNames)) {
      for (i in argStart:length(argNames)) {
        argName <- argNames[[i]]
        defaultIndex <- i + length(defaults) - length(argNames)
        if (defaultIndex > 0) {
          result <- append(result, sprintf("%s=%s", argName, defaults[defaultIndex]))
        } else {
          result <- append(result, argName)
        }
        # remove it from the list of arguments mentioned in the docstring
        argDescriptionsFromDoc[[argName]] <- NULL
      }
    }
  }
  # are there any remaining arguments, not included in the argument list?
  # if so, they are kwargs / named parameters
  if (length(names(argDescriptionsFromDoc)) > 0) {
    result <- append(result, lapply(
      names(argDescriptionsFromDoc),
      function(x) {
        sprintf("%s=NULL", x)
      }
    ))
  }
  sprintf("%s(%s)", name, paste(result, collapse = ", "))
}

# create a named list of arguments and their descriptions
# suitable for use in the arguments section
# argNames is the list of explicit arguments from inspecting the function
# argDescriptionsFromDoc is the result of parsing the docstring, looking for parameters
formatArgsForArgumentSection <- function(argNames, argDescriptionsFromDoc) {
  result <- NULL
  if (length(argNames) > 0) {
    if (argNames[1] != "self" && argNames[1] != "typ") argStart <- 1 else argStart <- 2
    if (argStart <= length(argNames)) {
      for (i in argStart:length(argNames)) {
        argName <- argNames[[i]]
        argDescription <- argDescriptionsFromDoc[[argName]]
        # remove it from the list of arguments mentioned in the docstring
        argDescriptionsFromDoc[[argName]] <- NULL
        if (is.null(argDescription)) argDescription <- ""
        result <- append(result, sprintf("\\item{%s}{%s}", argName, argDescription))
      }
    }
  }
  # are there any remaining arguments, not included in the argument list?
  # if so, they are kwargs / named parameters
  if (length(argDescriptionsFromDoc) > 0) {
    result <- append(result, lapply(
      names(argDescriptionsFromDoc),
      function(x) {
        sprintf("\\item{%s}{optional named parameter: %s}", x, argDescriptionsFromDoc[[x]])
      }
    ))
  }
  paste(result, collapse = "\n")
}

getDictDocString <- function(templateDir) {
  file <- sprintf("%s/dictDocString.txt", templateDir)
  connection <- file(file, open = "r")
  result <- paste(readLines(connection), collapse = "\n")
  close(connection)
  result
}

# any conversion of Sphinx text to Latex text goes here
convertSphinxToLatex <- function(raw) {
  changeSphinxHyperlinksToLatex(raw)
}

changeSphinxHyperlinksToLatex <- function(raw) {
  gsub("`([^<\n]*) <([^>\n]*)>`_", "\\\\href{\\2}{\\1}", raw)
}

insertLatexNewLines <- function(raw) {
  gsub("\n", "\\cr\n", raw, fixed = TRUE)
}

# returns a named list in which the names are arguments
# and the values are their descriptions
parseArgDescriptionsFromDetails <- function(raw) {
  # escape any escaped-escapes
  preprocessed <- gsub("\\\\", "\\\\\\\\", raw)
  # change all quotes to escaped quotes
  preprocessed <- gsub("\"", "\\\\\"", preprocessed)
  # change \r\n to \n
  preprocessed <- gsub("\r\n", "\n", preprocessed)

  # find parameters and convert them, along with their def'ns, to json
  # reminder: \w in a regexp means "word character", [A-Za-z0-9_]
  json <- gsub(":(parameter|param|var) (\\w+):", "\",\"\\2\":\"", preprocessed)
  # prepend "{\"unusedPrefix\":\""
  # add "\"}" to the end
  json <- paste0("{\"unusedPrefix\":\"", json, "\"}")
  # parse JSON into named list
  paramsList <- fromJSON(json)
  # truncate each entry at end
  result <- lapply(
    X = paramsList,
    function(x) {
      p <- regexpr("\n\n|\n:returns?:|\n[Ee]xample:", x)[1]
      if (p < 0) {
        result <- x
      } else {
        result <- substr(x, 1, p - 1)
      }
      # now do any conversion of the description
      result <- pyVerbiageToLatex(result)
      result <- insertLatexNewLines(result)
      result
    }
  )
  result$unusedPrefix <- NULL
  if (length(names(result)) != length(unique(names(result)))) {
    message(sprintf("Warning:  encountered repeated function arguments definitions in docstring: %s", raw))
  }
  result
}

pyVerbiageToLatex <- function(raw) {
  if (missing(raw) || is.null(raw) || length(raw) == 0 || nchar(raw) == 0) return("")
  # this replaces ':param <param name>:' with '\nparam name:'
  # same for parameter, type, var
  result <- raw
  result <- gsub(":(parameter|param|var) (\\w+):", "\n\\2:", result)
  # Reminder:  \\S means 'not whitespace'
  result <- gsub(":py:class:`(\\S+\\.)*(\\S+)`", "\\2", result)

  convertToUpper <- "##convertToUpper##" # marks character to convert
  result <- gsub(":py:mod:`(\\S+\\.)*(\\S+)`", paste0(convertToUpper, "\\2"), result)
  result <- gsub(":py:(func|meth):`Synapse.(\\w+)`", paste0("syn", convertToUpper, "\\2"), result)
  result <- gsub(":py:(func|meth):`synapseclient.Synapse.(\\w+)`", paste0("syn", convertToUpper, "\\2"), result)
  # anything else we simply leave in place for manual curation:
  result <- gsub(":py:(func|meth):`([^`]*)`", "\\2", result)

  while (TRUE) {
    ctuIndex <- regexpr(convertToUpper, result)[[1]]
    if (ctuIndex < 0) break
    lcChar <- nchar(convertToUpper) + ctuIndex
    result <- paste0(
      substring(result, 1, ctuIndex - 1),
      toupper(substring(result, lcChar, lcChar)),
      substring(result, lcChar + 1)
    )
  }

  result <- gsub(dictDocString, "\nConstructor accepts named arguments.\n", result, fixed = TRUE)

  result <- convertSphinxToLatex(result)
}

getDescription <- function(raw) {
  if (missing(raw) || is.null(raw) || length(raw) == 0 || nchar(raw) == 0) return("")
  preprocessed <- gsub("\r\n", "\n", raw, fixed = TRUE)
  # find everything up to the first syphinx token following the description
  terminatorIndex <- regexpr("\n*:(parameter|param|type|var)|\n*?:returns?:|\n{1,}[Ee]xample:", preprocessed)[1]
  if (terminatorIndex < 1) return(preprocessed)
  substr(preprocessed, 1, terminatorIndex - 1)
}

getReturned <- function(raw) {
  if (missing(raw) || is.null(raw) || length(raw) == 0 || nchar(raw) == 0) return("")
  preprocessed <- gsub("\r\n", "\n", raw, fixed = TRUE)
  if (!grepl(":returns?:", preprocessed)) return("")
  # get whatever follows :return: or :returns:
  result <- gsub(".*:returns?:(.*)", "\\1", preprocessed)
  # check for any trailing content
  doubleNewLineIndex <- regexpr("\n\n", result)[1]
  if (doubleNewLineIndex <= 1) return(result)
  substr(result, 1, doubleNewLineIndex - 1)
}

getExample <- function(raw) {
  if (missing(raw) || is.null(raw) || length(raw) == 0 || nchar(raw) == 0) return("")
  preprocessed <- gsub("\r\n", "\n", raw, fixed = TRUE)
  pattern <- ".*[Ee]xample::?\n\n(.*)"
  if (!grepl(pattern, preprocessed)) return("")
  result <- gsub(pattern, "\\1", preprocessed)
  # check for any trailing content
  doubleNewLineIndex <- regexpr("\n\n", result)[1]
  if (doubleNewLineIndex <= 1) return(result)
  substr(result, 1, doubleNewLineIndex - 1)
}

createFunctionRdContent <- function(templateDir, alias, title, description, usage, argument, returned) {
  templateFile <- sprintf("%s/rdFunctionTemplate.Rd", templateDir)
  connection <- file(templateFile, open = "r")
  template <- paste(readLines(connection), collapse = "\n")
  close(connection)

  content <- template
  content <- gsub("##alias##", alias, content, fixed = TRUE)
  if (!missing(title) && !is.null(title)) content <- gsub("##title##", title, content, fixed = TRUE)
  examples <- NULL
  if (!missing(description) && !is.null(description)) {
    processedDescription <- pyVerbiageToLatex(getDescription(description))
    content <- gsub("##description##", processedDescription, content, fixed = TRUE)
    examples <- pyVerbiageToLatex(getExample(description))
  } else {
    content <- gsub("##description##", "", content, fixed = TRUE)
  }
  if (!missing(returned) && !is.null(returned)) {
    value <- pyVerbiageToLatex(returned)
    content <- gsub("##value##", value, content, fixed = TRUE)
  } else {
    content <- gsub("##value##", "", content, fixed = TRUE)
  }
  if (!missing(usage) && !is.null(usage)) content <- gsub("##usage##", usage, content, fixed = TRUE)
  if (!missing(argument) && !is.null(argument)) content <- gsub("##arguments##", argument, content, fixed = TRUE)
  if (is.null(examples) || length(examples) == 0 || nchar(examples) == 0) {
    content <- gsub("##examples##", "", content, fixed = TRUE)
  } else {
    # we comment out the examples which come from the Python client and need to be curated
    content <- gsub("##examples##", paste0("%\\dontrun{\n%", gsub("\n", "\n%", examples), "\n%}"), content, fixed = TRUE)
  }
  content
}

createMethodContent <- function(f) {
  paste0("\\item \\code{", usage(f$name, f$args, f$argDescriptionsFromDoc), "}: ", f$description)
}

createClassRdContent <- function(templateDir, alias, title, description, methods) {
  templateFile <- sprintf("%s/rdClassTemplate.Rd", templateDir)
  connection <- file(templateFile, open = "r")
  template <- paste(readLines(connection), collapse = "\n")
  close(connection)

  content <- template
  content <- gsub("##alias##", alias, content, fixed = TRUE)
  if (!missing(title) && !is.null(title)) content <- gsub("##title##", title, content, fixed = TRUE)
  if (!missing(description) && !is.null(description)) {
    processedDescription <- pyVerbiageToLatex(getDescription(description))
    content <- gsub("##description##", processedDescription, content, fixed = TRUE)
  }
  methodContent <- NULL
  for (method in methods) {
    methodDescription <- method$description
    if (method$name == title) {
      method$description <- sprintf("Constructor for \\code{\\link{%s}}", title)
    } else {
      if (!is.null(methodDescription)) {
        methodDescription <- pyVerbiageToLatex(getDescription(methodDescription))
        methodDescription <- insertLatexNewLines(methodDescription)
        method$description <- methodDescription
      }
    }
    methodContent <- c(methodContent, createMethodContent(method))
  }
  content <- gsub("##methods##", paste(methodContent, collapse = "\n"), content, fixed = TRUE)
  content
}

writeContent <- function(content, name, targetFolder) {
  filePath <- file.path(targetFolder, sprintf("%s.Rd", name))
  connection <- file(filePath, open = "w")
  writeChar(content, connection, eos = NULL)
  writeChar("\n", connection, eos = NULL)
  close(connection)
}

#' @title Generate .Rd files for Python classes and functions
#' @description This function generate .Rd files for Python classes and functions
#'   for a given Python module.
#'
#' @param srcRootDir The directory of the R package
#' @param pyPkg The Python package name
#' @param module The Python module
#' @param modifyFunctions Optional function to modify the returned functions
#' @param modifyClasses Optional function to modify the returned classes
#' @param functionPrefix Optional text to add to the name of the functions
#' @param keepContent Optional wheather the existing files at the target directory
#'   should be kept
#' @param templateDir Optional path to a template directory
#' @details
#' * `generateRdFiles` and `generateRWrappers` should be called with similar
#'   params to ensure all R wrappers has sufficient documentation.
#'   
#' * `module` can have the same value as `pyPkg` or a module within the Python package.
#'   The value that is passed to `module` parameter must be a fully qualified name.
#'   
#' * `modifyFunctions` and `modifyClasses` are optional function defined by the caller.
#' 
#' * `modifyFunctions` takes an object with the schema: ('name', 'args', 'doc', 'module')
#'   and modifies the list of functions found under `module`. See example 2.
#'   
#' * `modifyClasses` takes an object with the schema: ('name', 'constructorArgs', 'doc', 'methods')
#'   and modifies the list of classes found under `module`. See example 3.
#' 
#' @note The generated .Rd files is localed in srcRootDir/auto-man. One must copy
#'  all .Rd files to their man folder and make sure that the language being used in
#'  these documents are friendly to R users.
#' @examples
#' 1.
#' ```
#' .onLoad <- function(libname, pkgname) {
#'   PythonEmbedInR::generateRdFiles(
#'     srcRootDir = "path/to/R/pkg",
#'     pyPkg = "pyPackageName",
#'     module = "aModuleInPyPackageName")
#' }
#' ```
#' 2.
#' ```
#' myModifyFunctions <- function(x) {
#'   if (any(x$name == "myFun")) NULL else x
#' }
#' .onLoad <- function(libname, pkgname) {
#'   PythonEmbedInR::generateRdFiles(
#'     srcRootDir = "path/to/R/pkg",
#'     pyPkg = "pyPackageName",
#'     module = "aModuleInPyPackageName",
#'     modifyFunctions = myModifyFunctions)
#' }
#' ```
#' 3.
#' ```
#' myModifyClasses <- function(x) {
#'   if (any(x$name == "MyObj")) NULL else x
#' }
#' .onLoad <- function(libname, pkgname) {
#'   PythonEmbedInR::generateRdFiles(
#'     srcRootDir = "path/to/R/pkg",
#'     pyPkg = "pyPackageName",
#'     module = "aModuleInPyPackageName",
#'     modifyClasses = myModifyClasses)
#' }
#' ```
generateRdFiles <- function(srcRootDir,
                            pyPkg,
                            module,
                            modifyFunctions = NULL,
                            modifyClasses = NULL,
                            functionPrefix = NULL,
                            keepContent = FALSE,
                            templateDir = NULL) {
  functionInfo <- getFunctionInfo(pyPkg, module, modifyFunctions, functionPrefix)
  classInfo <- getClassInfo(pyPkg, module, modifyClasses)

  autoGenerateRdFiles(srcRootDir, functionInfo, classInfo, keepContent, templateDir)
}
