/* --------------------------------------------------------------------------  \

    SetPyObjects

    Provides functions to set Python objects from within R.

\  -------------------------------------------------------------------------- */

#include "SetPyObjects.h"

/*  ----------------------------------------------------------------------------
    py_assign

    The variable r_key_vec and r_key_name hold the same information
    but in a different format, r_key_name is just used to produce 
    meaningfull error messages (pasting string is in R just easier than in C).
        e.g. r_key_name: "numpy.array"
             r_key_vec:  c("numpy", "array")

  ----------------------------------------------------------------------------*/
SEXP py_assign(SEXP r_namespace_name, SEXP r_key_vec, SEXP r_key_name, SEXP value){
	PyObject *py_value;
	SEXP r_val;
    
    py_value = r_to_py(value);
    r_val = set_py_object(r_namespace_name, r_key_vec, r_key_name, py_value);
    Py_XDECREF(py_value);

    return r_val;
}


/*  ----------------------------------------------------------------------------
    set_py_object
  ----------------------------------------------------------------------------*/
SEXP set_py_object(SEXP r_namespace_name, SEXP r_key_vec, SEXP r_key_name, PyObject *py_value){
    // let it iterate over py_module_get_dict and py_dict_get_item_string
    // import namespace
    PyObject *py_local, *py_global;
    SEXP r_val, r_namesp_name;
    int success = 0, override = 1;
    long len = -1; 
    const char *namespace_name;

    namespace_name = R_TO_C_STRING(r_namespace_name);

    if (strcmp(namespace_name, "__main__") == 0){
        py_global = PyModule_GetDict(PyImport_AddModule("__main__"));
        // Py_XINCREF(py_global); # TEST and DELETE
    }else{
        r_namesp_name = c_to_r_string("__main__"); // # TEST and DELETE
        // py_global = PyModule_GetDict(PyImport_AddModule("__main__"));  # TEST and DELETE
        // Py_XINCREF(py_global);  # TEST and DELETE
        py_global = get_py_object(r_namespace_name, r_namesp_name);
    }

    len = GET_LENGTH(r_key_vec);
    py_local = PyDict_New();
    success = PyDict_SetItemString(py_local, R_TO_C_STRING_V(r_key_vec, len-1), py_value);
    if (success == -1){ 
        PyRun_SimpleString("\n");
        error("could not assign %s \n", r_key_name);
    }

    success = PyDict_Merge(py_global, py_local, override);

    Py_XDECREF(py_local);
    // Py_XDECREF(py_global);  # TEST and DELETE
    r_val = c_to_r_integer(success);
    return r_val;
}

/*  ----------------------------------------------------------------------------
    set_py_object_old not used 
    changed it to fix an issue but the issue was in py_get rather than set
    so maybe this function is also fine! But I am not sure what happens if
    I override a variable? And by merging the Dictonaries with the override
    flag I am confident that this issue is handeled by Python.
  ----------------------------------------------------------------------------*/
SEXP set_py_object_old(SEXP r_namespace_name, SEXP r_key_vec, SEXP r_key_name, PyObject *py_value){
    // let it iterate over py_module_get_dict and py_dict_get_item_string
    // import namespace
    PyObject *py_namespace_name, *py_object, *py_namespace_dict;
    SEXP r_val;
    int success = 0;
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
    
    len = GET_LENGTH(r_key_vec);
    // get module dict
    for(i = 0; i < len; i++) {
        py_namespace_dict = PyModule_GetDict(py_object);
        Py_XDECREF(py_object);
        if (py_namespace_dict == NULL){
            PyRun_SimpleString("\n");
            error("variable doesn't exist!\n");
        }
        Py_XINCREF(py_namespace_dict);
        // PyMapping_SetItemString returns -1 on failure
        success = PyDict_SetItemString(py_namespace_dict, R_TO_C_STRING_V(r_key_vec, i), py_value);
        if (success == -1){
            PyRun_SimpleString("\n");
            error("could not assign %s \n", r_key_name);
        }
        Py_XDECREF(py_namespace_dict);
    }

    r_val = c_to_r_integer(success);
    return r_val;
}

/*  ----------------------------------------------------------------------------
    delete_python_object
  ----------------------------------------------------------------------------*/
int delete_python_object(PyObject *py_dict, const char *key){
    PyObject *value;   
    int success;
    
    value = PyDict_GetItemString(py_dict, key);
    Py_CLEAR(value);
    success = PyDict_DelItemString(py_dict, key);
    
    Py_XDECREF(py_dict);

    return success;
}

/*  ----------------------------------------------------------------------------
    py_del
  ----------------------------------------------------------------------------*/
SEXP py_del(SEXP key){
    PyObject *py_dict; 
    int success;
    const char *c_key  = R_TO_C_STRING(key);

    py_dict = PyModule_GetDict(PyImport_AddModule("__main__"));
    Py_XINCREF(py_dict);

    success = delete_python_object(py_dict, c_key);

    Py_XDECREF(py_dict);
    return c_to_r_integer(success);
}

