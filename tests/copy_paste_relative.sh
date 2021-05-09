alias ctrl=$(pwd)/../ctrl
status=0

echo Running $0

#setup
ctrl --reset
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
ctrl -C ../a

if [ "$(ctrl --list)" = "`pwd`/../a" ]; then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed : $(ctrl --list) != $(pwd)/a
fi

ctrl -V
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
ctrl --reset
exit $status
