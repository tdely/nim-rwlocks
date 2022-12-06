discard """
  timeout: 15
"""
import rwlocks

from os import sleep
from random import rand

var
  thrs: array[100, Thread[void]]
  lock: Rwlock
  writes = cast[ptr int](allocShared0(sizeof(int)))

initLock(lock)

proc writer() {.thread.} =
  if tryAcquireWrite(lock):
    inc(writes[])
    sleep(rand(50))
    releaseWrite(lock)

for i in 0..high(thrs):
  createThread(thrs[i], writer)
  sleep(5)

joinThreads(thrs)

assert writes[] > 0
assert writes[] < high(thrs)

deinitLock(lock)
