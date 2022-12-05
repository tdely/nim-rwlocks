discard """
  outputsub: "10"
"""
from os import sleep

import rwlocks

var
  thrs: array[100, Thread[void]]
  lock: Rwlock
  writes = cast[ptr int](allocShared0(sizeof(int)))

proc reader() {.thread.} =
  acquireRead(lock)
  sleep(50)
  discard writes[]
  releaseRead(lock)

proc writer() {.thread.} =
  acquireWrite(lock)
  sleep(50)
  inc(writes[])
  releaseWrite(lock)

for i in 0..39:
  createThread(thrs[i], reader)

for i in 40..49:
  createThread(thrs[i], writer)

for i in 50..99:
  createThread(thrs[i], reader)

joinThreads(thrs)

echo $writes[]
