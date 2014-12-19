#!/bin/bash

account="yiabitester@yiabi.com"
password="yiabi1234"
host="http://210.242.73.143"
port="80"
TIMEOUT_CMD="--connect-timeout 10"
conf="test.conf"

load_config() {
	while read line; do
		echo "line = $line"
		k="$(echo $line | cut -d':' -f1)"
		v="${line#*:}"
		case "$k" in
			host)
				host="$v"
				;;
			port)
				port="$v"
				;;
			account)
				account="$v"
				;;
			password)
				password="$v"
				;;
			*)
				;;
		esac
	done < "$conf"
	
	echo "----------------------------------------"
	echo "Load config:"
	echo "  host => ${host}"
	echo "  port => ${port}"
	echo "  account => ${account}"
	echo "  password => ${password}"
	echo "----------------------------------------"
}

login() {
	rslt="$(\
		curl -s -X POST ${host}:${port}/pus/services/login \
		-H "content-type: application/json" \
		-d "{ \
			\"account\":\"$1\", \
			\"password\":\"$2\", \
		}" \
		$TIMEOUT_CMD \
		)"
		
	echo "$rslt"
}

getCuttingList() {
	length=20
	offset=$(($RANDOM%50*$length))
	rslt="$(\
		curl -s -X POST ${host}:${port}/pus/services/getCuttingList \
		-H "content-type: application/json" \
		-d "{ \
			\"offset\":$offset, \
			\"length\":$length, \
		}" \
		$TIMEOUT_CMD \
		)"
	echo "$rslt"
}

getHomepage() {
	curl -s -X GET ${host}:${port}/pus/services/getSpecificList \
	-H "content-type: application/json"
}
getBookStatistics() {	
	curl -s -X GET ${host}:${port}/pus/services/getBookStatistics \
	-H "content-type: application/json"
}

getBookShelf() {
	accessToken="$1"

	rslt="$(\
		curl -s -X POST ${host}:${port}/pus/services/getBookShelf \
		-H "content-type: application/json" \
		-d "{ \
			\"accessToken\":\"$accessToken\", \
			\"obtainType\":\"100\", \
		}" \
		$TIMEOUT_CMD \
		)"
		
	echo "$rslt"
}

searchAll() {
	keyword=$(uuidgen)
	keyword=${keyword:0:2}

	curl -s -X POST ${host}:${port}/pus/EBookServlet2/searchAll \
	-H "content-type: application/json" \
	-d '{"offset":"0","length":"30","keyword":"'${keyword}'","searchType":["name"]}'
}

readBook() {
	bookId="53ec63950cf27bda623fc52d"
	curl http://www.yiabi.com.tw/pus/pages/product_info_c2c_page.jsp?bookId=${bookId}\&p=1\&sm=0\&bs=eb
}

## main
# bug about global/local variable
#load_config

rslt=$(login "$account" "$password")
echo "/login => ${rslt:0:100} ..."
rslt=$(getCuttingList)
echo "/getCuttingList => ${rslt:0:200} ..."
rslt=$(getHomepage)
echo "/getSpecificList => ${rslt:0:100} ..."
rslt=$(getBookStatistics)
echo "/getBookStatistics => ${rslt:0:100} ..."
rslt=$(searchAll)
echo "/searchAll => ${rslt:0:100} ..."
rslt=$(readBook)
echo "/readBook => ${rslt:0:100} ..."
echo ""
