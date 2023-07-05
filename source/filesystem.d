module filesystem;

import std.file;
import std.traits : isSomeString;

enum INVALID_CROSS_DEVICE_LINK = 18;

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

    void move(S)(S source, S destination) if(isSomeString!S)
    {
        try
        {
            std.file.rename(source, destination);
        }
        catch(FileException e)
        {
            if(e.errno == INVALID_CROSS_DEVICE_LINK)
            {
                softMove(source, destination);
            }
            else
            {
                throw e;
            }
        }
    }

    void softMove(S)(S source, S destination) if(isSomeString!S)
    {
        copy(source, destination);
        if(source.isDir())
        {
            std.file.rmdirRecurse(source);
        }
        else
        {
            std.file.remove(source);
        }
    }
}
