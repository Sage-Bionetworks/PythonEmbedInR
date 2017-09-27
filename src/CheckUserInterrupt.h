#include <R_ext/Utils.h>
#include <signal.h>
#include "PythonInR.h"

#ifdef PYTHON_EXPLICIT_LINKING

// copied from pyport.h
#define PyAPI_DATA(RTYPE) extern __declspec(dllexport) RTYPE

// copied from longinterpr.h
struct _longobject {
  PyObject_VAR_HEAD
  unsigned ob_digit[1]; // modified from the original
};


// copied from boolobject.h
/* Don't use these directly */
PyAPI_DATA(struct _longobject) _Py_FalseStruct, _Py_TrueStruct;

/* Use these macros */
#define Py_False ((PyObject *) &_Py_FalseStruct)
#define Py_True ((PyObject *) &_Py_TrueStruct)

#endif

PyObject *pythoninr_checkuserinterrupt(PyObject *self, PyObject *args);

void chkIntFn(void *dummy);

int checkInterrupt();
