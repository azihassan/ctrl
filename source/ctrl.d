module ctrl;

import std.path;
import std.conv : to;
import std.stdio : writeln;
import std.typecons : Flag, Tuple, No;
import std.range : empty;
import std.algorithm : map;
import std.typecons : tuple, Tuple;
import std.array : array;

import clipboard : Clipboard;
import logging : Logger;
import filesystem : Filesystem;

struct Ctrl
{
    Filesystem filesystem;
    Clipboard clipboard;
    Logger logger;

    this(ref Clipboard clipboard, Filesystem filesystem, Logger logger)
    {
        this.filesystem = filesystem;
        this.clipboard = clipboard;
        this.logger = logger;
    }

    Error[] queue(Tuple!(string, Mode)[] paths)
    {
        return queue(paths.map!(path => tuple(path[0], path[1], No.force)).array);
    }

    Error[] queue(Tuple!(string, Mode, Flag!"force")[] paths)
    {
        Error[] errors;
        foreach(pending; paths)
        {
            string path = pending[0];
            Mode mode = pending[1];
            auto force = pending[2];
            if(!filesystem.exists(path))
            {
                logger("[Error] ", path, " does not exist");
                errors ~= Error(ErrorType.NOT_FOUND, path, mode);
                continue;
            }

            if(clipboard.has(path) && !force)
            {
                Tuple!(string, Mode) existing = clipboard.get(path);
                logger("[Error] ", path, " is already queued for ", existing[1] == Mode.COPY ? "copying" : "moving");
                errors ~= Error(ErrorType.ALREADY_QUEUED, path, mode);
                continue;
            }
            clipboard.append(path, mode);
        }
        return errors;
    }

