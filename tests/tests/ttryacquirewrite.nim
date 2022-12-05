discard """
  output: '''
acquired
failed to acquire
'''
"""
import rwlocks

var
  thrs: array[2, Thread[void]]
  lock: Rwlock
  rCh: Channel[true]
  fCh: Channel[string]

open(fCh)
open(rCh)

proc writer() {.thread.} =
  if tryAcquireWrite(lock):
    fCh.send("acquired")
    discard rCh.recv()
    releaseWrite(lock)
  else: fCh.send("failed to acquire")

for i in 0..high(thrs):
  createThread(thrs[i], writer)
  echo fCh.recv()

for i in 0..high(thrs):
  rCh.send(true)

joinThreads(thrs)
close(fCh)
close(rCh)
