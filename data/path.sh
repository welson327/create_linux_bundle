#!/bin/bash

NGINX_DIR="/opt/nginx"

PROJ_NAME="myapp"
PROJ_DATA_TOP_PATH="/${PROJ_NAME}"
PROJ_DATA_TOP_VIRTUAL_PATH="/${PROJ_NAME}Root"
PROJ_PATH_CONF="${PROJ_DATA_TOP_PATH}/path.sh"


PROJ_BACKUP_DIR="${PROJ_DATA_TOP_PATH}/backup"
PROJ_CRONJOB_DIR="${PROJ_DATA_TOP_PATH}/cronjob"
PROJ_ETC_DIR="${PROJ_DATA_TOP_PATH}/etc"
# PROJ_MEMBER_DIR="${PROJ_DATA_TOP_PATH}/member"
PROJ_SERVICE_DIR="${PROJ_DATA_TOP_PATH}/service"
PROJ_TEMP_DIR="${PROJ_DATA_TOP_PATH}/temp"
PROJ_WS_DIR="${PROJ_DATA_TOP_PATH}/ws"

PROJ_LOGFILE="${PROJ_WS_DIR}/rails/log/development.log"
PROJ_VERSION_FILE="${PROJ_DATA_TOP_PATH}/version.txt"

LOCALHOST="127.0.0.1"

# MAC OS: $OSTYPE = darwin
if [[ "$OSTYPE" == *win* ]]; then 
	echo "****************************************************************************"
	echo "* Your OS is Mac!"
	echo "****************************************************************************"
fi
