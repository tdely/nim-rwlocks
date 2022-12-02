discard """
  output: '''
acquired
failed to acquire
'''
"""
from os import sleep

import rwlocks

var
  thrs: array[2, Thread[void]]
  lock: Rwlock

proc writer() {.thread.} =
  if tryAcquireWrite(lock):
    echo "acquired"
    sleep(50)
    releaseWrite(lock)
  else: echo "failed to acquire"

for i in 0..1:
  createThread(thrs[i], writer)

joinThreads(thrs)
