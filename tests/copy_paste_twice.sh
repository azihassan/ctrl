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
echo foo > a
pastard -c a
content=$(pastard -c a)
expected="$(pwd)/a is already queued for copying"

if [ "$content" = "$expected" ]
then
    echo 1/3 OK
else
    echo 1/3 Failed : "$expected" != "$content"
fi

if [ $(pastard -p --list) = "$(pwd)/a" ]
then
    echo 2/3 OK
else
    echo 2/3 Failed : "$expected" != "$content"
fi

mkdir tmp
cd tmp
pastard -p
content=$(cat a)
expected=foo

if [ "$content" = "$expected" ]; then
    echo 3/3 OK
else
    echo 3/3 Failed : "$expected" != "$content"
fi

#cleanup
cd ..
rm -rf tmp
rm a
pastard -p --reset
