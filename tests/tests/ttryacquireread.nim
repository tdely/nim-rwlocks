discard """
  output: '''
reader acquired
writer acquired
reader failed to acquire
'''
"""
import rwlocks

var
  thrs: array[3, Thread[void]]
  lock: Rwlock
  fCh: Channel[string]
  rCh: Channel[true]

proc reader() {.thread.} =
  if tryAcquireRead(lock):
    fCh.send("reader acquired")
    releaseRead(lock)
  else: fCh.send("reader failed to acquire")

proc writer() {.thread.} =
  acquireWrite(lock)
  fCh.send("writer acquired")
  discard rCh.recv()
  releaseWrite(lock)

open(fCh)
open(rCh)

createThread(thrs[0], reader)
echo fCh.recv()
createThread(thrs[1], writer)
echo fCh.recv()
createThread(thrs[2], reader)
echo fCh.recv()
rCh.send(true)

joinThreads(thrs)
close(fCh)
close(rCh)
