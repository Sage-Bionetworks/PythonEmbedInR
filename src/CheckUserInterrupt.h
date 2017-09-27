#include <R_ext/Utils.h>
#include <signal.h>
#include "PythonInR.h"

PyObject *pythoninr_checkuserinterrupt(PyObject *self, PyObject *args);

void chkIntFn(void *dummy);

int checkInterrupt();
