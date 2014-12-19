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

dbname="puppy"
ts="$(date +%Y%m%d_%H%M%S)"

restored_db_tarname="${dbname}.tar.gz"
restored_webuser_tarname="webuser.tar.gz"

backup_file="${YIABI_BACKUP_DIR}/yiabi_backup_db-${ts}.tar.gz"


print_title() {
	echo ""
	echo ""
	echo ""
	echo "=====> $1"
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
	
	backup_dir="${YIABI_BACKUP_DIR}/db/${dbname}"

	rm -rf ${backup_dir}
	mongodump -h 127.0.0.1 -d ${dbname} -o ${YIABI_BACKUP_DIR}/db
	tar -zcvpf ${YIABI_BACKUP_DIR}/${restored_db_tarname} -C ${YIABI_BACKUP_DIR}/db ${dbname}
	
	cd -
}

pack_restored_data() {
	print_title "Generate Backup ${backup_file} ..."
	tar -zcvpf "${backup_file}" -C ${YIABI_BACKUP_DIR} ${restored_db_tarname} ${restored_webuser_tarname} 2>/dev/null
	rm -rf ${YIABI_BACKUP_DIR}/${restored_db_tarname}
}


print_title "Start backup DB ..."
backup_db
#backup_webuser
pack_restored_data
print_title "Backup DB completed. Backup file: ${backup_file}"
