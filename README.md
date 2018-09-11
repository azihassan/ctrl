# Pastard

Pastard is a terminal tool that allows you to copy a file THEN paste it elsewhere. It reproduces the copy/pasting behavior of file explorers on the terminal.

# Examples

The most common use case is to run ctrlc on a file, cd to another directory or move to another terminal window, then call ctrlp there :

$ mkdir a
$ echo foobar > a/file
$ ctrlc a/file
$ mkdir b
$ cd b
$ ctrlp
$ ls
file
$ cat file
foobar

As this tool is under development, further examples and details will be added down the road.
