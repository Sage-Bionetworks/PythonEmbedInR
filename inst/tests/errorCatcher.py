# -*- coding: utf-8 -*-
"""
Created on Tue Jan  6 14:29:44 2015

@author: http://www.gossamer-threads.com/lists/python/python/1150418
"""

import logging
import logging.handlers
import sys

FACILITY = logging.handlers.SysLogHandler.LOG_LOCAL6
mylogger = logging.getLogger('spam')
handler = logging.handlers.SysLogHandler(
address='/dev/log', facility=FACILITY)
formatter = logging.Formatter("%(levelname)s:%(message)s [%(module)s]")
handler.setFormatter(formatter)
mylogger.addHandler(handler)
mylogger.setLevel(logging.DEBUG)
mylogger.info('started logging')

def handler_gen(mylogger, sys):
    def my_error_handler(type, value, tb):
        msg = "Uncaught %s: %s" % (type, value)
        mylogger.exception(msg)
        sys.__excepthook__(type, value, tb) # print the traceback to stderr

# Install exception handler.
mylogger.info('installing error handler')
sys.excepthook = handler_gen(mylogger, sys) 
