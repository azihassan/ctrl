import std.stdio : writeln;
import std.getopt;
import ctrlc;
import ctrlv;

void main(string[] args)
{
    bool copy, cut, paste, help;
    auto result = args.getopt(
        std.getopt.config.passThrough,
        "c|copy", "Copy mode", &copy,
        "C|Cut", "Cut mode", &cut,
        "p|paste", "Paste mode", &paste,
        "h|help", "Help", &help
    );

    if(help && !copy && !cut && !paste)
    {
        defaultGetoptPrinter("Pastard", result.options);
    }

    if(copy)
    {
        ctrlc.run(args.appendHelp(help));
    }

    if(paste)
    {
        ctrlv.run(args.appendHelp(help));
    }
}

string[] appendHelp(string[] args, bool help) {
    if(!help)
    {
        return args;
    }
    return args ~ "-h";
}
