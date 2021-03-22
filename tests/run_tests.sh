status=0
for f in $(ls *.sh); do
    if [ $f != $0 ]; then
        sh $f || status=1
    fi
done
exit $status
