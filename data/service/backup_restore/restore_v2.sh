#!/bin/bash

source "/myapp/path.sh"

export TMPDIR=`mktemp -d /tmp/restored.XXXXXX`
dbname="puppy"
restored_data="$1"
restored_item=""

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

restore_ebooklib() {
	cd /
	print_title "tar -zxf ${TMPDIR}/ebooklib.tar.gz -C ${PROJ_DATA_TOP_PATH}"
	tar -zxf ${TMPDIR}/ebooklib.tar.gz -C ${PROJ_DATA_TOP_PATH}
	cd -
}

restore_mapdb() {
	cd /
	print_title "tar -zxf ${TMPDIR}/mapdb.tar.gz -C ${PROJ_DATA_TOP_PATH}"
	tar -zxf ${TMPDIR}/mapdb.tar.gz -C ${PROJ_DATA_TOP_PATH}
	cd -
}

restore_webuser() {
	cd /
  
	print_title "tar -zxf ${TMPDIR}/webuser.tar.gz -C ${PROJ_DATA_TOP_PATH}"
	tar -zxf ${TMPDIR}/webuser.tar.gz -C ${PROJ_DATA_TOP_PATH}
  
	#print_title "ln -sf /yiabi /yiabiweb"
	#ln -sf /yiabi /yiabiweb # ???????????

	#print_title "chown/chmod /yiabiweb"
	#chown -R webuser:webuser /yiabiweb
	#chmod -R 777 /yiabiweb
  
	cd -
}

remove_prepared_data() {
	print_title "rm -rf ${TMPDIR}"
	rm -rf ${TMPDIR}
}

append_log() {
	file=${PROJ_VERSION_FILE}
	
	echo "" >> $file
	echo "##[ RESTORE ]##" >> $file
	echo "date:$(date +%Y-%m-%d@%H:%M:%S)" >> $file
	echo "version:${restored_data}" >> $file
}

refresh_website() {
	if [ -f "${PROJ_ETC_DIR}/refresh_website.sh" ]; then
		print_title "${PROJ_ETC_DIR}/refresh_website.sh"
		${PROJ_ETC_DIR}/refresh_website.sh
	fi
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
	echo "Please select item to retore:"
	echo "  (0) ALL"
	echo "  (1) db (mongo)"
	echo "  (2) /yiabi/ebooklib"
	echo "  (3) /yiabi/mapdb"
	echo "  (4) /yiabi/webuser"
	read -p "Which item you want to retore?(0/1/2/3/4): " restored_item

	prepare_data

	case ${restored_item} in
		"0")
			restore_db
			restore_ebooklib
			restore_mapdb
			restore_webuser
			;;
			
		"1")
			restore_db
			;;
			
		"2")
			restore_ebooklib
			;;
			
		"3")
			restore_mapdb
			;;
			
		"4")
			restore_webuser
			;;
			
		*)
			echo "Invalid selection!!! 881~"
			remove_prepared_data
			exit 0
			;;
	esac

	remove_prepared_data
	
	append_log
	refresh_website
	
	print_title "Restore ${restored_data} successfully!~ 881~"
	echo ""
	echo ""
fi
