#!/bin/bash

echo "========================="
echo "   Service Installer"
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

still_install?() {
	read -e -p "Still install? (y/n)" yesno
	if [ "$yesno" != "y" ]; then
		exit 0
	fi
}

query_install_version() {
	echo "Installation supports following items for you:"
	echo "  (h) --Help--"
	echo "  (1) Production version"
	echo "  (2) Engineer version"
	echo "  (t) Only folder tree"
	read -e -p "Which item to install?(1/2/t): " install_version
	
	case ${install_version} in
		"h" | "H")
			echo "* Official: Install project in [${PROJ_DATA_TOP_PATH}]."
			echo "* Engineer: Install project in [${PROJ_DATA_TOP_PATH}]."
			echo "* Only folder tree: mkdir -p ${PROJ_DATA_TOP_PATH} and its child folders."
			read -e -p "Back to install menu? (y/n)" yesno
			if [ "$yesno" = "y" ]; then
				query_install_version
			else
				exit 0
			fi
			;;
		"1")
			echo "------> Prepare to install [Production] version."
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
	mkdir -p $PROJ_DATA_TOP_PATH
	
	mkdir -p $PROJ_BACKUP_DIR
	mkdir -p $PROJ_CRONJOB_DIR
	mkdir -p $PROJ_ETC_DIR
	mkdir -p $PROJ_SERVICE_DIR
	mkdir -p $PROJ_TEMP_DIR
	mkdir -p $PROJ_WS_DIR
	
	# if [ ! -d $PROJ_WEBUSER_SOFTLINK_DIR ]; then
	# 	mkdir -p $PROJ_WEBUSER_SOFTLINK_DIR
	# fi

	change_permission $PROJ_DATA_TOP_PATH
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
	file="${PROJ_VERSION_FILE}"
	
	echo "" >> $file

	echo "##[ INSTALL ]##" >> $file
	echo "date:$(date +%Y-%m-%d@%H:%M:%S)" >> $file
	echo "version:$(version_get ${BIN_FILE})" >> $file
}

check_service() {
	case ${install_version} in
		*)
			proj="${PROJ_NAME}"
			;;
	esac
	
	if [ "$(curl localhost:80/${proj}/s/helloworld)" = "Hello_World" ]; then 
		echo "true"
	elif [ "$(curl localhost:3000/${proj}/s/helloworld)" = "Hello_World" ]; then 
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
			${PROJ_ETC_DIR}/refresh_website.sh
			;;
		*)
			;;
	esac
}

check_hosts_conf() {
	if [ -f "${PROJ_ETC_DIR}/hosts.conf" ]; then
		read -e -p "${PROJ_ETC_DIR}/hosts.conf is exist! Keep original file? (y/n)" isKeep
		if [ "$isKeep" = "y" ]; then
			echo "Keep original hosts.conf."
			cp -rf ${PROJ_ETC_DIR}/dfs_hosts.conf ${DATA_DIR}/etc
		fi
	fi
}

deploy() {
	# clear /myapp/ws/rails
	rm -rf ${PROJ_DATA_TOP_PATH}/ws/rails
	
	# check_hosts_conf
	
	cp -rf ${DATA_DIR}/* ${PROJ_DATA_TOP_PATH}/
	
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

	# set_crontab
	wait_for_service_ready
	refresh_website
	make_version_file
	change_permission $PROJ_DATA_TOP_PATH
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
