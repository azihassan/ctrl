import std.stdio;
import std.algorithm : each;
import std.path;
import std.file;
import std.getopt;
import utils;

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

    if(list)
    {
        listClipboard(getClipboardPath()).each!writeln;
        return;
    }

    if(reset)
    {
        resetClipboard(getClipboardPath());
        return;
    }

    scope(success) resetClipboard(getClipboardPath);
    foreach(entry; File(getClipboardPath()).byLine)
    {
        if(verbosity > 0)
            writeln("Copying ", entry, " to ", getcwd);

        if(!entry.exists)
        {
            writeln(entry, " no longer exists.");
            continue;
        }
        copy(entry, buildPath(getcwd, entry.baseName));
    }
}
