discard """
  output: '''
reading
reading
writer acquiring
could not read
could not read
finished reading
finished reading
writing
finished writing
'''
"""

from os import sleep

import rwlocks

type PLock = ptr Rwlock

proc rAction(lock: Plock) {.thread.} =
  if tryAcquireRead(lock[]):
    echo "reading"
    sleep(300)
    echo "finished reading"
    releaseRead(lock[])
  else: echo "could not read"

proc wAction(lock: Plock) {.thread.} =
  echo "writer acquiring"
  acquireWrite(lock[])
  echo "writing"
  sleep(300)
  echo "finished writing"
  releaseWrite(lock[])

var
  rthrs: array[4, Thread[PLock]]
  wthr: Thread[PLock]
  lock: Rwlock

for i in 0..1:
  createThread(rthrs[i], rAction, addr(lock))

sleep(50)
createThread(wthr, wAction, addr(lock))

for i in 2..3:
  createThread(rthrs[i], rAction, addr(lock))

joinThreads(rthrs)
joinThreads(wthr)
