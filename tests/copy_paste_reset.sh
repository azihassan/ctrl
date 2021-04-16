alias ctrl=$(pwd)/../ctrl
status=0

echo Running $0

#setup
ctrl --reset
if [ -f a ]; then
    rm a
fi

#test
echo foo > a
ctrl -C a

if [ "$(ctrl --list)" = "$(pwd)/a" ]; then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed : $(ctrl --list) != $(pwd)/a
fi

ctrl --reset

if [ "$(ctrl --list)" = "" ]; then
    echo 2/2 OK
else
    status=1
    echo 2/2 Failed : $(ctrl --list) is not empty
fi

#cleanup
rm a
exit $status
