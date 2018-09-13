for f in $(ls); do
    if [ $f != $0 ]; then
        sh $f
    fi
done
