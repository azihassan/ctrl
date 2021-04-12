alias ctrl=$(pwd)/../ctrl
status=0

rm -rf ~/.config/ctrl

echo Running $0

#setup
touch a

#test
content=$(ctrl -C a && ctrl -V --list)
expected="$(pwd)/a"

if [ -f ~/.config/ctrl/clipboard ]; then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed : clipboard not created on first run
fi

if [ "$content" = "$expected" ]; then
    echo 2/2 OK
else
    status=1
    echo 2/2 Failed
    echo Expected :
    echo "$expected"
    echo Actual :
    echo "$content"
fi

#cleanup
rm a
ctrl -V --reset
exit $status
