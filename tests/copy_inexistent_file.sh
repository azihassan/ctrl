alias pastard=$(pwd)/../pastard
status=0

echo Running $0

#setup
pastard -p --reset

#test
touch a
rm a
content=$(pastard -c a)
expected="$(pwd)/a does not exist"

if [ "$content" = "$expected" ]
then
    echo 1/2 OK
else
    echo 1/2 Failed : "$expected" != "$content"
    status=1
fi

touch a
content=$(pastard -c a && pastard -p --list)
expected="$(pwd)/a"
if [ "$content" = "$expected" ]
then
    echo 2/2 OK
else
    echo 2/2 Failed : "$expected" != "$content"
    status=1
fi

#cleanup
rm a
pastard -p --reset

exit $status
