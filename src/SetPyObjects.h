/* --------------------------------------------------------------------------  \

    SetPyObjects

    Provides set functions.

\  -------------------------------------------------------------------------- */

#ifndef SET_PY_OBJECTS
#define SET_PY_OBJECTS

#include "PythonInR.h"
#include "GetPyObjects.h"
#include "CastRObjects.h"
#include "CToR.h"

SEXP py_assign(SEXP r_namespace_name, SEXP r_key_vec, SEXP r_key_name, SEXP value);

SEXP set_py_object(SEXP r_namespace_name, SEXP r_key_vec, SEXP r_key_name, PyObject *py_value);

int delete_python_object(PyObject *py_dict, const char *key);

#endif
