module filesystem;

import std.file;
import std.string : replace;
import std.path : buildPath, baseName, dirName;
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
        if(source.isDir())
        {
            copyDirectory(source, destination);
        }
        else
        {
            std.file.copy(source, destination);
        }
    }

    void copyDirectory(S)(S source, S destination) if(isSomeString!S)
    {
        foreach(e; source.dirEntries(SpanMode.breadth))
        {
            immutable destinationPath = e.name.replace(source, destination);
            if(e.isDir())
            {
                mkdirRecurse(destinationPath);
            }
            else
            {
                immutable directory = destinationPath.dirName;
                mkdirRecurse(directory);
                std.file.copy(e.name, destinationPath);
            }
        }
    }

    void move(S)(S source, S destination) if(isSomeString!S)
    {
        std.file.rename(source, destination);
    }
}
