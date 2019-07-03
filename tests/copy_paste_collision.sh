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
mkdir tmp
touch tmp/a
echo foo > a
echo bar > b
echo baz > c
ctrlc a
ctrlc b
ctrlc c
cd tmp
content=$(ctrlp)
expected="a already exists in this directory."
echo $content

if [ "$content" = "$expected" ]
then
    echo 1/2 OK
else
    echo 1/2 Failed : "$expected" != "$content"
fi

cd ..

content=$(ctrlp --list)
expected="$(pwd)/a"
if [ "$content" = "$expected" ]
then
    echo 2/2 OK
else
    echo 2/2 Failed : "$expected" != "$content"
fi

#cleanup
rm -rf tmp
rm a
rm b
rm c
ctrlp --reset
