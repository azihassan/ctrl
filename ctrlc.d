import std.stdio : writeln, File;
import std.path : buildPath;
import std.file : getcwd, exists;
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

    immutable logger = Logger(verbosity);
    foreach(arg; args[1 .. $])
    {
        immutable pending = buildPath(getcwd, arg);
        logger("Copying " ~ pending);

        if(!pending.exists)
        {
            writeln(pending, " does not exist");
            continue;
        }

        if(clipboard.has(pending))
        {
            writeln(pending, " is already queued for copying");
            continue;
        }
        clipboard.append(pending);
    }
}
