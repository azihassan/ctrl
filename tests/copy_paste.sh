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
mkdir tmp
cd tmp
pastard -p
content=$(cat a)
expected=foo

if [ "$content" = "$expected" ]; then
    echo 1/1 OK
else
    echo 1/1 Failed
fi

#cleanup
cd ..
rm -rf tmp
rm a
pastard -p --reset
