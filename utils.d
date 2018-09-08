import std.path;
import std.file : exists;
import std.stdio : File;

string getClipboardPath()
{
    return expandTilde("~/.pastard.clipboard");
}

void initClipboard(string path)
{
    if(path.exists)
        return;
    File(path, "w");
}
