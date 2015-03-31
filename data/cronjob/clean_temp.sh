#!/bin/bash

source "/wels/path.sh"

proj_clean_temp() {
	expired_days="$1"
	#echo "$(date +"%Y-%m%d-%H%M-%S") Clean $PROJ_TEMP_DIR, expired days > $expired_days" >> $PROJ_LOGFILE
	find ${PROJ_TEMP_DIR}/ -name '*' -mtime +${expired_days} -exec rm -f {} \;
	find ${PROJ_WEBUSER_POSTTEMP_DIR}/ -name '*' -mtime +${expired_days} -exec rm -f {} \;
}

proj_clean_temp 3
