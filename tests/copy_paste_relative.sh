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
mkdir tmp
cd tmp
pastard -c ../a

#if [ "$(pastard -p --list)" = "$(readlink `pwd`/../a)" ]; then
if [ "$(pastard -p --list)" = "`pwd`/../a" ]; then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed : $(pastard -p --list) != $(pwd)/a
fi

pastard -p
content=$(cat a)
expected=foo

if [ "$content" = "$expected" ]; then
    echo 2/2 OK
else
    status=1
    echo 2/2 Failed
fi

#cleanup
cd ..
rm -rf tmp
rm a
pastard -p --reset
exit $status
