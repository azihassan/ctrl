alias ctrlc=$(pwd)/../ctrlc
alias ctrlp=$(pwd)/../ctrlp

echo Running $0

#setup
ctrlp --reset
if [ -f a ]; then
    rm a
fi

#test
echo foo > a
ctrlc a

if [ "$(ctrlp --list)" = "$(pwd)/a" ]; then
    echo 1/2 OK
else
    echo 1/2 Failed : $(ctrlp --list) != $(pwd)/a
fi

ctrlp --reset

if [ "$(ctrlp --list)" = "" ]; then
    echo 2/2 OK
else
    echo 2/2 Failed : $(ctrlp --list) is not empty
fi

#cleanup
rm a
