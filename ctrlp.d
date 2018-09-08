import std.stdio;
import std.path;
import std.file;
import std.getopt;
import utils;

void main(string[] args)
{
    int verbosity;
    auto result = args.getopt(
        std.getopt.config.passThrough,
        "v|verbosity+", "Verbosity level", &verbosity,
    );

    if(result.helpWanted)
    {
        defaultGetoptPrinter("Pastard - ctrlc", result.options);
        return;
    }

    foreach(entry; File(getClipboardPath()).byLine)
    {
        if(verbosity > 0)
            writeln("Copying ", entry, " to ", getcwd);

        copy(entry, buildPath(getcwd, entry.baseName));
    }
}
