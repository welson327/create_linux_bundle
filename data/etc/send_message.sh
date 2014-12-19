#!/bin/bash

send_message() {
	phoneNumber="$1"
	msg="$2"
	echo "Sending msg to ${phoneNumber}, msg=${msg}"
	curl "http://smexpress.mitake.com.tw:9600/SmSendGet.asp?username=54643825&password=feisu168&dstaddr=${phoneNumber}&dlvtime=2&vldtime=60&smbody=${msg}" \
		-H "Content-Type: text/html; charset=Big5"
}

if [ -z "$1" ]; then
	echo "Argument 1, phone number, required!"
elif [ -z "$2" ]; then
	echo "Argument 2, message, required!"
else
	send_message "$1" "$2"
fi

