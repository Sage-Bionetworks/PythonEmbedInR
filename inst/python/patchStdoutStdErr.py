import sys

# stdout / stderr get rerouted to some sort of logger which lacks expected attributes,
# so we add them as per this discussion
# from https://stackoverflow.com/questions/47069239/consolebuffer-object-has-no-attribute-isatty
def patch_stdout_stderr():
    patch_stream(sys.stdout)
    patch_stream(sys.stderr)
    
def patch_stream(stream):
    if not hasAttr(stream, 'isatty'):
        stream.isatty = lambda: True
    if not hasAttr(stream, 'encoding') or stream.encoding is None:
        stream.encoding = sys.getdefaultencoding()
