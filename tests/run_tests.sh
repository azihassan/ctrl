for f in $(ls *.sh); do
    if [ $f != $0 ]; then
        sh $f
    fi
done
