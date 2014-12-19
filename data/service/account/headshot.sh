#!/bin/bash

source "/yiabi/path.sh"

account="$1"
tmpCoverName="$2"
LOGFILE="${TOMCAT_DIR}/logs/catalina.out"

get_ext_name() {
	filename="$1"
	echo "${filename##*.}"
}

cp_files_to_account_dir() {
	initChar="${account:0:1}"
	output_dir="${YIABI_WEBUSER_POSTTEMP_DIR}"

	if [ $tmpCoverName != "null" ]; then
	
		imgPath="${YIABI_TEMP_DIR}/${tmpCoverName}"

		if [ -f ${imgPath} ]; then
			#ext="$(get_ext_name $tmpCoverName)"
			echo "[server script] cp -f ${imgPath} ${output_dir}/${account}.jpg" >> $LOGFILE
			cp -f ${imgPath} ${output_dir}/${account}.jpg
		fi	
	fi
}

cp_files_to_account_dir
