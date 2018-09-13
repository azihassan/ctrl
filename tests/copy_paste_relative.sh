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
mkdir tmp
cd tmp
ctrlc ../a

#if [ "$(ctrlp --list)" = "$(readlink `pwd`/../a)" ]; then
if [ "$(ctrlp --list)" = "`pwd`/../a" ]; then
    echo 1/2 OK
else
    echo 1/2 Failed : $(ctrlp --list) != $(pwd)/a
fi

ctrlp
content=$(cat a)
expected=foo

if [ "$content" = "$expected" ]; then
    echo OK
else
    echo Failed
fi

#cleanup
cd ..
rm -rf tmp
rm a
ctrlp --reset
