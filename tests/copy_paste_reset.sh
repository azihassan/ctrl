alias pastard=$(pwd)/../pastard
status=0

echo Running $0

#setup
pastard -p --reset
if [ -f a ]; then
    rm a
fi

#test
echo foo > a
pastard -c a

if [ "$(pastard -p --list)" = "$(pwd)/a" ]; then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed : $(pastard -p --list) != $(pwd)/a
fi

pastard -p --reset

if [ "$(pastard -p --list)" = "" ]; then
    echo 2/2 OK
else
    status=1
    echo 2/2 Failed : $(pastard -p --list) is not empty
fi

#cleanup
rm a
exit $status
