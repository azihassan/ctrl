module ctrl;

import std.path;
import std.conv : to;
import std.stdio : writeln;
import std.typecons : Flag, Tuple, No;
import std.range : empty;

import clipboard : Clipboard;
import logging : Logger;
import filesystem : Filesystem;

struct Ctrl
{
    Filesystem filesystem;
    Clipboard clipboard;
    Logger logger;

    this(Clipboard clipboard, Filesystem filesystem, Logger logger)
    {
        this.filesystem = filesystem;
        this.clipboard = clipboard;
        this.logger = logger;
    }

    Error[] queue(Tuple!(string, Mode)[] paths)
    {
        Error[] errors;
        foreach(pending; paths)
        {
            string path = pending[0];
            Mode mode = pending[1];
            if(!filesystem.exists(path))
            {
                logger(path, " does not exist");
                errors ~= Error(ErrorType.NOT_FOUND, path);
                continue;
            }

            if(clipboard.has(path))
            {
                logger(path, " is already queued for copying");
                errors ~= Error(ErrorType.ALREADY_QUEUED, path);
                continue;
            }
            clipboard.append(pending.expand);
        }
        return errors;
    }

    Error[] execute(Flag!"force" force = No.force)
    {
        Error[] errors;
        foreach(char[] entry; clipboard.list())
        {
            immutable localFile = buildPath(filesystem.workingDirectory, entry.baseName);
            if(filesystem.exists(localFile) && !force)
            {
                errors ~= Error(ErrorType.ALREADY_EXISTS_IN_DESTINATION, entry.idup);
                logger(entry.baseName, " already exists in this directory.");
                continue;
            }

            if(!filesystem.exists(entry))
            {
                errors ~= Error(ErrorType.NO_LONGER_EXISTS, entry.idup);
                logger(entry, " no longer exists.");
                continue;
            }

            filesystem.copy(entry.idup, localFile);
        }

        clipboard.reset();
        if(!errors.empty)
        {
            foreach(error; errors)
            {
                clipboard.append(error.subject, Mode.COPY);
            }
        }

        return errors;
    }
}

enum Mode
{
    COPY, MOVE
}

struct Error
{
    ErrorType type;
    string subject;

    string toString()
    {
        return subject ~ " : " ~ type.to!string;
    }
}

enum ErrorType
{
    NOT_FOUND,
    ALREADY_QUEUED,
    ALREADY_EXISTS_IN_DESTINATION,
    NO_LONGER_EXISTS
}

version(unittest)
{
    import std;
}

unittest
{
    writeln("Should queue files correctly");
    scope(success) writeln("OK\n");

    string clipboardPath = "/tmp/clipboard.tmp";
    string logPath = "/tmp/clipboard.log";
    scope(exit) clipboardPath.remove();
    scope(exit) logPath.remove();

    auto clipboard = Clipboard(clipboardPath);
    auto filesystem = Filesystem();
    auto logger = Logger(1, File(logPath, "w"));
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    ctrl.queue([tuple(clipboardPath, Mode.COPY)]);
    assert(clipboard.has(clipboardPath));
}

unittest
{
    writeln("Should return NOT FOUND if queued path is incorrect");
    scope(success) writeln("OK\n");

    string clipboardPath = "/tmp/clipboard.tmp";
    string logPath = "/tmp/clipboard.log";
    scope(exit) clipboardPath.remove();
    scope(exit) logPath.remove();

    auto clipboard = Clipboard(clipboardPath);
    auto filesystem = Filesystem();
    auto logger = Logger(1, File(logPath, "w"));
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    string bogusPath = "/foo/bar";
    auto errors = ctrl.queue([tuple(bogusPath, Mode.COPY)]);
    assert(!errors.empty, "Expected errors not to be empty, instead it was empty");
    assert(errors[0].type == ErrorType.NOT_FOUND);
    assert(errors[0].subject == bogusPath);
    assert(!clipboard.has(bogusPath), "Expected clipboard not to have " ~ bogusPath);
}

unittest
{
    writeln("Should return ALREADY_QUEUED if path is queued twice");
    scope(success) writeln("OK\n");

    string clipboardPath = "/tmp/clipboard.tmp";
    string logPath = "/tmp/clipboard.log";
    scope(exit) clipboardPath.remove();
    scope(exit) logPath.remove();

    auto clipboard = Clipboard(clipboardPath);
    auto filesystem = Filesystem();
    auto logger = Logger(1, File(logPath, "w"));
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    auto errors = ctrl.queue([
        tuple(clipboardPath, Mode.COPY),
        tuple(clipboardPath, Mode.COPY)
    ]);

    assert(!errors.empty, "Expected errors not to be empty, instead it was empty");
    assert(errors[0].type == ErrorType.ALREADY_QUEUED);
    assert(errors[0].subject == clipboardPath);
    assert(clipboard.has(clipboardPath), "Expected clipboard to have " ~ clipboardPath ~ ", but it didn't");
}

