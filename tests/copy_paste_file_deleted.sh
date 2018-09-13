alias ctrlc=$(pwd)/../ctrlc
alias ctrlp=$(pwd)/../ctrlp

echo Running $0

#setup
ctrlp --reset
if [ -f tmp ]; then
    rm -rf tmp
fi

if [ -f a ]; then
    rm a
fi

#test
echo foo > a
ctrlc a
rm a

if [ "$(ctrlp --list)" = "$(pwd)/a" ]; then
    echo 1/2 OK
else
    echo 1/2 Failed : $(ctrlp --list) != $(pwd)/a
fi

mkdir tmp
cd tmp

content=$(ctrlp)
cd ..
expected="$(pwd)/a no longer exists."

if [ "$content" = "$expected" ]; then
    echo 2/2 OK
else
    echo 2/2 Failed : "$content" != "$expected" 
fi

#cleanup
rm -rf tmp
ctrlp --reset
