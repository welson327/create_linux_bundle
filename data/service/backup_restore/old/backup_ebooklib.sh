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

restored_ebooklib_tarname="ebooklib.tar.gz"
backup_file="${YIABI_BACKUP_DIR}/yiabi_backup_ebooklib-${ts}.tar.gz"


print_title() {
	echo ""
	echo ""
	echo ""
	echo "=====> $1"
}

backup_ebooklib() {
	print_title "Backup ${YIABI_EBOOKLIB_DIR} ..."
	cd /
	tar -zcvpf ${YIABI_BACKUP_DIR}/${restored_ebooklib_tarname} -C ${YIABI_DATA_TOP_PATH} ebooklib
	cd -
}

pack_restored_data() {
	print_title "Generate Backup ${backup_file} ..."
	tar -zcvpf "${backup_file}" -C ${YIABI_BACKUP_DIR} ${restored_ebooklib_tarname}
	rm -rf ${YIABI_BACKUP_DIR}/${restored_ebooklib_tarname}
}


print_title "Start backup ..."
backup_ebooklib
pack_restored_data
print_title "Backup completed. Backup file: ${backup_file}"