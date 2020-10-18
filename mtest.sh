for entry in `ls course/ok/`; do
	echo course/ok/$entry
    ./app.out course/ok/$entry
done
