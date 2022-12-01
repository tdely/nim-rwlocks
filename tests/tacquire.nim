discard """
  output: '''
reading
reading
finished reading
finished reading
writing
finished writing
writing
finished writing
reading
reading
finished reading
finished reading
'''
"""

from os import sleep

import rwlocks

type PLock = ptr Rwlock

proc rAction(lock: Plock) {.thread.} =
  acquireRead(lock[])
  echo "reading"
  sleep(300)
  echo "finished reading"
  releaseRead(lock[])

proc wAction(lock: Plock) {.thread.} =
  acquireWrite(lock[])
  echo "writing"
  sleep(300)
  echo "finished writing"
  releaseWrite(lock[])

var
  rthrs: array[4, Thread[PLock]]
  wthrs: array[2, Thread[PLock]]
  lock: Rwlock

for i in 0..1:
  createThread(rthrs[i], rAction, addr(lock))

sleep(50)

for i in 0..1:
  createThread(wthrs[i], wAction, addr(lock))

sleep(50)

for i in 2..3:
  createThread(rthrs[i], rAction, addr(lock))

joinThreads(wthrs)
joinThreads(rthrs)