unittest
{
    writeln("Should return NO_LONGER_EXISTS when pasting file that was deleted after queueing");
    scope(success) writeln("OK\n");

    string clipboardPath = "/tmp/clipboard.tmp";
    string logPath = "/tmp/clipboard.log";
    string tmpFile = "/tmp/tmp";
    scope(exit) clipboardPath.remove();
    scope(exit) logPath.remove();
    scope(exit)
    {
        if(tmpFile.exists)
        {
            tmpFile.remove();
        }
    }

    File(tmpFile, "w").writeln("tmp");

    auto clipboard = Clipboard(clipboardPath);
    auto filesystem = Filesystem();
    auto logger = Logger(1, File(logPath, "w"));
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    auto errors = ctrl.queue([tuple(tmpFile, Mode.COPY)]);
    assert(errors.empty, "Expected errors to be empty, instead found : " ~ errors.map!(to!string).join("\n"));

    tmpFile.remove();
    assert(!tmpFile.exists);
    errors = ctrl.execute();

    assert(!errors.empty, "Expected errors not to be empty, instead it was empty");
    assert(errors[0].type == ErrorType.NO_LONGER_EXISTS, "Expected error type to be NO_LONGER_EXISTS, instead it was " ~ errors[0].type.to!string);
    assert(errors[0].subject == tmpFile);
    assert(clipboard.has(tmpFile), "Expected clipboard to have " ~ tmpFile ~ ", but it didn't");
}

unittest
{
    writeln("Should return ALREADY_EXISTS_IN_DESTINATION when pasting file that exists in the working directory");
    scope(success) writeln("OK\n");
    
    string clipboardPath = "/tmp/clipboard.tmp";
    string logPath = "/tmp/clipboard.log";

    string sourcePath = "/tmp/copyme";
    string destinationPath = "copyme";

    scope(exit) clipboardPath.remove();
    scope(exit) logPath.remove();
    scope(exit)
    {
        if(sourcePath.exists)
        {
            sourcePath.remove();
        }
        if(destinationPath.exists)
        {
            destinationPath.remove();
        }
    }

    File(sourcePath, "w").write("copy me");
    File(destinationPath, "w").write("don't overwrite me");

    auto clipboard = Clipboard(clipboardPath);
    auto filesystem = Filesystem();
    auto logger = Logger(1, File(logPath, "w"));
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    auto errors = ctrl.queue([tuple(sourcePath, Mode.COPY)]);
    assert(errors.empty, "Expected errors to be empty, instead found : " ~ errors.map!(to!string).join("\n"));

    errors = ctrl.execute();

    assert(!errors.empty, "Expected errors not to be empty, instead it was empty");
    assert(errors[0].type == ErrorType.ALREADY_EXISTS_IN_DESTINATION, "Expected error type to be ALREADY_EXISTS_IN_DESTINATION, instead it was " ~ errors[0].type.to!string);
    assert(errors[0].subject == sourcePath);
    assert(clipboard.has(sourcePath), "Expected clipboard to still have " ~ sourcePath ~ ", but it didn't");
    assert(destinationPath.readText() == "don't overwrite me", "Expected destination to contain 'don't overwrite me', instead it has : '" ~ destinationPath.readText() ~ "'");
}

unittest
{
    writeln("Should overwrite target path when pasting file that exists in the working directory with the 'force' flag");
    scope(success) writeln("OK\n");

    string clipboardPath = "/tmp/clipboard.tmp";
    string logPath = "/tmp/clipboard.log";

    string sourcePath = "/tmp/copyme";
    string destinationPath = "copyme";

    scope(exit) clipboardPath.remove();
    scope(exit) logPath.remove();
    scope(exit)
    {
        if(sourcePath.exists)
        {
            sourcePath.remove();
        }
        if(destinationPath.exists)
        {
            destinationPath.remove();
        }
    }

    File(sourcePath, "w").write("copy me");
    File(destinationPath, "w").write("don't overwrite me");

    auto clipboard = Clipboard(clipboardPath);
    auto filesystem = Filesystem();
    auto logger = Logger(1, File(logPath, "w"));
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    auto errors = ctrl.queue([tuple(sourcePath, Mode.COPY)]);
    assert(errors.empty, "Expected errors to be empty, instead found : " ~ errors.map!(to!string).join("\n"));

    errors = ctrl.execute(Yes.force);

    assert(errors.empty, "Expected errors not to be empty, instead it was empty");
    assert(!clipboard.has(sourcePath), "Expected clipboard not to have " ~ sourcePath ~ ", but it did");
    assert(destinationPath.readText() == "copy me");
}

unittest
{
    writeln("Should paste file correctly if there are no errors");
    scope(success) writeln("OK\n");

    string clipboardPath = "/tmp/clipboard.tmp";
    string logPath = "/tmp/clipboard.log";

    string sourcePath = "/tmp/tocopy";
    string destinationPath = "tocopy";

    scope(exit) clipboardPath.remove();
    scope(exit) logPath.remove();
    scope(exit)
    {
        if(sourcePath.exists)
        {
            sourcePath.remove();
        }
        if(destinationPath.exists)
        {
            destinationPath.remove();
        }
    }

    File(sourcePath, "w").write("copy me");

    auto clipboard = Clipboard(clipboardPath);
    auto filesystem = Filesystem();
    auto logger = Logger(1, File(logPath, "w"));
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    auto errors = ctrl.queue([tuple(sourcePath, Mode.COPY)]);
    assert(errors.empty, "Expected errors to be empty, instead found : " ~ errors.map!(to!string).join("\n"));
    assert(clipboard.has(sourcePath), "Expected clipboard to have " ~ sourcePath ~ ", but it didn't");

    errors = ctrl.execute();

    assert(errors.empty, "Expected errors to be empty, instead it has " ~ errors.map!(to!string).join(", "));
    assert(!clipboard.has(sourcePath), "Expected clipboard not to have " ~ sourcePath ~ ", but it did");
    assert(destinationPath.readText() == "copy me");
}
