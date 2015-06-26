#include "PythonFunctions.h"

/*
TODO: acutally I wan't this to be a python package which can be shipped 
      with PythonInR but should be loaded on it's own.
*/


/*
static PyMethodDef Sexp_methods[] = {
  {"list_attrs", (PyCFunction)Sexp_list_attr, METH_NOARGS,
   Sexp_list_attr_doc},
  {"do_slot", (PyCFunction)Sexp_do_slot, METH_O,
   Sexp_do_slot_doc},
  {"do_slot_assign", (PyCFunction)Sexp_do_slot_assign, METH_VARARGS,
   Sexp_do_slot_assign_doc},
  {"rsame", (PyCFunction)Sexp_rsame, METH_O,
   Sexp_rsame_doc},
#if (PY_VERSION_HEX < 0x03010000)  
  {"__deepcopy__", (PyCFunction)Sexp_duplicate, METH_KEYWORDS,
   Sexp_duplicate_doc},
#else
  {"__deepcopy__", (PyCFunction)Sexp_duplicate, METH_VARARGS | METH_KEYWORDS,
   Sexp_duplicate_doc},
#endif
  {"__getstate__", (PyCFunction)Sexp___getstate__, METH_NOARGS,
   Sexp___getstate___doc},
  {"__setstate__", (PyCFunction)Sexp___setstate__, METH_O,
   Sexp___setstate___doc},
  {"__reduce__", (PyCFunction)Sexp___reduce__, METH_NOARGS,
   Sexp___reduce___doc},
  {NULL, NULL}          // sentinel
};

*/

PyObject *r_eval_py_string(PyObject* self, PyObject *args){
    SEXP e, tmp;
    int hadError;
    ParseStatus status;
    
    char* code = NULL;
    
    Rprintf("eval 1\n");
    if (!PyArg_ParseTuple(args, "s", &code)) Py_RETURN_NONE;
    Rprintf("code: %s\n", code);

    PROTECT(tmp = mkString(code));
    //PROTECT(tmp = mkString("{plot(1:10, pch=\"+\"); print(1:10)}"));
    Rprintf("eval 2\n");
    
    PROTECT(e = R_ParseVector(tmp, 1, &status, R_NilValue));
    Rprintf("eval 3\n");
    PrintValue(e);
    Rprintf("eval 4\n");
    R_tryEval(VECTOR_ELT(e,0), R_GlobalEnv, &hadError);
    Rprintf("eval 5\n");
    UNPROTECT(2);
    Rprintf("eval 6\n");

    return(PyLong_FromLong(0));
}


PyObject *py_get_r_object(PyObject* self, PyObject *py_name){
    //R_do_slot(R_GlobalEnv, name);
    SEXP r_obj;
    Rprintf("get 1\n");
    char *c_name = NULL;

    if (!PyArg_ParseTuple(py_name, "s", &c_name)) Py_RETURN_NONE;

    Rprintf("get 1\n");
    r_obj = findVar(install(c_name), R_GlobalEnv);

    if (r_obj == R_UnboundValue) {
        Rprintf("not found 1\n");
        return(PyLong_FromLong(-1));
    }

    PyObject *py_object = r_to_py(r_obj);
    return(py_object);
}


PyObject *py_set_r_object(PyObject *self, PyObject *args){
    PyObject *args_len, *args_i;
    SEXP key;
    char *c_key;
    int len;

    Rprintf("set 1\n");
    args_len = PyLong_FromSsize_t(PyTuple_GET_SIZE(args));
    len = PY_TO_C_LONG(args_len);
    Py_XDECREF(args_len);

    if (len != 2) error("py_set_r_object wrong length!\n");

    Rprintf("set 2\n");
    args_i = PyLong_FromLong(0);
    //key = py_to_r(PyTuple_GetItem(args, PyLong_AsSsize_t(args_i)), 1, 1);
    c_key = PY_TO_C_STRING(PyTuple_GetItem(args, PyLong_AsSsize_t(args_i)));
    Py_XDECREF(args_i);

    Rprintf("set 3\n");
    args_i = PyLong_FromLong(1);
    // TODO: check if ref count is right
    SEXP val = py_to_r(PyTuple_GetItem(args, PyLong_AsSsize_t(args_i)), 1, 1);
    Py_XDECREF(args_i);

    key = Rf_install(c_key); // create a symbol
    Rprintf("set 4\n");
	setVar(key, val, R_GlobalEnv);
    Rprintf("set 5\n");
    //UNPROTECT(1);
    Rprintf("set 6\n");
    
    return(PyLong_FromLong(0));
}

/*
SEXP *py_get_r_value(SEXP rho, SEXP lang){
    SEXP t;
    Rprintf("get 1\n");
    t = findVarInFrame3( rho, lang, TRUE);
    Rprintf("get 2\n");
    return t;
}
*/


static PyMethodDef PythonInRMethods[] = {
    {"eval",  (PyCFunction)r_eval_py_string, METH_VARARGS, "comment"},
    {"get",  (PyCFunction)py_get_r_object, METH_VARARGS, "comment"},
    {"set",  (PyCFunction)py_set_r_object, METH_VARARGS, "comment"},
    {NULL, NULL, 0, NULL}
};

PyMODINIT_FUNC python_in_r_init_methods(void){
    (void) Py_InitModule("PythonInR", PythonInRMethods);
}

/*
SEXP py_substitute(SEXP lang, SEXP rho){
    SEXP t;
    switch (TYPEOF(lang)) {
    case PROMSXP:
	return substitute(PREXPR(lang), rho);
    case SYMSXP:
	if (rho != R_NilValue) {
	    t = findVarInFrame3( rho, lang, TRUE);
	    if (t != R_UnboundValue) {
		if (TYPEOF(t) == PROMSXP) {
		    do {
			t = PREXPR(t);
		    } while(TYPEOF(t) == PROMSXP);
		    // make sure code will not be modified:
		    if (NAMED(t) < 2) SET_NAMED(t, 2);
		    return t;
		}
		else if (TYPEOF(t) == DOTSXP)
		    error(_("'...' used in an incorrect context"));
		if (rho != R_GlobalEnv)
		    return t;
	    }
	}
	return (lang);
    case LANGSXP:
	return //substituteList(lang, rho);
    default:
	return (lang);
    }
}
*/

