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
content=$(ctrlc a)
expected="$(pwd)/a is already queued for copying"

if [ "$content" = "$expected" ]
then
    echo 1/3 OK
else
    echo 1/3 Failed : "$expected" != "$content"
fi

if [ $(ctrlp --list) = "$(pwd)/a" ]
then
    echo 2/3 OK
else
    echo 2/3 Failed : "$expected" != "$content"
fi

mkdir tmp
cd tmp
ctrlp
content=$(cat a)
expected=foo

if [ "$content" = "$expected" ]; then
    echo 3/3 OK
else
    echo 3/3 Failed : "$expected" != "$content"
fi

#cleanup
cd ..
rm -rf tmp
rm a
ctrlp --reset
