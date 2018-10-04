# test module
from enum import Enum

class DIGIT(Enum):
  ZERO = 0
  ONE = 1
  TWO = 2
  THREE = 3
  FOUR = 4
  FIVE = 5
  SIX = 6
  SEVEN = 7
  EIGHT = 8
  NINE = 9

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
  def setx(x):
    """
    Takes a DIGIT and set its value to self.x
    """
    if isinstance(DIGIT, x):
      self.x = x.value
    else:
      raise ValueError("Input must be an instance of DIGIT")

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
