import std.traits : isSomeString;
import std.array : array;
import std.file : exists;
import std.stdio : File, lines;

struct Clipboard
{
    string path;

    this(string path)
    {
        this.path = path;
        init();
    }

    void init()
    {
        if(!path.exists)
        {
            File(path, "w");
        }
    }

    void reset()
    {
        File(path, "w");
    }

    auto list() const
    {
        return path.File.byLine;
    }

    void append(string pending)
    {
        File(path, "a").writeln(pending);
    }
}

struct Logger
{
    int verbosity;

    this(int verbosity)
    {
        this.verbosity = verbosity;
    }

    void log(T)(lazy T dg) if(isSomeString!T)
    {
        if(verbosity)
        {
            dg();
        }
    }

    void opCall(T)(lazy T dg) if(isSomeString!T)
    {
        log(dg);
    }
}
