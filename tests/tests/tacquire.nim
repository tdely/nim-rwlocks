discard """
  timeout: 15
"""
from os import sleep

import rwlocks

var
  thrs: array[20, Thread[void]]
  lock: Rwlock
  writes = cast[ptr int](allocShared0(sizeof(int)))

proc reader() {.thread.} =
  var x: int
  while x < 10:
    acquireRead(lock)
    x = writes[]
    releaseRead(lock)
    sleep(40)

proc writer() {.thread.} =
  for i in 0..9:
    acquireWrite(lock)
    inc(writes[])
    releaseWrite(lock)
    sleep(50)

initLock(lock)

for i in 0..16:
  createThread(thrs[i], reader)
for i in 17..19:
  createThread(thrs[i], writer)

joinThreads(thrs)

deinitLock(lock)
