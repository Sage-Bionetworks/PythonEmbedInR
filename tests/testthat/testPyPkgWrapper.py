# test module

class MyObj():
  """
  A simple test object
  
  :param test:          test parameter for generating ref docs
  :param test2:         second test parameter for generating ref docs
  
  Typically, no parameters are needed::
      
      import testPyPkgWrapper
      obj = testPyPkgWrapper.MyObj()
  
  See:
  
  - :py:func:`testPyPkgWrapper.myFun`
  """
  def __init__(self):
    self.x = 0
  def print(self): 
    """
    Print x
    
    :return: return x.
    """
    return(self.x)
  def inc(self):
    """
    Increment x by 1
    
    :return: return x after incrementing it.
    """
    self.x += 1
    return(self.x)

digits = [0, 1]
def myGenerator():
  for digit in digits:
    yield digit

def myFun(n):
  """
  Absolute value
  
  :param n: the input number 
  :return: return absolute value of n.
  """
  if n < 0:
    return(-n)
  else:
    return(n)

def incObj(x):
  """
  Wrapper for MyObj which calls its inc() method
  
  :param x: an instance of MyObj
  :return: the value of x.inc().
  """
  return(x.inc())
