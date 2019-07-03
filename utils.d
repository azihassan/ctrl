import std.traits : isSomeString;
import std.range : ElementType, isInputRange;
import std.array : array;
import std.file : exists;
import std.string : strip;
import std.stdio : File, lines;
import std.algorithm : each;

struct Clipboard
{
    string path;

    this(string path)
    {
        this.path = path;
        init();
    }

    bool has(string path) const
    {
        foreach(char[] entry; list())
        {
            if(entry.strip == path.strip)
            {
                return true;
            }
        }
        return false;
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

    void append(StringRange)(StringRange pending) if(isInputRange!StringRange && isSomeString!(ElementType!StringRange))
    {
        auto fh = File(path, "a");
        pending.each!(p => fh.writeln(p));
    }
}

struct Logger
{
    int verbosity;

    this(int verbosity)
    {
        this.verbosity = verbosity;
    }

    void log(T)(lazy T dg) const if(isSomeString!T)
    {
        if(verbosity)
        {
            dg();
        }
    }

    void opCall(T)(lazy T dg) const if(isSomeString!T)
    {
        log(dg);
    }
}
