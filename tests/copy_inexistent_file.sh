alias ctrl=$(pwd)/../ctrl
status=0

echo Running $0

#setup
ctrl -V --reset

#test
touch a
rm a
content=$(ctrl -C a)
expected="$(pwd)/a does not exist"

if [ "$content" = "$expected" ]
then
    echo 1/2 OK
else
    echo 1/2 Failed : "$expected" != "$content"
    status=1
fi

touch a
content=$(ctrl -C a && ctrl -V --list)
expected="$(pwd)/a"
if [ "$content" = "$expected" ]
then
    echo 2/2 OK
else
    echo 2/2 Failed : "$expected" != "$content"
    status=1
fi

#cleanup
rm a
ctrl -V --reset

exit $status