    Error[] execute(Flag!"force" force = No.force)
    {
        Error[] errors;
        foreach(path, mode; clipboard.list())
        {
            immutable localFile = buildPath(filesystem.workingDirectory, path.baseName);
            if(filesystem.exists(localFile) && !force)
            {
                errors ~= Error(ErrorType.ALREADY_EXISTS_IN_DESTINATION, path.idup);
                logger("[Error] ", path.baseName, " already exists in this directory.");
                continue;
            }

            if(!filesystem.exists(path))
            {
                errors ~= Error(ErrorType.NO_LONGER_EXISTS, path.idup);
                logger("[Error] ", path, " no longer exists.");
                continue;
            }

            final switch(mode) with(Mode)
            {
                case COPY:
                    filesystem.copy(path.idup, localFile);
                    logger("[OK] ", localFile);
                    break;
                case MOVE:
                    filesystem.move(path.idup, localFile);
                    logger("[OK] ", localFile);
                    break;
            }
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
    Mode mode;

    string toString()
    {
        return "[" ~ mode.to!string ~ "] " ~ subject ~ " : " ~ type.to!string;
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

    auto errors = ctrl.queue([tuple(clipboardPath, Mode.COPY)]);
    assert(errors.empty, "Expected errors to be empty, instead found : " ~ errors.map!(to!string).join("\n"));
    assert(clipboard.has(clipboardPath, Mode.COPY));
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
    assert(errors[0].mode == Mode.COPY);
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
    assert(errors[0].mode == Mode.COPY);
    assert(clipboard.has(clipboardPath, Mode.COPY), "Expected clipboard to have " ~ clipboardPath ~ ", but it didn't");

    errors = ctrl.queue([
        tuple(clipboardPath, Mode.MOVE),
        tuple(clipboardPath, Mode.COPY)
    ]);

    assert(!errors.empty, "Expected errors not to be empty, instead it was empty");
    assert(errors[0].type == ErrorType.ALREADY_QUEUED);
    assert(errors[0].subject == clipboardPath);
    assert(errors[0].mode == Mode.MOVE);
    assert(clipboard.has(clipboardPath, Mode.COPY), "Expected clipboard to have " ~ clipboardPath ~ ", but it didn't");
}

unittest
{
    writeln("Should overwrite queuing mode for already queued paths if queuing with force");
    scope(success) writeln("OK\n");

    string clipboardPath = "/tmp/clipboard.tmp";
    string logPath = "/tmp/clipboard.log";
    scope(exit) clipboardPath.remove();
    scope(exit) logPath.remove();

    auto clipboard = Clipboard(clipboardPath);
    auto filesystem = Filesystem();
    auto logger = Logger(1, File(logPath, "w"));
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    ctrl.queue([
        tuple(clipboardPath, Mode.COPY),
    ]);
    auto errors = ctrl.queue([
        tuple(clipboardPath, Mode.MOVE, Yes.force)
    ]);

    assert(errors.empty, "Expected errors to be empty, instead found : " ~ errors.map!(to!string).join("\n"));
    assert(clipboard.has(clipboardPath, Mode.MOVE), "Expected clipboard to have " ~ clipboardPath ~ ", but it didn't");
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
    assert(clipboard.has(tmpFile, Mode.COPY), "Expected clipboard to have " ~ tmpFile ~ ", but it didn't");
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
    assert(clipboard.has(sourcePath, Mode.COPY), "Expected clipboard to still have " ~ sourcePath ~ ", but it didn't");
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

    auto expectedLogs = "[OK] " ~ buildPath(getcwd(), destinationPath);
    auto actualLogs = logPath.readText();
    assert(actualLogs.strip() == expectedLogs, "Expected logs to be " ~ expectedLogs ~ ", instead it was " ~ actualLogs);
}

unittest
{
    writeln("Should remove original file when queuing in MOVE mode");
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

    File(sourcePath, "w").write("move me");

    auto clipboard = Clipboard(clipboardPath);
    auto filesystem = Filesystem();
    auto logger = Logger(1, File(logPath, "w"));
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    auto errors = ctrl.queue([tuple(sourcePath, Mode.MOVE)]);
    assert(errors.empty, "Expected errors to be empty, instead found : " ~ errors.map!(to!string).join("\n"));
    assert(clipboard.has(sourcePath), "Expected clipboard to have " ~ sourcePath ~ ", but it didn't");

    errors = ctrl.execute();

    assert(errors.empty, "Expected errors to be empty, instead it has " ~ errors.map!(to!string).join(", "));
    assert(!clipboard.has(sourcePath), "Expected clipboard not to have " ~ sourcePath ~ ", but it did");
    assert(destinationPath.readText() == "move me");
    assert(!sourcePath.exists);
}

unittest
{
    import std.process : execute;
    writeln("Should move file across mount points");
    scope(success) writeln("OK\n");

    string clipboardPath = "/tmp/clipboard.tmp";
    string logPath = "/tmp/clipboard.log";

    string sourceDirectory = buildPath(getcwd(), "source-directory");
    string sourcePath = buildPath(sourceDirectory, "tomove");
    string mountedSourceDirectory = "/tmp/cross-device-directory";
    string mountedSourcePath = buildPath(mountedSourceDirectory, "tomove");

    string destinationDirectory = getcwd();
    string destinationPath = buildPath(destinationDirectory, "tomove");

    sourceDirectory.mkdirRecurse();
    mountedSourceDirectory.mkdirRecurse();
    File(sourcePath, "w").write("move me");

    auto mountCommand = execute([
            "sudo", "mount", "--bind", sourceDirectory, mountedSourceDirectory
    ]);
    assert(mountCommand.status == 0, "Failed to mount " ~ mountedSourceDirectory ~ " : " ~ mountCommand.output);

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
        if(sourceDirectory.exists)
        {
            sourceDirectory.rmdirRecurse();
        }
        if(mountedSourceDirectory.exists)
        {
            auto umountCommand = execute([
                    "sudo", "umount", mountedSourceDirectory
            ]);
            assert(umountCommand.status == 0, "Failed to unmount " ~ mountedSourceDirectory ~ " : " ~ umountCommand.output);
            mountedSourceDirectory.rmdirRecurse();
        }
    }

    auto clipboard = Clipboard(clipboardPath);
    auto filesystem = Filesystem();
    auto logger = Logger(1, File(logPath, "w"));
    auto ctrl = Ctrl(clipboard, filesystem, logger);

    auto errors = ctrl.queue([tuple(mountedSourcePath, Mode.MOVE)]);
    assert(errors.empty, "Expected errors to be empty, instead found : " ~ errors.map!(to!string).join("\n"));
    assert(clipboard.has(mountedSourcePath), "Expected clipboard to have " ~ sourcePath ~ ", but it didn't");

    errors = ctrl.execute();

    assert(errors.empty, "Expected errors to be empty, instead it has " ~ errors.map!(to!string).join(", "));
    assert(!clipboard.has(mountedSourcePath), "Expected clipboard not to have " ~ sourcePath ~ ", but it did");
    assert(destinationPath.readText() == "move me");
    assert(!sourcePath.exists);
}
