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
echo old > tmp/a
echo new > a
ctrl -C a
cd tmp
content=$(ctrl -V)
expected="a already exists in this directory."

if [ "$content" = "$expected" ]
then
    echo 1/3 OK
else
    status=1
    echo 1/3 Failed : "$expected" != "$content"
fi

ctrl -V --force
content=$(cat a)
expected="new"
echo $content

if [ "$content" = "$expected" ]
then
    echo 2/3 OK
else
    status=1
    echo 2/3 Failed : "$expected" != "$content"
fi

cd ..
content=$(ctrl -V --list)
expected=""
if [ "$content" = "$expected" ]
then
    echo 3/3 OK
else
    status=1
    echo 3/3 Failed : "$expected" != "$content"
fi

#cleanup
rm -rf tmp
rm a
ctrl -V --reset
exit $status
