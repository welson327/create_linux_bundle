#!/bin/bash

phoneList=("0933275803" "0933737710" "0939876808" "0931380382" "0920188399")
dailyReportList=("0933275803")

logFile="$1"

send_phone_message() {
	phone="$1"
	msg="[$(hostname)]$2"
	curl "http://smexpress.mitake.com.tw:9600/SmSendGet.asp?username=54643825&password=feisu168&dstaddr=${phone}&dlvtime=2&vldtime=60&smbody=${msg}"
}

send_msg_to_group() {
	msg="$1"
	for phone in ${phoneList[@]}; do
		send_phone_message "$phone" "$msg"
	done
}

latency_check() {
	local latency=0
	local latencyLimit=600 #10mins
	local step=30
	local callback="$1"
	
	while [ "$($callback)" = "FAIL" ]; do
		latency=$(($latency+$step))
		sleep $step
		
		if [ $latency -gt $latencyLimit ]; then
			latency=0
			echo "FAIL"
			break
		fi
	done
}

cb_check_servlet() {
	rslt="$(curl localhost/pus/services/helloworld)"
	
	if [ -z "$rslt" ]; then
		rslt="$(curl localhost:8080/pus/services/helloworld)"
	fi
		
	if [ "$rslt" != "Hello_World" ]; then
		echo "FAIL"
	fi
}

cb_check_cpu() {
	usageLimit=80
	cpu_us=$(top -n1 | head -n5 | grep 'cpu' -i | awk '{print $2}')
	cpu_sy=$(top -n1 | head -n5 | grep 'cpu' -i | awk '{print $3}')
	us=${cpu_us%\%*}
	sy=${cpu_sy%\%*}
	
	# float operation: bc
	total=$(echo "${us}+${sy}" | bc)
	
	# floating compare
	if [ $(echo "$total > $usageLimit" | bc) -eq 1 ]; then
		echo "FAIL"
	fi
}

cb_check_db_conn() {
	connLimit=500
	connFieldName=$(mongostat -n1 | tail -n2 | awk '{print $21}')
	
	if [ "$connFieldName" = "conn" ]; then
		connValue=$(mongostat -n1 | tail -n1 | awk '{print $18}')
		if [ $connValue -gt $connLimit ]; then
			echo "FAIL"
		fi
	fi
}

check_servlet() {
	if [ "$(latency_check cb_check_servlet)" = "FAIL" ]; then
		echo "Servlet_fail"
	fi
}

check_cpu() {
	if [ "$(latency_check cb_check_cpu)" = "FAIL" ]; then
		echo "Cpu%_too_high"
	fi
}

check_db_conn() {
	if [ "$(latency_check cb_check_db_conn)" = "FAIL" ]; then
		echo "Mongo_conn_too_high"
	fi	
}

## main
	sendMsg=""
	
	servletRslt="$(check_servlet)"
	cpuRslt="$(check_cpu)"
	connRslt="$(check_db_conn)"
	
	if [ ! -z "$servletRslt" ]; then
		echo "Servlet NG"
		sendMsg="${sendMsg}${servletRslt},"
	else
		echo "Servlet OK"
	fi

	if [ ! -z "$cpuRslt" ]; then
		echo "CPU useage NG"
		sendMsg="${sendMsg}${cpuRslt},"
	else
		echo "CPU useage OK"
	fi
	
	if [ ! -z "$connRslt" ]; then
		echo "MongoConn NG"
		sendMsg="${sendMsg}${connRslt},"
	else
		echo "MongoConn OK"
	fi
	
	
	
	### send msg
	if [ ! -z "$sendMsg" ]; then
		echo ">>> System Warning: $sendMsg"
		send_msg_to_group "$sendMsg"
	else
		if [ ! -z "$logFile" ]; then
			#echo "[$(date +%Y%m%d@%H:%M:%S)] check service OK." >> /yiabiRoot/logs/${0%*.sh}.log
			echo "[$(date +%Y%m%d@%H:%M:%S)] check service OK." >> $logFile
		fi
	fi
