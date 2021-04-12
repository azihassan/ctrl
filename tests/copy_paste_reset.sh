alias ctrl=$(pwd)/../ctrl
status=0

echo Running $0

#setup
ctrl -V --reset
if [ -f a ]; then
    rm a
fi

#test
echo foo > a
ctrl -C a

if [ "$(ctrl -V --list)" = "$(pwd)/a" ]; then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed : $(ctrl -V --list) != $(pwd)/a
fi

ctrl -V --reset

if [ "$(ctrl -V --list)" = "" ]; then
    echo 2/2 OK
else
    status=1
    echo 2/2 Failed : $(ctrl -V --list) is not empty
fi

#cleanup
rm a
exit $status
