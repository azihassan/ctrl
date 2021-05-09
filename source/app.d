import std.stdio : writeln;
import std.getopt;
import std.path : buildPath;
import std.typecons : Tuple, Flag, tuple, Yes, No;
import std.range : empty;
import std.algorithm : each;

import filesystem : Filesystem;
import logging : Logger;
import clipboard : Clipboard;
import ctrl : Ctrl, Mode;
import config;

void main(string[] args)
{
    bool copy, cut, paste;
    bool list, reset, force;
    int verbosity = 1;
    auto result = args.getopt(
        std.getopt.config.passThrough,
        "C|copy", "Queue given file for copying", &copy,
        "X|cut", "Queue given file for moving", &cut,
        "V|paste", "Paste clipboard contents in current directory", &paste,

        "l|list", "Display the pending actions", &list,
        "r|reset", "Empty the clipboard", &reset,
        "f|force", "Overwrite existing files when pasting", &force,

        "v|verbosity+", "Verbosity level", &verbosity
    );

    if(result.helpWanted)
    {
        defaultGetoptPrinter("Ctrl", result.options);
        return;
    }

    auto clipboard = Clipboard(getClipboardPath());
    auto filesystem = Filesystem();
    auto logger = Logger(verbosity);
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    if(copy)
    {
        Tuple!(string, Mode, Flag!"force")[] pending;
        foreach(arg; args[1 .. $])
        {
            pending ~= tuple(buildPath(filesystem.workingDirectory, arg), Mode.COPY, force ? Yes.force : No.force);
        }
        ctrl.queue(pending);
    }

    if(cut)
    {
        Tuple!(string, Mode, Flag!"force")[] pending;
        foreach(arg; args[1 .. $])
        {
            pending ~= tuple(buildPath(filesystem.workingDirectory, arg), Mode.MOVE, force ? Yes.force : No.force);
        }
        ctrl.queue(pending);
    }

    else if(list)
    {
        clipboard.list().each!(pair => pair[0].writeln);
    }

    else if(reset)
    {
        clipboard.reset();
    }

    else if(paste)
    {
        auto errors = ctrl.execute(force ? Yes.force : No.force);

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
