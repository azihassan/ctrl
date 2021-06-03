alias ctrl=$(pwd)/../ctrl
status=0

echo Running $0

#setup
ctrl --reset
if [ -f tmp ]; then
    rm -rf tmp
fi

if [ -f a ]; then
    rm a
fi

#test
echo foo > a
ctrl -C a
content=$(ctrl -X a)
expected="[Error] $(pwd)/a is already queued for copying"

if [ "$content" = "$expected" ]
then
    echo 1/3 OK
else
    status=1
    echo 1/3 Failed : "$expected" != "$content"
fi

if [ $(ctrl --list) = "$(pwd)/a" ]
then
    echo 2/3 OK
else
    status=1
    echo 2/3 Failed : "$expected" != "$content"
fi

mkdir tmp
cd tmp
ctrl -V
content=$(cat a)
expected=foo

if [ "$content" = "$expected" ]; then
    echo 3/3 OK
else
    status=1
    echo 3/3 Failed : "$expected" != "$content"
fi

#cleanup
cd ..
rm -rf tmp
rm a
ctrl --reset
exit $status
