module filesystem;

import std.file;
import std.stdio;
import std.traits : isSomeString;

struct Filesystem
{
    bool exists(S)(S path) if(isSomeString!S)
    {
        return std.file.exists(path);
    }

    string workingDirectory()
    {
        return std.file.getcwd();
    }

    void copy(S)(S source, S destination) if(isSomeString!S)
    {
        std.file.copy(source, destination);
    }
}
