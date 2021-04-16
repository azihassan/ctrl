module clipboard;

import std.range : ElementType, isInputRange;
import std.array : array;
import std.file : exists;
import std.algorithm : map;
import std.file : mkdirRecurse;
import std.path : dirName;
import std.stdio : File;
import std.conv : to;
import std.typecons : tuple, Tuple;

import d2sqlite3;

import ctrl : Mode;

alias Clipboard = SqliteClipboard;
template isRangeOfPaths(R)
{
    enum isRangeOfPaths = isInputRange!R && is(ElementType!R == Tuple!(string, Mode));
}

struct SqliteClipboard
{
    string path;
    Database database;

    this(string path)
    {
        this.path = path;
        init();
    }

    bool has(string path)
    {
        auto statement = this.database.prepare("SELECT COUNT(*) FROM queue WHERE path = :path");
        statement.bindAll(path);
        return statement.execute().oneValue!long > 0;
    }

    bool has(string path, Mode mode)
    {
        auto statement = this.database.prepare("SELECT COUNT(*) FROM queue WHERE path = :path AND mode = :mode");
        statement.bindAll(path, mode.to!string);
        return statement.execute().oneValue!long > 0;
    }

    void init()
    {
        if(!path.exists)
        {
            path.dirName.mkdirRecurse();
            File(path, "w");
        }

        this.database = Database(path);
        this.database.run(`CREATE TABLE IF NOT EXISTS queue (
            path TEXT NOT NULL,
            mode TEXT NOT NULL
        )`);
    }

    void reset()
    {
        init();
        this.database.run("DELETE FROM queue");
    }

    void append(string pending, Mode mode)
    {
        auto statement = this.database.prepare("INSERT INTO queue (path, mode) VALUES (:path, :mode)");
        statement.bindAll(pending, mode.to!string);
        statement.execute();
    }

    void append(Paths)(Paths pending) if(isRangeOfPaths!Paths)
    {
        foreach(path; pending)
        {
            append(path.expand);
        }
    }

    auto list()
    {
        return database.execute("SELECT path, mode FROM queue")
            .map!(row => tuple(row["path"].as!string, row["mode"].as!Mode));
    }
}

version(unittest)
{
    import std;
}

unittest
{
    import std.file : exists, remove;
    import std.range : empty;
    import std.stdio : writeln;

    string path = "/tmp/ctrl/clipboard.test";
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
    string path = "/tmp/ctrl/clipboard.test";
    scope(exit) path.remove();
    auto clipboard = Clipboard(path);

    writeln("Test that appending a single item to clipboard is working");
    clipboard.append("/tmp/ctrl/clipboard.test", Mode.MOVE);
    assert(
        clipboard.list.array == [tuple("/tmp/ctrl/clipboard.test", Mode.MOVE)],
        "Clipboard does not contain expected path. Clipboard contents : " ~ clipboard.list.map!(to!string).join(", ")
    );
    writeln("OK");
    writeln("");
}

unittest
{
    import std.stdio : writeln;
    import std.file : remove;
    string path = "/tmp/ctrl/clipboard.test";
    //scope(exit) path.remove();
    auto clipboard = Clipboard(path);

    writeln("Test that has() is working");
    clipboard.append("/tmp/b", Mode.COPY);
    assert(clipboard.has("/tmp/b", Mode.COPY), "Clipboard does not contain expected path for Mode.COPY");
    assert(!clipboard.has("/tmp/b", Mode.MOVE), "Clipboard does not contain expected path for Mode.MOVE");

    clipboard.append("/tmp/a", Mode.MOVE);
    assert(!clipboard.has("/tmp/a", Mode.COPY), "Clipboard does not contain expected path for Mode.COPY");
    assert(clipboard.has("/tmp/a", Mode.MOVE), "Clipboard does not contain expected path for Mode.MOVE");

    assert(!clipboard.has("/tmp/foobar"), "Clipboard contains invalid path");

    writeln("OK");
    writeln("");
}

unittest
{
    import std.stdio : writeln;
    import std.file : remove;
    string path = "/tmp/ctrl/clipboard.test";
    scope(exit) path.remove();
    auto clipboard = Clipboard(path);

    writeln("Test that resetting the clipboard empties the file");
    clipboard.append("/deleteme", Mode.COPY);
    clipboard.reset();
    assert(clipboard.list.empty, "Clipboard not empty after reset");
    writeln("OK");
    writeln("");
}
