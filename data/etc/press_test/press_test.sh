#!/bin/bash

cnt=0
MAX=100000000

run_test() {
	./task.sh
}

while true; do
	cnt=$(($cnt+1))
	
	echo "Test cnt: ${cnt}"
	run_test &

	sleep 0.1

	if [ $cnt -ge $MAX ]; then
		echo "Scheduling Cnt > $MAX, end scheduling."
		break
	fi
done
