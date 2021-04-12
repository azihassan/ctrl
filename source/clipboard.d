module clipboard;

import std.traits : isSomeString;
import std.range : ElementType, isInputRange;
import std.array : array;
import std.file : exists;
import std.string : strip;
import std.algorithm : each;
import std.file : mkdirRecurse;
import std.path : dirName;
import std.stdio : File;

import pastard : Mode;

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

    void append(string pending, Mode mode)
    {
        File(path, "a").writeln(pending);
    }

    void append(StringRange)(StringRange pending) if(isInputRange!StringRange && isSomeString!(ElementType!StringRange))
    {
        auto fh = File(path, "a");
        pending.each!(p => fh.writeln(p));
    }
}

unittest
{
    import std.file : exists, remove;
    import std.range : empty;
    import std.stdio : writeln;

    string path = "/tmp/pastard/clipboard.test";
    scope(exit) path.remove();
    auto clipboard = Clipboard(path);

    writeln("Test that the clipboard file is created");
    clipboard.init();
    assert(path.exists, path ~ " was not created by Clipboard.init");
    writeln("OK");
    writeln("");
}

unittest
{
    import std.stdio : writeln;
    import std.file : remove;
    import std.array : array, join;
    string path = "/tmp/pastard/clipboard.test";
    scope(exit) path.remove();
    auto clipboard = Clipboard(path);

    writeln("Test that appending a single item to clipboard is working");
    clipboard.append("/tmp/pastard/clipboard.test", Mode.COPY);
    assert(
        clipboard.list.array == ["/tmp/pastard/clipboard.test"],
        "Clipboard does not contain expected path. Clipboard contents : " ~ clipboard.list.join(", ")
    );
    writeln("OK");
    writeln("");
}

unittest
{
    import std.stdio : writeln;
    import std.file : remove;
    import std.array : join;
    import std.algorithm : equal;
    import std.range : chain, only;

    string path = "/tmp/pastard/clipboard.test";
    scope(exit) path.remove();
    auto clipboard = Clipboard(path);

    writeln("Test that appending multiple items to clipboard is working");
    clipboard.append("/tmp/pastard/clipboard.test", Mode.COPY);
    auto fileList = ["/tmp/a", "/tmp/b", "tmp/c"];
    clipboard.append(fileList);
    assert(
        clipboard.list.equal("/tmp/pastard/clipboard.test".only.chain(fileList)),
        "Clipboard does not contain expected paths. Clipboard contents : " ~ clipboard.list.join(", ")
    );
    writeln("OK");
    writeln("");
}

unittest
{
    import std.stdio : writeln;
    import std.file : remove;
    string path = "/tmp/pastard/clipboard.test";
    scope(exit) path.remove();
    auto clipboard = Clipboard(path);

    writeln("Test that has() is working");
    clipboard.append("/tmp/b", Mode.COPY);
    assert(clipboard.has("/tmp/b"), "Clipboard does not contain expected path");
    assert(!clipboard.has("/tmp/foobar"), "Clipboard contains invalid path");
    writeln("OK");
    writeln("");
}

unittest
{
    import std.stdio : writeln;
    import std.file : remove;
    string path = "/tmp/pastard/clipboard.test";
    scope(exit) path.remove();
    auto clipboard = Clipboard(path);

    writeln("Test that resetting the clipboard empties the file");
    clipboard.append("/deleteme", Mode.COPY);
    clipboard.reset();
    assert(clipboard.list.empty, "Clipboard not empty after reset");
    writeln("OK");
    writeln("");
}
