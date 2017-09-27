#include <R_ext/Utils.h>
#include <signal.h>
#include "PythonInR.h"

void pythoninr_checkuserinterrupt(PyObject *self, PyObject *args);

void chkIntFn(void *dummy);

int checkInterrupt();
