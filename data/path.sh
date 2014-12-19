#!/bin/bash

NGINX_DIR="/opt/nginx"

YIABI_DATA_TOP_PATH="/wels"
YIABI_DATA_TOP_VIRTUAL_PATH="/welsRoot"
YIABI_PATH_CONF="${YIABI_DATA_TOP_PATH}/path.sh"


YIABI_BACKUP_DIR="${YIABI_DATA_TOP_PATH}/backup"
YIABI_CRONJOB_DIR="${YIABI_DATA_TOP_PATH}/cronjob"
YIABI_EBOOKLIB_DIR="${YIABI_DATA_TOP_PATH}/ebooklib"
YIABI_ETC_DIR="${YIABI_DATA_TOP_PATH}/etc"
YIABI_MAPDB_DIR="${YIABI_DATA_TOP_PATH}/mapdb"
YIABI_SERVICE_DIR="${YIABI_DATA_TOP_PATH}/service"
YIABI_STATIC_DATA_DIR="${YIABI_DATA_TOP_PATH}/static_data"
YIABI_TEMP_DIR="${YIABI_DATA_TOP_PATH}/temp"
YIABI_WEBSERVICE_DIR="${YIABI_DATA_TOP_PATH}/ws"
YIABI_WEBUSER_DIR="${YIABI_DATA_TOP_PATH}/webuser"

YIABI_LOGFILE="${YIABI_WEBSERVICE_DIR}/rails/log/development.log"
YIABI_VERSION_FILE="${YIABI_DATA_TOP_PATH}/version.txt"

LOCALHOST="127.0.0.1"

# MAC OS: $OSTYPE = darwin
if [[ "$OSTYPE" == *win* ]]; then 
	echo "****************************************************************************"
	echo "* Your OS is Mac!"
	echo "****************************************************************************"
fi
