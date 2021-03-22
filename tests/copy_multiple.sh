alias pastard=$(pwd)/../pastard
status=0

echo Running $0

#setup
pastard -p --reset

#test
touch a b c
content=$(pastard -c a b c && pastard -p --list)
expected="$(pwd)/a
$(pwd)/b
$(pwd)/c"
if [ "$content" = "$expected" ]
then
    echo 1/1 OK
else
    status=1
    echo 1/1 Failed
    echo Expected :
    echo "$expected"
    echo Actual :
    echo "$content"
fi

#cleanup
rm a b c
pastard -p --reset
exit $status
