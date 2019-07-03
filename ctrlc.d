import std.stdio : writeln, File;
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

    immutable logger = Logger(verbosity);
    immutable pending = buildPath(getcwd, args[1]);
    logger("Copying " ~ pending);

    if(clipboard.has(pending))
    {
        writeln(pending, " is already queued for copying");
        return;
    }
    clipboard.append(pending);
}
