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
echo old > tmp/a
echo new > a
ctrlc a
cd tmp
content=$(ctrlp)
expected="a already exists in this directory."

if [ "$content" = "$expected" ]
then
    echo 1/3 OK
else
    echo 1/3 Failed : "$expected" != "$content"
fi

ctrlp --force
content=$(cat a)
expected="new"
echo $content

if [ "$content" = "$expected" ]
then
    echo 2/3 OK
else
    echo 2/3 Failed : "$expected" != "$content"
fi

cd ..
content=$(ctrlp --list)
expected=""
if [ "$content" = "$expected" ]
then
    echo 3/3 OK
else
    echo 3/3 Failed : "$expected" != "$content"
fi

#cleanup
rm -rf tmp
rm a
ctrlp --reset
