alias ctrlc=$(pwd)/../ctrlc
alias ctrlp=$(pwd)/../ctrlp

echo Running $0

#setup
ctrlp --reset

#test
touch a b c
content=$(ctrlc a b c && ctrlp --list)
expected="$(pwd)/a\n$(pwd)/b\n$(pwd)/c"
if [ "$content" = *"$expected" ]
then
    echo 1/1 OK
else
    echo 1/1 Failed
    echo Expected : "$expected"
    echo Actual : "$content"
fi

#cleanup
rm a b c
ctrlp --reset

