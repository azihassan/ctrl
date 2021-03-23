import std.traits : isSomeString;
import std.range : ElementType, isInputRange;
import std.array : array;
import std.file : exists;
import std.string : strip;
import std.stdio : File, lines, stdout;
import std.algorithm : each;
import std.file : mkdirRecurse;
import std.path : dirName;

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
            path.dirName.mkdirRecurse();
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
    File output;

    this(int verbosity, File output = stdout)
    {
        this.verbosity = verbosity;
        this.output = output;
    }

    void log(Args...)(lazy Args args)
    {
        if(verbosity)
        {
            output.writeln(args);
        }
    }

    void opCall(Args...)(lazy Args args)
    {
        log(args);
    }
}

unittest
{
    {
        auto logger = Logger(1, File("tmp", "w"));
        logger("foo ", 1, " bar : ", true);
    }

    import std.file : readText;
    assert("tmp".readText == "foo 1 bar : true\n");
}
