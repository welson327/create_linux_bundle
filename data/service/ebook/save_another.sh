#!/bin/bash

source "/yiabi/path.sh"
#source "$YIABI_SERVICE_DIR/util.sh"

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

save_another() {
	initChar="${account:0:1}"
	output_dir="${YIABI_WEBUSER_POSTTEMP_DIR}"
	#output_dir="${YIABI_WEBUSER_DIR}/$(to_lowercase $initChar)/$account"

	#if [ $tmpTxtName != "null" ]; then
	#	if [ -f ${YIABI_TEMP_DIR}/${tmpTxtName} ]; then
	#		ext="$(get_ext_name $tmpTxtName)"
	#		echo "[server script] mv -f ${YIABI_TEMP_DIR}/${tmpTxtName} ${output_dir}/${bookId}.${ext}" >> $LOGFILE
	#		mv -f ${YIABI_TEMP_DIR}/${tmpTxtName} ${output_dir}/${bookId}.${ext}
	#	fi
	#fi

	if [ $tmpCoverName != "null" ]; then

		ext="$(get_ext_name $tmpCoverName)"
		outputImg="${output_dir}/${bookId}_cover.${ext}"
		
		case "$tmpCoverType" in
			"1") # upload to temp
				inputImg="${YIABI_TEMP_DIR}/${tmpCoverName}"
				;;
			"2") # free cover
				inputImg="${YIABI_SERVICE_DIR}/ebook/cover/${tmpCoverName}"
				;;
			*) # default
				inputImg="${output_dir}/${tmpCoverName}"
				;;
		esac


		echo "[server script] cp -f ${inputImg} ${outputImg}" >> $LOGFILE
		cp -f ${inputImg} ${outputImg}
		
	fi
}

save_another
