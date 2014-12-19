#!/bin/bash

#phoneList=("0933275803" "0933737710" "0939876808" "0931380382" "0920188399")
PORT="80"

check_port() {
	cnt="$(netstat -lntp | grep 8080 | wc -l)"
	if [ "$cnt" -gt 0 ]; then
		PORT="8080"
	fi
}

check_suspend() {
	#phoneList=""
	#for phone in ${phoneList[@]}; do
	#	phoneList="${phoneList}:${phone}"
	#done
	
	# 0933275803:welson
	# 0933737710:Bryan
	# 0920188399:Bryan
	# 0953725510:Bruce
	# 0939238747:Ason
	# 0935822182:Kila
	
	phoneList="0933275803:0953725510:0939238747:0935822182"
	curl localhost:${PORT}/pus/services/checkConvServer?phoneList=${phoneList}
}


check_port
check_suspend
