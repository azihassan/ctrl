# Ctrl ![build](https://github.com/azihassan/ctrl/actions/workflows/main.yml/badge.svg?branch=master) [![codecov](https://codecov.io/gh/azihassan/ctrl/branch/master/graph/badge.svg?token=2IILST4RV8)](https://codecov.io/gh/azihassan/ctrl)

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

The arguments get be listed by running `ctrl -h` or `ctrl --help` :

```bash
$ ctrl -h
Ctrl
-C       --copy Queue given file for copying
-X        --cut Queue given file for moving
-V      --paste Paste clipboard contents in current directory
-l       --list Display the pending actions
-r      --reset Empty the clipboard
-f      --force Overwrite existing files when pasting
-v --verbosity+ Verbosity level
-h       --help This help information.
```

As this tool is under development, further examples and details will be added down the road.
