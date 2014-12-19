#!/bin/bash

source "/yiabi/path.sh"
source "$YIABI_SERVICE_DIR/account/account_api.sh"

account="$1"
nickname="$2"
mobilephone="$3"
level="$4"
adminToken="$5"

is_email_format() {
	if [[ "$1" == *@* ]]; then 
		echo "true"; 
	else
		echo "false"
	fi
}

register() {
	TIMEOUT_CMD="--connect-timeout 10"
	
	account="$1"
	nickname="$2"
	mobile="$3"
	level="$4"
	adminToken="$5"
	
	echo "try register ...."
	echo "[$account] [$nickname] [$mobilephone] [$level] [$adminToken]"
	
	rslt="$(\
		curl -s -X POST localhost/pus/services/register \
		-H "content-type: application/json" \
		-d "{ \
			\"account\":\"$account\", \
			\"nickname\":\"$nickname\", \
			\"mobile\":\"$mobile\", \
			\"level\":$level, \
			\"password\":\"yiabi1234\", \
			\"adminToken\":\"$adminToken\" \
		}" \
		$TIMEOUT_CMD \
		)"
	
	if [ -z "$rslt" ]; then
		rslt="$(\
			curl -s -X POST localhost:8080/pus/services/register \
			-H "content-type: application/json" \
			-d "{ \
				\"account\":\"$account\", \
				\"nickname\":\"$nickname\", \
				\"mobile\":\"$mobile\", \
				\"level\":$level, \
				\"password\":\"yiabi1234\", \
				\"adminToken\":\"$adminToken\" \
			}" \
			$TIMEOUT_CMD \
			)"
	fi
	echo "$rslt"			
}


# main
if [ -z "$account" ]; then
	echo "Four arguments required. [1]email, (2)nickname, (3)mobilephone, (4)level, (5)adminToken"
elif [ -z "$nickname" ]; then
	echo "Four arguments required. (1)email, [2]nickname, (3)mobilephone, (4)level, (5)adminToken"
#elif [ -z "$mobilephone" ]; then
#	echo "Four arguments required. (1)email, (2)nickname, [3]mobilephone, (4)level, (5)adminToken"
elif [ -z "$level" ]; then
	echo "Four arguments required. (1)email, (2)nickname, (3)mobilephone, [4]level, (5)adminToken"
elif [ -z "$adminToken" ]; then
	echo "Four arguments required. (1)email, (2)nickname, (3)mobilephone, (4)level, [5]adminToken"
else
	
	register "$account" "$nickname" "$mobilephone" "$level" "$adminToken"
fi
