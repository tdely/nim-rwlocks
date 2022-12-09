# Package
version = "1.0.1"
author = "Tobias Dély"
description = "Readers-writer locks"
license = "MIT"

# Dependencies
requires "nim >= 1.6.0"

task tests, "Run all tests":
  exec "testament all"
