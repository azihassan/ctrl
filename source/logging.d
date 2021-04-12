module logging;

import std.stdio : File, stdout;

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
        if(verbosity > 0)
        {
            output.writeln(args);
            output.flush();
        }
    }

    void opCall(Args...)(lazy Args args)
    {
        log(args);
    }
}

unittest
{
    import std.file : readText, remove;
    import std.stdio : writeln;

    writeln("Test that the logger writes to the output stream");
    auto logger = Logger(1, File("tmp", "w"));
    scope(exit) "tmp".remove();
    logger("foo ", 1, " bar : ", true);

    assert("tmp".readText == "foo 1 bar : true\n");
    logger("a ", false, " b: ", true);
    assert("tmp".readText == "foo 1 bar : true\na false b: true\n");
    writeln("OK");
    writeln("");
}
