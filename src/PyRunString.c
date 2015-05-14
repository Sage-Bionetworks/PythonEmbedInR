/* --------------------------------------------------------------------------  \

    PyRunString 

    PyRunString provides functions to run Pyhton code from within R.

\  -------------------------------------------------------------------------- */

#include "PyRunString.h"  

/*  ----------------------------------------------------------------------------
    py_run_simple_string 
    
    executes one line of Python code from R.
    :param str code: The code that should be executed
    :return: NULL
    :rtype: NULL
  ----------------------------------------------------------------------------*/    
SEXP py_run_simple_string(SEXP code){
    const char *c_code;
    int success = 0;
    c_code = R_TO_C_STRING(code);
    success = PyRun_SimpleString(c_code);
    PyRun_SimpleString("\n");
    if (success==-1){
        error("");
    }
    return R_NilValue;
}

/*  ----------------------------------------------------------------------------
    py_run_simple_string 
    
    executes one line of Python code from R and prints the stdout at the screen.
    :param str code: The code that should be executed
    :return: NULL
    :rtype: NULL
  ----------------------------------------------------------------------------*/ 
SEXP py_run_string_single_input(SEXP code){
    PyObject *py_main, *py_dict, *py_object;
    const char *py_code;
    
    py_code = R_TO_C_STRING(code);

    py_main = PyImport_AddModule("__main__"); // borrowed reference but I don't increase it since it should always be one
    py_dict = PyModule_GetDict(py_main);
    Py_XINCREF(py_dict);
    py_object = PyRun_String(py_code, Py_single_input, py_dict, py_dict);
    PyRun_SimpleString("\n");
    if (py_object == NULL){ 
        error("in py_run_string_single_input");
    }
 
    Py_XDECREF(py_object);
    return R_NilValue;
}

/*  ----------------------------------------------------------------------------
    py_run_string_file_input 
    
    executes multiple lines of Python code from R and returns the therby 
    created variables in a list.
    :param str code: The code that should be executed
    :return: A list with all the variables created in the script.
    :rtype: list
  ----------------------------------------------------------------------------*/ 
SEXP py_run_string_file_input(SEXP code, SEXP simplify){
    SEXP r_object;
    PyObject *py_global, *py_local, *py_namsp, *py_object;
    const char *py_code;
    int c_simplify = R_TO_C_BOOLEAN(simplify);
    
    py_code = R_TO_C_STRING(code);

    py_namsp = PyImport_AddModule("__main__");
    py_global = PyModule_GetDict(py_namsp);
    Py_XINCREF(py_global);

    py_local = PyDict_New();
    py_object = PyRun_String(py_code, Py_file_input, py_global, py_local);
    PyRun_SimpleString("\n");
    Py_XDECREF(py_global);

    if (py_object == NULL){
        Py_XDECREF(py_local);
        error("in py_run_string_file_input");
    }

    r_object = py_to_r(py_local, c_simplify);
    Py_XDECREF(py_object);
    Py_XDECREF(py_local);
    return r_object;
}

/*  ----------------------------------------------------------------------------
    py_run_string
    
    executes multiple lines of Python code from R and returns the thereby 
    created variables in a list.
    :param str code: The code that should be executed.
    :param boolean merge_namespaces:
    :param boolean override:
    :param boolean return_to_r:
    :param boolean simplify:
    :return: A list with all the variables created in the script.
    :rtype: list    
  ----------------------------------------------------------------------------*/
SEXP py_run_string(SEXP code, SEXP merge_namespaces, SEXP override, 
                   SEXP return_to_r, SEXP simplify){
    SEXP r_object;
    PyObject *py_global, *py_local, *py_object, *py_len;
    const char *py_code;
    int merge_namesp, c_override, success = 0;
    int c_simplify = R_TO_C_BOOLEAN(simplify);
    long vec_len;
    
    py_object = NULL;
    py_code = R_TO_C_STRING(code);

    py_global = PyModule_GetDict(PyImport_AddModule("__main__"));
    py_local = PyDict_New();

    py_object = PyRun_String(py_code, Py_file_input, py_global, py_local);
    PyRun_SimpleString("\n");
    
    if (py_object == NULL){
        PyDict_Clear(py_local);
        Py_XDECREF(py_local);
        error("in pyExecg"); // i should see the python traceback anyways!
    }
    Py_XDECREF(py_object);
    merge_namesp = INTEGER(merge_namespaces)[0];
    c_override = INTEGER(override)[0];
    if (merge_namesp){
        // Return 0 on success or -1 if an exception was raised
        success = PyDict_Merge(py_global, py_local, c_override);
        if (success == -1){
            PyDict_Clear(py_local);
            Py_XDECREF(py_local);
            PyRun_SimpleString("\n");
            error("in pyExecg the dictionaries couln't be merged!\n");
        }
    }
    if ( py_local == NULL ){
        r_object = R_NilValue;
    }else{
        py_len = PyLong_FromSsize_t(PyDict_Size(py_local));
        vec_len = PY_TO_C_LONG(py_len);
        if ( INTEGER(return_to_r)[0] && (vec_len > 0) ){
            r_object = py_to_r(py_local, c_simplify);
        }else{
            r_object = R_NilValue;
        }
        Py_XDECREF(py_len);
    }
    Py_XDECREF(py_local);
    return r_object;
}

