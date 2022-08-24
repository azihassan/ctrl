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
mkdir folder
echo foo > folder/a
mkdir folder/nested
echo bar > folder/nested/b
ctrl -C folder
mkdir tmp
cd tmp
logs=$(ctrl -V)
expected_logs="[OK] $(pwd)/folder"

content=$(cat folder/a)
expected=foo

if [ "$content" = "$expected" ]; then
    echo 1/3 OK
else
    echo 1/3 Failed
    status=1
fi

content=$(cat folder/nested/b)
expected=bar

if [ "$content" = "$expected" ]; then
    echo 2/3 OK
else
    echo 2/3 Failed
    status=1
fi

if [ "$logs" = "$expected_logs" ]; then
    echo 3/3 OK
else
    echo 3/3 Failed
    status=1
fi

#cleanup
cd ..
rm -rf tmp
rm -rf folder
ctrl --reset
exit $status
