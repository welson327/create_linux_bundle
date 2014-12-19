#!/bin/bash

echo "========================="
echo "    Service Installer"
echo "========================="

rm -rf /tmp/selfextract.*
BIN_FILE="$0"

export TMPDIR=`mktemp -d /tmp/selfextract.XXXXXX`

echo "Extract $BIN_FILE ..."
ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $BIN_FILE`
tail -n+$ARCHIVE $BIN_FILE | tar xzv -C $TMPDIR >/dev/null 2>/dev/null

#currdir="$(dirname $(readlink -f $0))"
CRONTAB_FILE="/etc/crontab"
DATA_DIR="${TMPDIR}/data"
echo "DATA_DIR=${DATA_DIR}"

source "${DATA_DIR}/path.sh"

install_version=""
restful_site="localhost:80/pus"

# ============================================================
# Purpose: 		get ver. number bin BIN name
# Parameter: 	
# Return:     input: abcd-1.5.6.bin, output:1.5.6
# Remark:		  Format must be xxxxx-1.2.3.bin, where xxxxx should be alnum or underline
# Author:		  Welson
# ============================================================
version_get() {
	bin_name="$1"
	ver=$(echo ${bin_name} | cut -d'-' -f2 | sed 's/\([1-9\.]*\)\.bin/\1/')
	echo "$ver"
}

print_red() {
	rslt="$1"
	printf "%*s%s\n" "$(tput cols)" "[$(tput setaf 1)${rslt}$(tput sgr0)]"
}
print_green() {
	rslt="$1"
	printf "%*s%s\n" "$(tput cols)" "[$(tput setaf 2)${rslt}$(tput sgr0)]"
}

is_windows() {
	# if os can run this script, almost is using cygwin
	if [[ "$OSTYPE" == *win* ]]; then 
		echo "true"
	else
		echo "false"
	fi
}

still_install?() {
	read -e -p "Still install? (y/n)" yesno
	if [ "$yesno" != "y" ]; then
		exit 0
	fi
}

query_install_version() {
	echo "Installation supports following items for you:"
	echo "  (h) --Help--"
	echo "  (1) Official version"
	echo "  (2) Engineer version"
	echo "  (t) Only folder tree"
	read -e -p "Which item to install?(1/2/t): " install_version
	
	case ${install_version} in
		"h" | "H")
			echo "* Official: Install project in [${YIABI_DATA_TOP_PATH}]."
			echo "* Engineer: Install project in [${YIABI_DATA_TOP_PATH}]."
			echo "* Only folder tree: mkdir -p ${YIABI_DATA_TOP_PATH} and its child folders."
			read -e -p "Back to install menu? (y/n)" yesno
			if [ "$yesno" = "y" ]; then
				query_install_version
			else
				exit 0
			fi
			;;
		"1")
			echo "------> Prepare to install [Official] version."
			;;
		"t")
			echo "------> Prepare to mkdir folder tree."
			create_init_folder
			exit 0
			;;
		*)
			echo "------> Prepare to install [Engineer] version."
			;;
	esac
	echo ""
	echo ""
	echo ""	
}

change_permission() {
	dir="$1"
	chmod -R 777 $dir
	chown -R webuser:webuser $dir
}

check_os() {
	os="$(uname)"
	echo "Your OS is [${os}]"
	
	case "$os" in
		Linux)
			;;
		Darwin)
			echo "Please Make sure ${TOMCAT_WAR_DIR} and ${HTML_WAR_DIR} are exist!"
			still_install?
			;;
		*)
			;;
	esac
}

check_env() {
	cnt=$(grep 'passenger' /opt/nginx/conf/nginx.conf -r  | wc -l)
	if [ $cnt -gt 0 ]; then
		print_green "Check [passenger] OK."
	else
		echo "!!!!!!!!!!!!!!!!!!!!!"
		echo "'passenger' not found in nginx.conf!"
		still_install?
	fi
}

check_dependency() {
	local isSomethingNotFound="false"
	
	echo "===================================================="
	echo "Check Dependency:"
	
	echo "  Check [curl]:"
	if [ -z "$(which curl)" ]; then
		isSomethingNotFound="true"
		print_red "NOT FOUND"
	else
		print_green "OK"
	fi
	
	echo "  Check [ruby]:"
	if [ -z "$(which ruby)" ]; then
		isSomethingNotFound="true"	
		print_red "NOT FOUND"
	else
		print_green "OK"
	fi
	
	echo "  Check [json.rb]:"
	if [ -z "$(locate 'json.rb')" ]; then
		isSomethingNotFound="true"	
		print_red "NOT FOUND"
	else
		print_green "OK"
	fi

	if [ "$isSomethingNotFound" = "true" ]; then
		echo "------------------------------"
		echo "!!!!!!!!!!!!!!!!!!!!!"
		echo "Some dependency not found in your system!"
		still_install?
	fi
	echo "===================================================="
}

create_init_folder() {
	if [ ! -d $YIABI_DATA_TOP_PATH ]; then
		mkdir -p $YIABI_DATA_TOP_PATH
	fi
	
	ln -nsf $YIABI_DATA_TOP_PATH /yiabiRoot
	chown -R webuser:webuser /yiabiRoot
	change_permission $YIABI_DATA_TOP_PATH
	
	
	mkdir -p $YIABI_BACKUP_DIR
	mkdir -p $YIABI_CRONJOB_DIR
	mkdir -p $YIABI_ETC_DIR
	#mkdir -p $YIABI_EBOOKLIB_DIR

	# mapdb
	# mkdir -p $YIABI_BROWSING_COUNTER_DIR
	# mkdir -p $YIABI_COUNT24HR_DIR
	# mkdir -p $YIABI_CUTTING_COUNTER_DIR

	mkdir -p $YIABI_SERVICE_DIR
	mkdir -p $YIABI_TEMP_DIR

	mkdir -p $YIABI_WEBSERVICE_DIR

	# webuser
	mkdir -p $YIABI_WEBUSER_DIR
	# mkdir -p $YIABI_WEBUSER_DIR/cache
	# mkdir -p $YIABI_WEBUSER_DIR/doclib/html_converted
	# mkdir -p $YIABI_WEBUSER_DIR/doclib/log
	# mkdir -p $YIABI_WEBUSER_DIR/doclib/upload_doc
	# mkdir -p $YIABI_WEBUSER_DIR/doclib/zip_temp
	# mkdir -p $YIABI_WEBUSER_POSTTEMP_DIR
	# mkdir -p $YIABI_WEBUSER_ZIPSEND_DIR
	for ch in {a..z}; do
		mkdir -p $YIABI_WEBUSER_DIR/$ch
	done
	for dd in {0..9}; do
		mkdir -p $YIABI_WEBUSER_DIR/$dd
	done
	
	if [ ! -d $YIABI_WEBUSER_SOFTLINK_DIR ]; then
		mkdir -p $YIABI_WEBUSER_SOFTLINK_DIR
	fi
}

has_cronjob() {
	task_tag="$1"
	
	if [ $(grep "$task_tag" "$CRONTAB_FILE" -nHr | wc -l) -gt 0 ]; then
		echo "true"
	else
		echo "false"
	fi
}

set_crontab() {
	case ${install_version} in
		"1" | "2") # Official|Engineer
				echo "cp -f ${DATA_DIR}/etc/crontab /etc/crontab"
				cp -f ${DATA_DIR}/etc/crontab /etc/crontab
			;;
		*)
			;;
	esac
}

make_version_file() {
	file="${YIABI_VERSION_FILE}"
	
	echo "" >> $file

	echo "##[ INSTALL ]##" >> $file
	echo "date:$(date +%Y-%m-%d@%H:%M:%S)" >> $file
	echo "version:$(version_get ${BIN_FILE})" >> $file
}

check_service() {
	case ${install_version} in
		*)
			proj="pus"
			;;
	esac
	
	if [ "$(curl localhost:80/${proj}/services/helloworld)" = "Hello_World" ]; then 
		echo "true"
	elif [ "$(curl localhost:3000/${proj}/services/helloworld)" = "Hello_World" ]; then 
		echo "true"
	else
		echo "false"
	fi
}

wait_for_service_ready() {
	sleep 3
	cnt=0
	isReady="true"
	
	while [ "$(check_service)" = "false" ]; do
		echo "Wait for service ready ..."
		cnt=$(($cnt+1))
		sleep 3
		
		if [ $cnt -gt 10 ]; then
			isReady="false"
			break
		fi
	done
	
	echo ""
	echo ""
	if [ "$isReady" = "true" ]; then
		print_green "Service is ready"
	else
		print_red "Service is not ready!!! (timeout)"
	fi
	echo ""
	echo ""
}

refresh_website() {
	case ${install_version} in
		"1" | "2")
			${YIABI_ETC_DIR}/refresh_website.sh
			;;
		*)
			;;
	esac
}

check_dfs_hosts_conf() {
	if [ -f "${YIABI_ETC_DIR}/dfs_hosts.conf" ]; then
		read -e -p "${YIABI_ETC_DIR}/dfs_hosts.conf is exist! Keep original file? (y/n)" isKeep
		if [ "$isKeep" = "y" ]; then
			echo "Keep original dfs_hosts.conf."
			cp -rf ${YIABI_ETC_DIR}/dfs_hosts.conf ${DATA_DIR}/etc
		fi
	fi
}

deploy() {
	# clear /yiabi/ws/rails
	rm -rf ${YIABI_DATA_TOP_PATH}/ws/rails
	
	# check_dfs_hosts_conf
	
	cp -rf ${DATA_DIR}/* ${YIABI_DATA_TOP_PATH}/
	
	if [ -d "${DATA_DIR}/rails" ]; then
		case ${install_version} in
			"1") # official
				echo "------> Copy official-version data ..."
				;;				
			*)
				echo "------> Copy engineer-version data ..."
				;;
		esac
	fi

	set_crontab

	wait_for_service_ready
	
	#deploy_chromestore_certification
	refresh_website
	
	make_version_file

	change_permission $YIABI_DATA_TOP_PATH
}

clear_tmp() {
	rm -rf $TMPDIR
}


## main
check_env
check_dependency
query_install_version

create_init_folder
deploy
clear_tmp


echo ""
echo ""
echo ""
echo "Install completed. 881~"
exit 0

###############################################
__ARCHIVE_BELOW__
