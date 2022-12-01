import std/locks

type Rwlock* = object
  ## Readers-writer lock (multiple readers, single writer).
  activeReaders: int
  waitingWriters: int
  writerActive: bool
  cond: Cond
  g: Lock

proc tryAcquireRead*(rw: var Rwlock): bool {.inline.} =
  ## Tries to acquire the given lock for reading. Returns `true` on success.
  acquire(rw.g)
  if rw.waitingWriters == 0 and not rw.writerActive:
    inc(rw.activeReaders)
    result = true
  release(rw.g)

proc acquireRead*(rw: var Rwlock) {.inline.} =
  ## Acquires the given lock for reading.
  withLock(rw.g):
    while rw.waitingWriters > 0 or rw.writerActive:
      rw.cond.wait(rw.g)
    inc(rw.activeReaders)

proc releaseRead*(rw: var Rwlock) {.inline.} =
  ## Releases the given lock from reading.
  doAssert rw.activeReaders > 0
  withLock(rw.g):
    dec(rw.activeReaders)
    if rw.activeReaders == 0:
      rw.cond.broadcast()

proc tryAcquireWrite*(rw: var Rwlock): bool {.inline.} =
  ## Tries to acquire the given lock for writing. Returns `true` on success.
  acquire(rw.g)
  if rw.activeReaders == 0 and not rw.writerActive:
    rw.writerActive = true
    result = true
  release(rw.g)

proc acquireWrite*(rw: var Rwlock) {.inline.} =
  ## Acquires the given lock for writing.
  withLock(rw.g):
    inc(rw.waitingWriters)
    while rw.activeReaders > 0 or rw.writerActive:
      rw.cond.wait(rw.g)
    dec(rw.waitingWriters)
    rw.writerActive = true

proc releaseWrite*(rw: var Rwlock) {.inline.} =
  ## Releases the given lock from writing.
  doAssert rw.writerActive
  withLock(rw.g):
    rw.writerActive = false
    rw.cond.broadcast()

template withReadLock*(rw: Rwlock, stmt: untyped) =
  ## Acquires the given lock for reading, executes the statements in body and
  ## releases the lock after the statements finish executing.
  rw.acquireRead()
  try:
    stmt
  finally:
    rw.releaseRead()

template withWriteLock*(rw: Rwlock, stmt: untyped) =
  ## Acquires the given lock for writing, executes the statements in body and
  ## releases the lock after the statements finish executing.
  rw.acquireWrite()
  try:
    stmt
  finally:
    rw.releaseWrite()
