/* --------------------------------------------------------------------------  \

    GetPyObjects

    Provides function to get Python objects from various name spaces.

\  -------------------------------------------------------------------------- */

#include "GetPyObjects.h"
#include "PythonInR.h"
#include "CastPyObjects.h"

/*  ----------------------------------------------------------------------------
    py_get
  ----------------------------------------------------------------------------*/
SEXP py_get(SEXP r_var_name, SEXP r_namespace_name, SEXP simplify){
    PyObject *py_object;
    SEXP r_object;
    int c_simplify = R_TO_C_BOOLEAN(simplify);
    py_object = get_py_object(r_var_name, r_namespace_name);
    r_object = py_to_r(py_object, c_simplify);
    Py_XDECREF(py_object);
    
    return r_object;
}

/*  ----------------------------------------------------------------------------
    py_get_type
  ----------------------------------------------------------------------------*/
SEXP py_get_type(SEXP r_var_name, SEXP r_namespace_name){
    PyObject *py_object, *py_str, *py_type;
    SEXP r_object;
    
    py_object = get_py_object(r_var_name, r_namespace_name);
    py_type = PyObject_Type(py_object);
    Py_XDECREF(py_object);
    py_str = PyObject_Str(py_type);
    Py_XDECREF(py_type);
    
    r_object = c_to_r_string(PY_TO_C_OBJECT_STRING(py_str));
    Py_XDECREF(py_str);

    return r_object;
}

/*  ----------------------------------------------------------------------------
    get_py_object
  ----------------------------------------------------------------------------*/
PyObject *get_py_object(SEXP r_var_name, SEXP r_namespace_name){
    // let it iterate over py_module_get_dict and py_dict_get_item_string
    // import namespace
    PyObject *py_namespace_name, *py_object, *py_namespace_dict;
    long len = -1, i;
    const char *namespace_name;
    namespace_name = R_TO_C_STRING(r_namespace_name);
    
    py_namespace_name = PyInternalString_FromString(namespace_name);
    py_object = PyImport_Import(py_namespace_name);
    Py_XDECREF(py_namespace_name);
    if (py_object == NULL){ // if the namespace doesn't exist
        PyRun_SimpleString("\n");
        error("the namespace %s could not be found!\n", namespace_name);
    }
    // iterate over module dict and get item string
    len = GET_LENGTH(r_var_name);
    // get module dict
    for(i = 0; i < len; i++) {
        py_namespace_dict = PyModule_GetDict(py_object);
        Py_XDECREF(py_object);
        if (py_namespace_dict == NULL){
            PyRun_SimpleString("\n");
            error("variable doesn't exist!\n");
        }
        Py_XINCREF(py_namespace_dict);
        // #NOTE: PyDict_GetItemString returns borrowed reference!!! 
        py_object = PyDict_GetItemString(py_namespace_dict, R_TO_C_STRING_V(r_var_name, i));
        if (py_object == NULL){
            PyRun_SimpleString("\n");
            error("key %s not found get_py_object\n", R_TO_C_STRING_V(r_var_name, i));
        }
        Py_XINCREF(py_object);
        Py_XDECREF(py_namespace_dict);
    }
    return py_object;
}

