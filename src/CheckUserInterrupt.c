#include "CheckUserInterrupt.h"

// if R detects user interrupt then create a 'SIGINT' event to interrupt the running Python process
PyObject *pythoninr_checkuserinterrupt(PyObject *self, PyObject *args) {
	if (checkInterrupt()) {
		//printf("User interrupt detected.  Will raise SIGINT.\n");
		//raise(SIGINT);
		//printf("Raised SIGINIT.\n");
		Py_RETURN_TRUE;
	} else {
		//printf("No user interrupt detected.\n");
		Py_RETURN_FALSE;
	}

	//Py_INCREF(Py_None);
	//return Py_None;
}

// from https://stat.ethz.ch/pipermail/r-devel/2011-April/060702.html
static void chkIntFn(void *dummy) {
  //printf("At start of chkIntFn.\n");
  R_CheckUserInterrupt();
  //printf("At end of chkIntFn.\n");
}

// this will call the above in a top-level context so it won't longjmp-out of your context
int checkInterrupt() {
  //printf("At start of checkInterrupt.\n");
  int result = (R_ToplevelExec(chkIntFn, NULL) == FALSE);
  //printf("At end of checkInterrupt.\n");
  return (result);
}
