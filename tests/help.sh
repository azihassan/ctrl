alias pastard="$(pwd)/../pastard"
status=0

echo Running $0

#Passing -h with -p or -c or -C should display the help of the given mode
content=$(pastard -p -h | head -1)
expected="Pastard - ctrlp"

if [ "$content" = "$expected" ]; then
    echo 1/2 OK
else
    status=1
    echo 1/2 Failed
    echo Expected :
    echo "$expected"
    echo Actual :
    echo "$content"
fi

#Passing -h without passing a mode should display the supported modes
content=$(pastard -h | head -1)
expected="Pastard"

if [ "$content" = "$expected" ]; then
    echo 2/2 OK
else
    status=1
    echo 2/2 Failed
    echo Expected :
    echo "$expected"
    echo Actual :
    echo "$content"
fi
exit $status
