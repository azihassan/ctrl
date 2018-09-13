import std.stdio : writeln, File;
import std.string : strip;
import std.path : buildPath;
import std.file : getcwd;
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

    if(args.length == 1)
    {
        defaultGetoptPrinter("Pastard - ctrlc", result.options);
        return;
    }

    initClipboard(getClipboardPath());
    auto pending = buildPath(getcwd, args[1]);
    if(verbosity > 0)
        writeln("Copying ", pending);

    foreach(entry; listClipboard(getClipboardPath))
    {
        if(entry.strip == pending.strip)
        {
            writeln(pending, " is already queued for copying");
            return;
        }
    }
    File(getClipboardPath(), "a").writeln(pending);
}
