#include "CheckUserInterrupt.h"

/*
 * Has R detected a keyboard interrupt?
 */
PyObject *pythoninr_checkuserinterrupt(PyObject *self, PyObject *args) {
	if (checkInterrupt()) {
		Py_INCREF(Py_True);
		return Py_True;
	}
	Py_INCREF(Py_False);
	return Py_False;

}

// from https://stat.ethz.ch/pipermail/r-devel/2011-April/060702.html
void chkIntFn(void *dummy) {
  R_CheckUserInterrupt();
}

// this will call the above in a top-level context so it won't longjmp-out of your context
int checkInterrupt() {
  return(R_ToplevelExec(chkIntFn, NULL) == FALSE);
}
