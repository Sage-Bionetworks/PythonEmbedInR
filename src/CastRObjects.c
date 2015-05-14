/* --------------------------------------------------------------------------  \

    CastRObjects

    Provides functions cast R objects into Python objects!

\  -------------------------------------------------------------------------- */

#include "CastRObjects.h"
#include "PythonInR.h"

/*  ----------------------------------------------------------------------------

    r_logical_to_py_boolean 

  ----------------------------------------------------------------------------*/
PyObject *r_logical_to_py_boolean(SEXP r_object){
    PyObject *py_object;
    if( IS_LOGICAL(r_object) ){
        py_object = R_TO_PY_BOOLEAN(r_object);
    } else{
        error("r_logical_to_py_boolean the provided variable has not type logical!");
    }
    return py_object;
}

/*  ----------------------------------------------------------------------------

    r_integer_to_py_long 

  ----------------------------------------------------------------------------*/
PyObject *r_integer_to_py_long(SEXP r_object){
    PyObject *py_object;
    if( IS_INTEGER(r_object) ){
        py_object = R_TO_PY_LONG(r_object);
    } else{
        error("r_integer_to_py_long the provided variable has not type integer!");
    }
    return py_object;
}

/*  ----------------------------------------------------------------------------

    r_numeric_to_py_double 

  ----------------------------------------------------------------------------*/
PyObject *r_numeric_to_py_double(SEXP r_object){
    PyObject *py_object;
    if( IS_NUMERIC(r_object) ){
        py_object = R_TO_PY_DOUBLE(r_object);
    } else{
        error("r_numeric_to_py_double the provided variable has not type numeric!");
    }
    return py_object;
}

/*  ----------------------------------------------------------------------------

    r_character_to_py_string
      is byte string in python 3
  ----------------------------------------------------------------------------*/
PyObject *r_character_to_py_string(SEXP r_object){
    PyObject *py_object;
    if( IS_CHARACTER(r_object) ){
        py_object = R_TO_PY_STRING(r_object);
    } else{
        error("r_character_to_py_string the provided variable has not type character!");
    }
    return py_object;
}

/*  ----------------------------------------------------------------------------

    r_character_to_py_unicode

  ----------------------------------------------------------------------------*/
PyObject *r_character_to_py_unicode(SEXP r_object){
    PyObject *py_object;
    if( IS_CHARACTER(r_object) ){
        py_object = R_TO_PY_UNICODE(r_object);
    } else{
        error("r_character_to_py_unicode the provided variable has not type character!");
    }
    return py_object;
}

/*  ----------------------------------------------------------------------------

    r_to_py_primitive

  ----------------------------------------------------------------------------*/
PyObject *r_to_py_primitive(SEXP r_object){
    PyObject *py_object;
    
    if( IS_LOGICAL(r_object) ){
        py_object = R_TO_PY_BOOLEAN(r_object);
    } else if ( IS_INTEGER(r_object) ){
        py_object = R_TO_PY_LONG(r_object);
    } else if ( IS_NUMERIC(r_object) ){
        py_object = R_TO_PY_DOUBLE(r_object);
    } else if ( IS_CHARACTER(r_object) ){
        py_object = R_TO_PY_UNICODE(r_object);
    } else if ( isComplex(r_object) ){
        error("in r_to_py_primitive\n     conversion of type complex isn't supported jet!");
    } else {
        error("in r_to_py_primitive\n     unkown data type!\n\n");
    }
    return py_object;   
}

/*  ----------------------------------------------------------------------------

    r_to_py_tuple

  ----------------------------------------------------------------------------*/
PyObject *r_to_py_tuple(SEXP r_object){
    PyObject *py_object, *item;
    long i, len;

    len = GET_LENGTH(r_object);
    py_object = PyTuple_New(len);

    if (len == 0) return(py_object);
    
    if( IS_LOGICAL(r_object) ){
        for(i = 0; i < len; i++) {
            item = R_TO_PY_BOOLEAN_V(r_object,i);
            PyTuple_SET_ITEM(py_object, i, item);
        }
    }else if ( IS_INTEGER(r_object) ){
        for(i = 0; i < len; i++) {
            item = R_TO_PY_LONG_V(r_object,i);
            PyTuple_SET_ITEM(py_object, i, item);
        }
    }else if ( IS_NUMERIC(r_object) ){
        for(i = 0; i < len; i++) {
            item = R_TO_PY_DOUBLE_V(r_object,i);
            PyTuple_SET_ITEM(py_object, i, item);
        }
    }else if ( IS_CHARACTER(r_object) ){
       for(i = 0; i < len; i++) {
            item = R_TO_PY_UNICODE_V(r_object,i);
            PyTuple_SET_ITEM(py_object, i, item);
       }
    }else if ( isComplex(r_object) ){
        Py_XDECREF(py_object);
        error("in r_to_py_tuple\n     conversion of type complex isn't supported jet!");
    }else if ( IS_LIST(r_object) ){
        for(i = 0; i < len; i++) {
            item = r_to_py(VECTOR_ELT(r_object, i));
            PyTuple_SET_ITEM(py_object, i, item);
        }
    }else {
        Py_XDECREF(py_object);
        error("in r_to_py_tuple\n     unkown data type!\n\n");
    }
    return py_object;
}

/*  ----------------------------------------------------------------------------

    r_to_py_list

  ----------------------------------------------------------------------------*/
