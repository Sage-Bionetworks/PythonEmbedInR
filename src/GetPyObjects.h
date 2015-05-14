/* --------------------------------------------------------------------------  \

    GetPyObjects

    Provides get functions for R.

\  -------------------------------------------------------------------------- */

#ifndef GET_PY_OBJECTS
#define GET_PY_OBJECTS

#include "PythonInR.h"

SEXP py_get(SEXP r_var_name, SEXP r_namespace_name, SEXP simplify);

SEXP py_get_type(SEXP r_var_name, SEXP r_namespace_name);

PyObject *get_py_object(SEXP r_var_name, SEXP r_namespace_name);

#endif
