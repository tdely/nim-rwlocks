discard """
  output: '''
reading
finished reading
writing
finished writing
'''
"""
import rwlocks

var lock: Rwlock

try:
  withReadLock(lock):
    echo "reading"
    raise newException(Exception, "finished reading")
except Exception as e: echo e.msg

try:
  withWriteLock(lock):
    echo "writing"
    raise newException(Exception, "finished writing")
except Exception as e: echo e.msg

doAssert tryAcquireRead(lock)
releaseRead(lock)

doAssert tryAcquireWrite(lock)
releaseWrite(lock)
