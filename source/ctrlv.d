import std.stdio;
import std.algorithm : each;
import std.path;
import std.file;
import std.getopt;
import utils;
import config;

void run(string[] args)
{
    int verbosity;
    bool list, reset, force;
    auto result = args.getopt(
        std.getopt.config.passThrough,
        "v|verbosity+", "Verbosity level", &verbosity,
        "l|list", "Displays the pending actions", &list,
        "r|reset", "Empties the clipboard", &reset,
        "f|force", "Overwrites existing files", &force,
    );

    if(result.helpWanted)
    {
        defaultGetoptPrinter("Pastard - ctrlp", result.options);
        return;
    }

    auto clipboard = Clipboard(getClipboardPath());
    auto logger = Logger(verbosity);
    if(list)
    {
        clipboard.list().each!writeln;
        return;
    }

    if(reset)
    {
        clipboard.reset();
        return;
    }

    char[][] remaining;
    foreach(char[] entry; clipboard.list())
    {
        logger("Copying " ~ entry ~ " to " ~ getcwd);
        immutable localFile = buildPath(getcwd, entry.baseName);
        if(localFile.exists && !force)
        {
            remaining ~= entry.dup;
            writeln(entry.baseName, " already exists in this directory.");
            continue;
        }

        if(!entry.exists)
        {
            writeln(entry, " no longer exists.");
            continue;
        }
        copy(entry, localFile);
    }

    clipboard.reset();
    clipboard.append(remaining);
}
