discard """
  output: '''
0
0
2
'''
"""
from os import sleep

import rwlocks

var
  thrs: array[5, Thread[void]]
  lock: Rwlock
  chan: Channel[string]
  writes = cast[ptr int](allocShared0(sizeof(int)))

proc reader() {.thread.} =
  acquireRead(lock)
  let x = writes[]
  echo x
  discard chan.recv()
  releaseRead(lock)

proc writer() {.thread.} =
  acquireWrite(lock)
  discard chan.recv()
  inc(writes[])
  releaseWrite(lock)

open(chan)

for i in 0..1:
  createThread(thrs[i], reader)
sleep(50)
for i in 2..3:
  createThread(thrs[i], writer)
createThread(thrs[4], reader)
for i in 0..4: chan.send($i)

joinThreads(thrs)
close(chan)
