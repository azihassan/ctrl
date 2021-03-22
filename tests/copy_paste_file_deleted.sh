alias pastard=$(pwd)/../pastard
status=0

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
rm a

if [ "$(pastard -p --list)" = "$(pwd)/a" ]; then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed : $(pastard -p --list) != $(pwd)/a
fi

mkdir tmp
cd tmp

content=$(pastard -p)
cd ..
expected="$(pwd)/a no longer exists."

if [ "$content" = "$expected" ]; then
    echo 2/2 OK
else
    status=1
    echo 2/2 Failed : "$content" != "$expected" 
fi

#cleanup
rm -rf tmp
pastard -p --reset
exit $status
