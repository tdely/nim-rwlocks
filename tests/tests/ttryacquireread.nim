discard """
  output: '''
acquired
failed to acquire
'''
"""
from os import sleep

import rwlocks

var
  thrs: array[3, Thread[void]]
  lock: Rwlock
  chan: Channel[string]

proc reader() {.thread.} =
  if tryAcquireRead(lock):
    echo "acquired"
    discard chan.recv()
    releaseRead(lock)
  else: echo "failed to acquire"

proc writer() {.thread.} =
  acquireWrite(lock)
  discard chan.recv()
  releaseWrite(lock)

open(chan)

createThread(thrs[0], reader)
sleep(50)
createThread(thrs[1], writer)
sleep(50)
createThread(thrs[2], reader)
for i in 0..2: chan.send($i)

joinThreads(thrs)
close(chan)
