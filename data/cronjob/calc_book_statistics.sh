#!/bin/bash

calc_book_statistics() {
	echo "Try 8080 port: curl localhost:8080/pus/services/calcBookStatistics"
	rslt="$(curl localhost:8080/pus/services/calcBookStatistics)"

	sleep 1
	echo "$rslt"
}
	
calc_book_statistics
