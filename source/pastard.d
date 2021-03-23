module pastard;

import std.path;
import std.stdio : writeln;
import std.typecons : Flag, Tuple, No;

import clipboard : Clipboard;
import logging : Logger;
import filesystem : Filesystem;

struct Pastard
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
            //logger("Queuing ", path, " for mode ", mode);
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
            //logger("Copying ", entry, " to ", filesystem.workingDirectory());
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
}

enum ErrorType
{
    NOT_FOUND,
    ALREADY_QUEUED,
    ALREADY_EXISTS_IN_DESTINATION,
    NO_LONGER_EXISTS
}
