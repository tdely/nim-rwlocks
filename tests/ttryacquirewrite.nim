discard """
  output: '''
writing
could not write
finished writing
'''
"""

from os import sleep

import rwlock

type PLock = ptr Rwlock

proc wAction(lock: Plock) {.thread.} =
  if tryAcquireWrite(lock[]):
    echo "writing"
    sleep(300)
    echo "finished writing"
    releaseWrite(lock[])
  else: echo "could not write"

var
  wthrs: array[2, Thread[PLock]]
  lock: Rwlock

for i in 0..1:
  createThread(wthrs[i], wAction, addr(lock))

joinThreads(wthrs)
