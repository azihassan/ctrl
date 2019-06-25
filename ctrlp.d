import std.stdio;
import std.algorithm : each;
import std.path;
import std.file;
import std.getopt;
import utils;
import config;

void main(string[] args)
{
    int verbosity;
    bool list, reset;
    auto result = args.getopt(
        std.getopt.config.passThrough,
        "v|verbosity+", "Verbosity level", &verbosity,
        "l|list", "Displays the pending actions", &list,
        "r|reset", "Empties the clipboard", &reset,
    );

    if(result.helpWanted)
    {
        defaultGetoptPrinter("Pastard - ctrlc", result.options);
        return;
    }

    auto clipboard = Clipboard(getClipboardPath());
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

    scope(success)
    {
        clipboard.reset();
    }

    foreach(char[] entry; clipboard.list())
    {
        if(verbosity > 0)
        {
            writeln("Copying ", entry, " to ", getcwd);
        }

        if(!entry.exists)
        {
            writeln(entry, " no longer exists.");
            continue;
        }
        copy(entry, buildPath(getcwd, entry.baseName));
    }
}
