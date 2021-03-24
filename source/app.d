import std.stdio : writeln;
import std.getopt;
import std.path : buildPath;
import std.typecons : Tuple, tuple, Yes, No;
import std.range : empty;
import std.algorithm : each;

import filesystem : Filesystem;
import logging : Logger;
import clipboard : Clipboard;
import pastard : Pastard, Mode;
import config;

void main(string[] args)
{
    bool copy, cut, paste;
    bool list, reset, force;
    int verbosity = 1;
    auto result = args.getopt(
        std.getopt.config.passThrough,
        "c|copy", "Queue given file for copying", &copy,
        "x|cut", "Queue given file for moving", &cut,
        "p|paste", "Paste clipboard contents in current directory", &paste,

        "l|list", "Display the pending actions", &list,
        "r|reset", "Empty the clipboard", &reset,
        "f|force", "Overwrite existing files when pasting", &force,

        "v|verbosity+", "Verbosity level", &verbosity
    );

    if(result.helpWanted)
    {
        defaultGetoptPrinter("Pastard", result.options);
        return;
    }

    auto clipboard = Clipboard(getClipboardPath());
    auto filesystem = Filesystem();
    auto logger = Logger(verbosity);
    auto pastard = Pastard(clipboard, filesystem, logger);

    if(copy)
    {
        Tuple!(string, Mode)[] pending;
        foreach(arg; args[1 .. $])
        {
            pending ~= tuple(buildPath(filesystem.workingDirectory, arg), Mode.COPY);
        }
        pastard.queue(pending);
    }

    if(cut)
    {
        writeln("--cut is not implemented yet");
        return;
    }

    else if(list)
    {
        clipboard.list().each!writeln;
    }

    else if(reset)
    {
        clipboard.reset();
    }

    else if(paste)
    {
        auto errors = pastard.execute(force ? Yes.force : No.force);

        clipboard.reset();
        if(!errors.empty)
        {
            foreach(error; errors)
            {
                clipboard.append(error.subject, Mode.COPY);
            }
        }
    }
}