PyObject *r_to_py_list(SEXP r_object){
    PyObject *py_object, *item;
    long i, len;

    len = GET_LENGTH(r_object);
    py_object = PyList_New(len);
    
    if( IS_LOGICAL(r_object) ){
        for(i = 0; i < len; i++) {
            item = R_TO_PY_BOOLEAN_V(r_object,i);
            PyList_SET_ITEM(py_object, i, item);
        }
    }else if ( IS_INTEGER(r_object) ){
        for(i = 0; i < len; i++) {
            item = R_TO_PY_LONG_V(r_object,i);
            PyList_SET_ITEM(py_object, i, item);
        }
    }else if ( IS_NUMERIC(r_object) ){
        for(i = 0; i < len; i++) {
            item = R_TO_PY_DOUBLE_V(r_object,i);
            PyList_SET_ITEM(py_object, i, item);
        }
    }else if ( IS_CHARACTER(r_object) ){
       for(i = 0; i < len; i++) {
            item = R_TO_PY_UNICODE_V(r_object,i);
            PyList_SET_ITEM(py_object, i, item);
       }
    }else if ( isComplex(r_object) ){
        Py_XDECREF(py_object);
        error("in r_to_py_list\n     conversion of type complex isn't supported jet!");
    }else if ( IS_LIST(r_object) ){
        for(i = 0; i < len; i++) {
            item = r_to_py(VECTOR_ELT(r_object, i));
            PyList_SET_ITEM(py_object, i, item);
        }
    }else {
        Py_XDECREF(py_object);
        error("in r_to_py_list\n     unkown data type!\n\n");
    }
    return py_object;
}

/*  ----------------------------------------------------------------------------

    r_to_py_dict

  ----------------------------------------------------------------------------*/
PyObject *r_to_py_dict(SEXP r_keys, SEXP r_values){
    PyObject *py_object, *key, *value;
    long i, len;

    len = GET_LENGTH(r_values);
    py_object = PyDict_New();

    if( IS_LOGICAL(r_values) ){
        for(i = 0; i < len; i++) {
            key = R_TO_PY_UNICODE_V(r_keys,i);
            value = R_TO_PY_BOOLEAN_V(r_values,i);
            PyDict_SetItem(py_object, key, value);
        }
    }else if ( IS_INTEGER(r_values) ){
        for(i = 0; i < len; i++) {
            key = R_TO_PY_UNICODE_V(r_keys,i);
            value = R_TO_PY_LONG_V(r_values,i);
            PyDict_SetItem(py_object, key, value);
        }
    }else if ( IS_NUMERIC(r_values) ){
        for(i = 0; i < len; i++) {
            key = R_TO_PY_UNICODE_V(r_keys,i);
            value = R_TO_PY_DOUBLE_V(r_values,i);
            PyDict_SetItem(py_object, key, value);
        }
    }else if ( IS_CHARACTER(r_values) ){
        for(i = 0; i < len; i++) {
            key = R_TO_PY_UNICODE_V(r_keys,i);
            value = R_TO_PY_UNICODE_V(r_values,i);
            PyDict_SetItem(py_object, key, value);
        }
    }else if ( isComplex(r_values) ){
        Py_XDECREF(py_object);
        error("in r_to_py_dict\n     conversion of type complex isn't supported jet!");
    }else if ( IS_LIST(r_values) ){
        for(i = 0; i < len; i++) {
            key = R_TO_PY_UNICODE_V(r_keys,i);
            value = r_to_py(VECTOR_ELT(r_values, i));
            PyDict_SetItem(py_object, key, value);
        }
    }else {
        Py_XDECREF(py_object);
        error("in r_to_py_dict\n     unkown data type!\n\n");
    }    
    return py_object;
}

/*  ----------------------------------------------------------------------------

    r_to_py
  ----------------------------------------------------------------------------*/
PyObject *r_to_py(SEXP r_object){
    PyObject *py_object;
    long len=-1; 
    SEXP names;

    len = GET_LENGTH(r_object);
    names = GET_NAMES(r_object);
    
    if(GET_LENGTH(names) > 0){                                                  // Case 1: R object has names!        
        py_object = r_to_py_dict(names, r_object);
    }else if ( len == 1 && ( IS_LOGICAL(r_object) || IS_INTEGER(r_object) || 
                             IS_NUMERIC(r_object) || IS_CHARACTER(r_object) || 
                             isComplex(r_object)) ){                            // Case 2: Convert to int, unicode, ...!
        py_object = r_to_py_primitive(r_object);
    }else if ( (IS_LIST(r_object) && len >= 1) ) {                              // Case 3: R object is a list!
        py_object = r_to_py_list(r_object);
    }else if ( len == 0 ){                                                      // Case 4: Convert R NULL or character(0), ... to Py_None
        Py_RETURN_NONE;
    }else{                                                                      // Case 5: Should actually never happen!
        error("in r_to_py provided object is not supported!\n"); 
    }
    return py_object;
}

/*  ----------------------------------------------------------------------------

    check_r_type_flags
    Just a test function to see if the functions behave as assumed.
    NOTE: This function is never used in any other code.
  ----------------------------------------------------------------------------*/
SEXP check_r_type_flags(SEXP r_object){
    Rprintf("len: %i\n", GET_LENGTH(r_object));
    Rprintf("len names: %i\n", GET_LENGTH(GET_NAMES(r_object)));

    if (IS_LIST(r_object)) Rprintf("IS_LIST\n");
    if (IS_LOGICAL(r_object)) Rprintf("IS_LOGICAL\n");
    if (IS_INTEGER(r_object)) Rprintf("IS_INTEGER\n");
    if (IS_NUMERIC(r_object)) Rprintf("IS_NUMERIC\n");
    if (IS_CHARACTER(r_object)) Rprintf("IS_CHARACTER\n");
    if (isComplex(r_object)) Rprintf("isComplex\n");

    return R_NilValue;
}

