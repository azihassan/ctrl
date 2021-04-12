# Ctrl [![Build Status](https://travis-ci.com/azihassan/ctrl.svg?branch=master)](https://travis-ci.com/azihassan/ctrl)

Ctrl is a terminal tool that allows you to copy a file THEN paste it elsewhere. It reproduces the copy/pasting behavior of file explorers on the terminal.

# Examples

The most common use case is to run `ctrl -C` (or `ctrl --copy`) on a file, cd to another directory or move to another terminal window, then call `ctrl -V` (or `ctrl --paste`) there :

```bash
$ mkdir a
$ echo foobar > a/file
$ ctrl -C a/file
$ mkdir b
$ cd b
$ ctrl -V
$ ls
file
$ cat file
foobar
```

As this tool is under development, further examples and details will be added down the road.
