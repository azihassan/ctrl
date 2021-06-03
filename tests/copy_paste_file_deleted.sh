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
ctrl -C a
rm a

if [ "$(ctrl --list)" = "$(pwd)/a" ]; then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed : $(ctrl --list) != $(pwd)/a
fi

mkdir tmp
cd tmp

content=$(ctrl -V)
cd ..
expected="[Error] $(pwd)/a no longer exists."

if [ "$content" = "$expected" ]; then
    echo 2/2 OK
else
    status=1
    echo 2/2 Failed : "$content" != "$expected" 
fi

#cleanup
rm -rf tmp
ctrl --reset
exit $status
