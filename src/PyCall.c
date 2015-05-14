/* --------------------------------------------------------------------------  \

    PyCall

    Provides functions call R objects from with in R!

\  -------------------------------------------------------------------------- */

#include "PyCall.h"

/*  ----------------------------------------------------------------------------

    py_call_object

  ----------------------------------------------------------------------------*/
SEXP py_call_object(SEXP r_namespace, SEXP r_obj_name, SEXP r_args, SEXP r_kw, SEXP simplify){
    SEXP r_object;
    PyObject *py_object, *py_args, *py_kw, *py_ret_val;
    long len_kw = -1;
    int c_simplify = R_TO_C_BOOLEAN(simplify);
    
    len_kw = GET_LENGTH(r_kw);

    py_object = get_py_object(r_obj_name, r_namespace);

    // convert the args and kwargs
    // py_args = r_non_nested_list_to_py_tuple(r_args);
    py_args = r_to_py_tuple(r_args);
    if (len_kw < 1){
        py_kw = NULL;
    }else{
        py_kw = r_to_py_dict(GET_NAMES(r_kw), r_kw);
    }

    py_ret_val = PyObject_Call(py_object, py_args, py_kw);
    PyRun_SimpleString("\n");
    Py_XDECREF(py_args);
    Py_XDECREF(py_kw);
    Py_XDECREF(py_object);
    if (py_ret_val == NULL) error("in py_object_call");

    r_object = py_to_r(py_ret_val, c_simplify);
    Py_XDECREF(py_ret_val);
    return(r_object);
}
