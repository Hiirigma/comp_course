for entry in `ls ok/`; do
	echo ok/$entry
    ./app.out ok/$entry
done
