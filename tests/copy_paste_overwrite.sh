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
echo old > tmp/a
echo new > a
pastard -c a
cd tmp
content=$(pastard -p)
expected="a already exists in this directory."

if [ "$content" = "$expected" ]
then
    echo 1/3 OK
else
    echo 1/3 Failed : "$expected" != "$content"
fi

pastard -p --force
content=$(cat a)
expected="new"
echo $content

if [ "$content" = "$expected" ]
then
    echo 2/3 OK
else
    echo 2/3 Failed : "$expected" != "$content"
fi

cd ..
content=$(pastard -p --list)
expected=""
if [ "$content" = "$expected" ]
then
    echo 3/3 OK
else
    echo 3/3 Failed : "$expected" != "$content"
fi

#cleanup
rm -rf tmp
rm a
pastard -p --reset
