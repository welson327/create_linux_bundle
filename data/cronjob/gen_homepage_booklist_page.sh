#!/bin/bash

check_webservice_cnt() {
	cnt="$(ps aux | grep java | wc -l)"
	echo $cnt
}

curl_genHomepageBooklistPage() {
	port="$1"
	homedir="$2"
	rslt="$(curl localhost:${port}/pus/services/genHomepageBooklistPage?homedir=${homedir})"
	echo "$rslt"
}

gen_hompage_booklist_page() {
	echo ""
	echo ""
	echo "[gen_hompage_booklist_page]"
	
	rslt=""

	if [ -z "$rslt" ]; then 
		homedir="/home/webuser/JservRoot"
		echo "  Try ${homedir} with port 80 ..."
		rslt="$(curl_genHomepageBooklistPage 80 ${homedir})"
	fi
	
	if [ -z "$rslt" ]; then 
		homedir="/home/webuser/HtmlRoot"
		echo "  Try ${homedir} with port 80 ..."
		rslt="$(curl_genHomepageBooklistPage 80 ${homedir})"
	fi

	if [ -z "$rslt" ]; then 
		homedir="/home/webuser/JservRoot"
		echo "  Try ${homedir} with port 8080 ..."
		rslt="$(curl_genHomepageBooklistPage 8080 ${homedir})"
	fi
	
	if [ -z "$rslt" ]; then 
		homedir="/home/webuser/HtmlRoot"
		echo "  Try ${homedir} with port 8080 ..."
		rslt="$(curl_genHomepageBooklistPage 8080 ${homedir})"
	fi

	sleep 1
	echo "$rslt"
}
	
gen_hompage_booklist_page
