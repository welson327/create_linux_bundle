#!/bin/bash

# ===============================================================
# Purpose:		parse path.sh
# Parameter:	
# Return:
# Remark:		use 'readlink' to get fullpath
# Author:
# ===============================================================
get_path_sh() {
	currdir="$(dirname $(readlink -f $0))"
	path_sh_path="$(dirname $(dirname $currdir))/path.sh"
	echo "$path_sh_path"
}

source "$(get_path_sh)"
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

export TMPDIR=`mktemp -d /tmp/restored.XXXXXX`
dbname="puppy"
restored_data="$1"

print_title() {
	echo ""
	echo ""
	echo ""
	echo "=====> $1"
}

prepare_data() {
	print_title "tar -zxf ${restored_data} -C ${TMPDIR}"
	tar -zxf ${restored_data} -C ${TMPDIR}
}

restore_db() {
	cd /
	
	# drop db
	print_title "db.dropDatabase()"
	mongo ${dbname} --eval "db.dropDatabase()"
	
	print_title "tar -zxf ${TMPDIR}/puppy.tar.gz -C ${TMPDIR}"
	tar -zxf ${TMPDIR}/puppy.tar.gz -C ${TMPDIR}
	
	print_title "mongorestore -h 127.0.0.1 -d "${dbname}" ${TMPDIR}/${dbname}"
	mongorestore -h 127.0.0.1 -d "${dbname}" ${TMPDIR}/${dbname}
	
	cd -
}

restore_webuser() {
	cd /
  
	print_title "tar -zxf ${TMPDIR}/webuser.tar.gz -C ${YIABI_DATA_TOP_PATH}"
	tar -zxf ${TMPDIR}/webuser.tar.gz -C ${YIABI_DATA_TOP_PATH}
  
	print_title "ln -sf /yiabi /yiabiweb"
	ln -sf /yiabi /yiabiweb # ???????????

	print_title "chown/chmod /yiabiweb"
	chown -R webuser:webuser /yiabiweb
	chmod -R 777 /yiabiweb
  
	cd -
}


remove_prepared_data() {
	print_title "rm -rf ${TMPDIR}"
	rm -rf ${TMPDIR}
}

append_log() {
	file=${YIABI_VERSION_FILE}
	
	echo "" >> $file
	echo "##[ RESTORE ]##" >> $file
	echo "date:$(date +%Y-%m-%d@%H:%M:%S)" >> $file
	echo "version:${restored_data}" >> $file
}

refresh_website() {
	print_title "${YIABI_ETC_DIR}/refresh_website.sh"
	${YIABI_ETC_DIR}/refresh_website.sh
}


if [ -z "${restored_data}" ]; then
	echo "Argument 1 not found! Please input a [restored_data]"
	exit 0
else
	if [ ! -f "${restored_data}" ]; then
		echo "$restored_data not found!"
		exit 0
	fi
fi

## main
echo "In order to double confirm your action is exactly,"
read -p "Please input the hostname: " inputHostName
if [ "${inputHostName}" != "$(hostname)" ]; then
	echo "Sorry! The host of this machine is '$(hostname)', but you want to retore '${inputHostName}'. Please try again."
else
	prepare_data
	restore_webuser
	#restore_db
	remove_prepared_data
	
	append_log
	refresh_website
	
	print_title "Restore ${restored_data} successfully!~ 881~"
	echo ""
	echo ""
fi
