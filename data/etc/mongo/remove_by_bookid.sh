#!/bin/bash

MONGO_BIN="$(which mongo)"
DB="puppy"

remove_book_by_bookid() {
	bookId="$1"
	#js="/yiabiRoot/etc/mongo/remove_by_bookid.js"
	js="remove_by_bookid.js"
	
	if [ -f $js ]; then
		echo "$MONGO_BIN --quiet localhost:27017/$DB $js --eval \"var bookId = \"$bookId\";\""
		$MONGO_BIN --quiet localhost:27017/$DB $js --eval "var bookId = \"$bookId\";"
	else
		echo "$js not found!!"
	fi
}


if [ -z "$1" ]; then
	echo "Argument 1, bookId, required."
else
	echo "Mongo @ ${MONGO_BIN}"
	remove_book_by_bookid "$1"
	
	echo "----------> Please invalidate your cache manully! 881~"
	echo ""
fi

