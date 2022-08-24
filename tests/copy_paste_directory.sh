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
mkdir -p folder/nested
echo bar > folder/nested/b
tree folder

ctrl -C folder
mkdir tmp
cd tmp
logs=$(ctrl -V)
expected_logs="[OK] $(pwd)/folder"

if diff -r -q ../folder ./folder; then
    echo '1/2 OK'
else
    echo '1/2 Failed diff'
    status=1
fi


if [ "$logs" = "$expected_logs" ]; then
    echo 2/2 OK
else
    echo 2/2 Failed
    status=1
fi

#cleanup
cd ..
rm -rf tmp
rm -rf folder
ctrl --reset
exit $status
