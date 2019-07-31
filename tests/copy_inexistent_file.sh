alias ctrlc=$(pwd)/../ctrlc
alias ctrlp=$(pwd)/../ctrlp

echo Running $0

#setup
ctrlp --reset

#test
touch a
rm a
content=$(ctrlc a)
expected="$(pwd)/a does not exist"

if [ "$content" = "$expected" ]
then
    echo 1/2 OK
else
    echo 1/2 Failed : "$expected" != "$content"
fi

touch a
content=$(ctrlc a && ctrlp --list)
expected="$(pwd)/a"
if [ "$content" = "$expected" ]
then
    echo 2/2 OK
else
    echo 2/2 Failed : "$expected" != "$content"
fi

#cleanup
rm a
ctrlp --reset
