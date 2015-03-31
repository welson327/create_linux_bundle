print("Query " + bookId + ":");
printjson(db.ebook.find({"_id": ObjectId(bookId)}).toArray())

// [bookId] is declared in .sh by --eval
db.ebook.remove({"_id": ObjectId(bookId)})
db.account_booklist.remove({"bookId": bookId})
db.book_rank.remove({"bookId": bookId})
db.removed_book.remove({"bookId": bookId})

print("Remove bookId: " + bookId);

/*
// mongo_id,status is declared in set_status.sh by --eval
db.BACKUP_RESTORE.update(
	{"_id": ObjectId(mongo_id)}, 
	{$set: {"status":status}}
);
*/
