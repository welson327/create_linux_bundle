#!/bin/bash

# ===============================================================
# Purpose:		parse path.sh
# Parameter:	
# Return:
# Remark:		use 'readlink' to get fullpath
# Author:
# ===============================================================
#get_path_sh() {
#	currdir="$(dirname $(readlink -f $0))"
#	path_sh_path="$(dirname $(dirname $currdir))/path.sh"
#	echo "$path_sh_path"
#}

source "/yiabi/path.sh"
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

account="$1"
bookId="$2"
tmpTxtName="$3"
tmpCoverName="$4"
tmpCoverType="$5"
LOGFILE="${TOMCAT_DIR}/logs/catalina.out"

get_ext_name() {
	filename="$1"
	echo "${filename##*.}"
}

cp_files_to_account_dir() {
	initChar="${account:0:1}"
	output_dir="${YIABI_WEBUSER_POSTTEMP_DIR}"
	#output_dir="${YIABI_WEBUSER_DIR}/$(to_lowercase $initChar)/$account"

	if [ $tmpTxtName != "null" ]; then
		if [ -f ${YIABI_TEMP_DIR}/${tmpTxtName} ]; then
			ext="$(get_ext_name $tmpTxtName)"
			echo "[server script] cp -f ${YIABI_TEMP_DIR}/${tmpTxtName} ${output_dir}/${bookId}.${ext}" >> $LOGFILE
			cp -f ${YIABI_TEMP_DIR}/${tmpTxtName} ${output_dir}/${bookId}.${ext}
		fi
	fi
	if [ $tmpCoverName != "null" ]; then
	
		case "$tmpCoverType" in
			"1") # upload to temp
				imgHome="${YIABI_TEMP_DIR}"
				;;
			"2") # free cover
				imgHome="${YIABI_SERVICE_DIR}/ebook/cover"
				;;
			*) # default
				;;
		esac
	
		imgPath="${imgHome}/${tmpCoverName}"

		if [ -f ${imgPath} ]; then
			ext="$(get_ext_name $tmpCoverName)"
			echo "[server script] cp -f ${imgPath} ${output_dir}/${bookId}_cover.${ext}" >> $LOGFILE
			cp -f ${imgPath} ${output_dir}/${bookId}_cover.${ext}
		fi	
	fi
}

cp_files_to_account_dir
