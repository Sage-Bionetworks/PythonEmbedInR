import types
from stdouterrCapture import stdouterrCapture

# args[0] is an object and args[1] is a method name.  args[2:] and kwargs are the method's arguments
def invoke(*args, **kwargs):
    method_to_call = getattr(args[0], args[1])
    return stdouterrCapture(lambda: method_to_call(*args[2:], **kwargs), abbreviateStackTrace=True)
