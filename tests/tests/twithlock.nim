discard """
  outputsub: "2"
"""
import rwlocks

var
  lock: Rwlock
  errCount: int

try:
  withReadLock(lock):
    raise newException(Exception, "read")
except Exception: inc(errCount)

try:
  withWriteLock(lock):
    raise newException(Exception, "write")
except Exception: inc(errCount)

echo errCount

doAssert tryAcquireRead(lock)
releaseRead(lock)

doAssert tryAcquireWrite(lock)
releaseWrite(lock)
