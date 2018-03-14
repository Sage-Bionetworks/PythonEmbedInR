# test module

class MyObj():
  def __init__(self):
    self.x = 0
  def print(self): 
    return(self.x)
  def inc(self):
    self.x += 1
    return(self.x)

def myFun(n):
  if n < 0:
    return(-n)
  else:
    return(n)

def incObj(x):
  return(x.inc())
