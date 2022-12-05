import std/locks

{.push stacktrace: off.}

type Rwlock* = object
  ## Readers-writer lock (multiple readers, single writer).
  users {.guard: g.}: int # number of readers active, -1 if writer active
  waitingWriters {.guard: g.}: int
  cond: Cond
  g: Lock

proc initLock*(rw: var Rwlock) {.inline.} =
  initCond(rw.cond)
  initLock(rw.g)

proc deinitLock*(rw: var Rwlock) {.inline.} =
  deinitCond(rw.cond)
  deinitLock(rw.g)

proc tryAcquireRead*(rw: var Rwlock): bool {.inline.} =
  ## Tries to acquire the given lock for reading. Returns `true` on success.
  withLock(rw.g):
    if rw.waitingWriters == 0 and rw.users > -1:
      inc(rw.users)
      result = true

proc acquireRead*(rw: var Rwlock) {.inline.} =
  ## Acquires the given lock for reading.
  withLock(rw.g):
    while rw.waitingWriters > 0 or rw.users == -1:
      rw.cond.wait(rw.g)
    inc(rw.users)

proc releaseRead*(rw: var Rwlock) {.inline.} =
  ## Releases the given lock from reading.
  withLock(rw.g):
    doAssert rw.users > 0
    dec(rw.users)
    if rw.users == 0:
      rw.cond.broadcast()

proc tryAcquireWrite*(rw: var Rwlock): bool {.inline.} =
  ## Tries to acquire the given lock for writing. Returns `true` on success.
  withLock(rw.g):
    if rw.users == 0:
      dec(rw.users)
      result = true

proc acquireWrite*(rw: var Rwlock) {.inline.} =
  ## Acquires the given lock for writing.
  withLock(rw.g):
    inc(rw.waitingWriters)
    while rw.users != 0:
      rw.cond.wait(rw.g)
    dec(rw.waitingWriters)
    rw.users = -1

proc releaseWrite*(rw: var Rwlock) {.inline.} =
  ## Releases the given lock from writing.
  withLock(rw.g):
    doAssert rw.users == -1
    rw.users = 0
    rw.cond.broadcast()

template withReadLock*(rw: Rwlock, stmt: untyped) =
  ## Acquires the given lock for reading, executes the statements in body and
  ## releases the lock after the statements finish executing.
  {.locks: [rw].}:
    rw.acquireRead()
    try:
      stmt
    finally:
      rw.releaseRead()

template withWriteLock*(rw: Rwlock, stmt: untyped) =
  ## Acquires the given lock for writing, executes the statements in body and
  ## releases the lock after the statements finish executing.
  {.locks: [rw].}:
    rw.acquireWrite()
    try:
      stmt
    finally:
      rw.releaseWrite()

{.pop.}
