/* --------------------------------------------------------------------------  \

   In this header some makros are defined to capture the API changes from 
   Python 2.7 to Python 3.

\  -------------------------------------------------------------------------- */

#ifndef PY_RUN_STRING
#define PY_RUN_STRING

#include "PythonInR.h"
#include "CastPyObjects.h"
#include "CToR.h"
#include "GetPyObjects.h"

SEXP py_run_simple_string(SEXP code);

SEXP py_run_string_single_input(SEXP code);

SEXP py_run_string_file_input(SEXP code, SEXP simplify);

SEXP py_run_string(SEXP code, SEXP merge_namespaces, SEXP override, 
                   SEXP return_to_r, SEXP simplify);

#endif
