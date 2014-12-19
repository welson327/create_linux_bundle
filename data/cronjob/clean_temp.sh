#!/bin/bash

source "/yiabi/path.sh"

yiabi_clean_temp() {
	expired_days="$1"
	#echo "$(date +"%Y-%m%d-%H%M-%S") Clean $YIABI_TEMP_DIR, expired days > $expired_days" >> $YIABI_LOGFILE
	find ${YIABI_TEMP_DIR}/ -name '*' -mtime +${expired_days} -exec rm -f {} \;
	find ${YIABI_WEBUSER_POSTTEMP_DIR}/ -name '*' -mtime +${expired_days} -exec rm -f {} \;
}

yiabi_clean_temp 3
