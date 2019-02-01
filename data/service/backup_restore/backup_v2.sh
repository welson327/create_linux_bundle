#!/bin/bash

source "/myapp/path.sh"

backup_item="$1"
dbname="puppy"
ts="$(date +%Y%m%d_%H%M%S)"


restored_db_tarname="${dbname}.tar.gz"
restored_ebooklib_tarname="ebooklib.tar.gz"
restored_mapdb_tarname="mapdb.tar.gz"
restored_webuser_tarname="webuser.tar.gz"

backup_file="${PROJ_BACKUP_DIR}/PROJ_backup-${ts}.tar.gz"


print_title() {
	echo ""
	echo ""
	echo ""
	echo "=====> $1"
}

get_backup_filepath() {
	tagName="$1"
	case ${tagName} in
		"1")
			tagName="_db"
			;;
		"2")
			tagName="_ebooklib"
			;;
		"3")
			tagName="_mapdb"
			;;
		"4")
			tagName="_webuser"
			;;
		*)
			tagName=""
			;;
	esac
	echo "${PROJ_BACKUP_DIR}/PROJ_backup${tagName}-${ts}.tar.gz"
}

# ===============================================================
# Purpose:		
# Parameter:	
# Return:
# Remark:		# gen a 'puppy' dir
# Author:
# ===============================================================
backup_db() {
	print_title "Backup database of ${dbname} ..."
	cd /
	
	backup_dir="${PROJ_BACKUP_DIR}/db/${dbname}"

	rm -rf ${backup_dir}
	mongodump -h 127.0.0.1 -d ${dbname} -o ${PROJ_BACKUP_DIR}/db
	tar -zcvpf ${PROJ_BACKUP_DIR}/${restored_db_tarname} -C ${PROJ_BACKUP_DIR}/db ${dbname}
	
	cd -
}

backup_ebooklib() {
	print_title "Backup ${PROJ_EBOOKLIB_DIR} ..."
	cd /
	tar -zcvpf ${PROJ_BACKUP_DIR}/${restored_ebooklib_tarname} -C ${PROJ_DATA_TOP_PATH} ebooklib
	cd -
}

backup_mapdb() {
	print_title "Backup ${PROJ_MAPDB_DIR} ..."
	cd /
	tar -zcvpf ${PROJ_BACKUP_DIR}/${restored_mapdb_tarname} -C ${PROJ_DATA_TOP_PATH} mapdb
	cd -
}

backup_webuser() {
	print_title "Backup ${PROJ_WEBUSER_DIR} ..."
	cd /
	tar -zcvpf ${PROJ_BACKUP_DIR}/${restored_webuser_tarname} -C ${PROJ_DATA_TOP_PATH} webuser
	cd -
}

pack_restored_data() {
	print_title "Generate Backup ${backup_file} ..."
	tar -zcvpf "${backup_file}" -C ${PROJ_BACKUP_DIR} \
				${restored_db_tarname} \
				${restored_ebooklib_tarname} \
				${restored_mapdb_tarname} \
				${restored_webuser_tarname} 2>/dev/null
	rm -rf ${PROJ_BACKUP_DIR}/${restored_db_tarname}
	rm -rf ${PROJ_BACKUP_DIR}/${restored_ebooklib_tarname}
	rm -rf ${PROJ_BACKUP_DIR}/${restored_mapdb_tarname}
	rm -rf ${PROJ_BACKUP_DIR}/${restored_webuser_tarname}
}


if [ -z "${backup_item}" ]; then
	echo "Please select item to backup:"
	echo "  (0) ALL"
	echo "  (1) db (mongo)"
	echo "  (2) /yiabi/ebooklib"
	echo "  (3) /yiabi/mapdb"
	echo "  (4) /yiabi/webuser"
	read -p "Which item you want to backup?(0/1/2/3/4): " backup_item
fi

backup_file="$(get_backup_filepath ${backup_item})"

print_title "Start backup ..."

case ${backup_item} in
	"0")
		backup_db
		backup_ebooklib
		backup_mapdb
		backup_webuser
		;;
		
	"1")
		backup_db
		;;
		
	"2")
		backup_ebooklib
		;;
		
	"3")
		backup_mapdb
		;;
		
	"4")
		backup_webuser
		;;
		
	*)
		echo "Invalid selection!!! 881~"
		exit 0
		;;
esac
	
pack_restored_data
	
print_title "Backup completed. Backup file: ${backup_file}"
