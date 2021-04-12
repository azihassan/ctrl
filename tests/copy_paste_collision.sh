alias ctrl=$(pwd)/../ctrl
status=0

echo Running $0

#setup
ctrl -V --reset
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
expected="a already exists in this directory."
echo $content

if [ "$content" = "$expected" ]
then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed : "$expected" != "$content"
fi

cd ..

content=$(ctrl -V --list)
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
ctrl -V --reset
exit $status
