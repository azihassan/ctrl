import std.stdio : writeln, File;
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

    if(args.length == 1 && verbosity > 0)
    {
        writeln("Nothing to do here.");
        return;
    }

    initClipboard(getClipboardPath());
    if(verbosity > 0)
        writeln("Copying ", args[1]);

    File(getClipboardPath(), "a").writeln(buildPath(getcwd, args[1]));
}
