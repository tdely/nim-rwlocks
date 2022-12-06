discard """
  timeout: 15
"""
import rwlocks

from os import sleep
from random import rand

var
  thrs: array[2, Thread[void]]
  lock: Rwlock
  writes = cast[ptr int](allocShared0(sizeof(int)))

proc reader() {.thread.} =
  var
    read: int
    skippedCount: int
  while read < 5:
    if tryAcquireRead(lock):
      read = writes[]
      releaseRead(lock)
    else: inc(skippedCount)
    sleep(50)
  assert skippedCount > 0

proc writer() {.thread.} =
  for i in 0..4:
    acquireWrite(lock)
    inc(writes[])
    sleep(rand(50))
    releaseWrite(lock)

initLock(lock)

createThread(thrs[0], reader)
createThread(thrs[1], writer)

joinThreads(thrs)
deinitLock(lock)
