alias ctrl=$(pwd)/../ctrl
status=0

echo Running $0

#setup
ctrl -V --reset

#test
touch a b c
content=$(ctrl -C a b c && ctrl -V --list)
expected="$(pwd)/a
$(pwd)/b
$(pwd)/c"
if [ "$content" = "$expected" ]
then
    echo 1/1 OK
else
    status=1
    echo 1/1 Failed
    echo Expected :
    echo "$expected"
    echo Actual :
    echo "$content"
fi

#cleanup
rm a b c
ctrl -V --reset
exit $status
