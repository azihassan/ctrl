alias pastard=$(pwd)/../pastard

echo Running $0

#setup
pastard -p --reset
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
pastard -c a
pastard -c b
pastard -c c
cd tmp
content=$(pastard -p)
expected="a already exists in this directory."
echo $content

if [ "$content" = "$expected" ]
then
    echo 1/2 OK
else
    echo 1/2 Failed : "$expected" != "$content"
fi

cd ..

content=$(pastard -p --list)
expected="$(pwd)/a"
if [ "$content" = "$expected" ]
then
    echo 2/2 OK
else
    echo 2/2 Failed : "$expected" != "$content"
fi

#cleanup
rm -rf tmp
rm a
rm b
rm c
pastard -p --reset
