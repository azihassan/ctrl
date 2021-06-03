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
    echo 1/5 OK
else
    status=1
    echo 1/5 Failed : "$expected" != "$content"
fi

if [ $(ctrl --list) = "$(pwd)/a" ]
then
    echo 2/5 OK
else
    status=1
    echo 2/5 Failed : "$expected" != "$content"
fi

ctrl -X a --force
if [ $(ctrl --list) = "$(pwd)/a" ]
then
    echo 3/5 OK
else
    status=1
    echo 3/5 Failed : "$expected" != "$content"
fi

mkdir tmp
cd tmp
ctrl -V
content=$(cat a)
expected=foo

if [ "$content" = "$expected" ]; then
    echo 4/5 OK
else
    status=1
    echo 4/5 Failed : "$expected" != "$content"
fi

cd ..
if [ ! -f a ]; then
    echo 5/5 OK
else
    echo 5/5 Failed : a was not moved to tmp/
fi

#cleanup
rm -rf tmp
rm -f a
ctrl --reset
exit $status
