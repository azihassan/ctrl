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
mkdir tmp
touch tmp/a
echo foo > a
echo bar > b
echo baz > c
ctrl -C a
ctrl -C b
ctrl -C c
cd tmp
content=$(ctrl -V)
expected="[Error] a already exists in this directory.
[OK] $(pwd)/b
[OK] $(pwd)/c"

if [ "$content" = "$expected" ]
then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed : "$expected" != "$content"
fi

cd ..

content=$(ctrl --list)
expected="$(pwd)/a"
if [ "$content" = "$expected" ]
then
    echo 2/2 OK
else
    status=1
    echo 2/2 Failed : "$expected" != "$content"
fi

#cleanup
rm -rf tmp
rm a
rm b
rm c
ctrl --reset
exit $status
