alias ctrlc=$(pwd)/../ctrlc
alias ctrlp=$(pwd)/../ctrlp

rm -rf ~/.config/pastard

echo Running $0

#setup
touch a

#test
content=$(ctrlc a && ctrlp --list)
expected="$(pwd)/a"

if [ -f ~/.config/pastard/clipboard ]; then
    echo 1/2 OK
else
    echo 1/2 Failed : clipboard not created on first run
fi

if [ "$content" = "$expected" ]; then
    echo 2/2 OK
else
    echo 2/2 Failed
    echo Expected :
    echo "$expected"
    echo Actual :
    echo "$content"
fi

#cleanup
rm a
ctrlp --reset
