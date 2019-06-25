import std.stdio : writeln, File;
import std.string : strip;
import std.path : buildPath;
import std.file : getcwd;
import std.getopt;
import utils;
import config;

void main(string[] args)
{
    int verbosity;
    auto result = args.getopt(
        std.getopt.config.passThrough,
        "v|verbosity+", "Verbosity level", &verbosity,
    );

    if(result.helpWanted || args.length == 1)
    {
        defaultGetoptPrinter("Pastard - ctrlc", result.options);
        return;
    }

    auto clipboard = Clipboard(getClipboardPath());
    auto logger = Logger(verbosity);
    auto pending = buildPath(getcwd, args[1]);
    logger("Copying " ~ pending);

    foreach(char[] entry; clipboard.list())
    {
        if(entry.strip == pending.strip)
        {
            writeln(pending, " is already queued for copying");
            return;
        }
    }
    clipboard.append(pending);
}
