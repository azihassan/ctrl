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
ctrl -X a
content=$(ctrl -C a)
expected="[Error] $(pwd)/a is already queued for moving"

if [ "$content" = "$expected" ]
then
    echo 1/4 OK
else
    status=1
    echo 1/4 Failed : "$expected" != "$content"
fi

if [ $(ctrl --list) = "$(pwd)/a" ]
then
    echo 2/4 OK
else
    status=1
    echo 2/4 Failed : "$expected" != "$content"
fi

mkdir tmp
cd tmp
ctrl -V
content=$(cat a)
expected=foo

if [ "$content" = "$expected" ]; then
    echo 3/4 OK
else
    status=1
    echo 3/4 Failed : "$expected" != "$content"
fi


if [ ! -f ../a ]; then
    echo 4/4 OK
else
    status=1
    echo 4/4 Failed : expected ../a not to exist, but it exists
fi

#cleanup
cd ..
rm -rf tmp
rm -f a
ctrl --reset
exit $status
