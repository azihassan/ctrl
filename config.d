import std.path : expandTilde;

string getClipboardPath()
{
    return expandTilde("~/.config/pastard/.clipboard");
}
