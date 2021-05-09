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
mkdir tmp
cd tmp
ctrl -V
content=$(cat a)
expected=foo

if [ "$content" = "$expected" ]; then
    echo 1/1 OK
else
    echo 1/1 Failed
    status=1
fi

#cleanup
cd ..
rm -rf tmp
rm a
ctrl --reset
exit $status
