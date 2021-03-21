# Pastard [![Build Status](https://travis-ci.com/azihassan/pastard.svg?branch=master)](https://travis-ci.com/azihassan/pastard)

Pastard is a terminal tool that allows you to copy a file THEN paste it elsewhere. It reproduces the copy/pasting behavior of file explorers on the terminal.

# Examples

The most common use case is to run `pastard -c` (or `pastard --copy`) on a file, cd to another directory or move to another terminal window, then call `pastard -p` (or `pastard --paste`) there :

```bash
$ mkdir a
$ echo foobar > a/file
$ pastard -c a/file
$ mkdir b
$ cd b
$ pastard -p
$ ls
file
$ cat file
foobar
```

As this tool is under development, further examples and details will be added down the road.
