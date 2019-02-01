#!/bin/bash

NGINX_DIR="/opt/nginx"

export PROJ_NAME="myapp"
export PROJ_DATA_TOP_PATH="/${PROJ_NAME}"
export PROJ_DATA_TOP_VIRTUAL_PATH="/${PROJ_NAME}Root"
export PROJ_PATH_CONF="${PROJ_DATA_TOP_PATH}/path.sh"


export PROJ_BACKUP_DIR="${PROJ_DATA_TOP_PATH}/backup"
export PROJ_CRONJOB_DIR="${PROJ_DATA_TOP_PATH}/cronjob"
export PROJ_ETC_DIR="${PROJ_DATA_TOP_PATH}/etc"
# export PROJ_MEMBER_DIR="${PROJ_DATA_TOP_PATH}/member"
export PROJ_SERVICE_DIR="${PROJ_DATA_TOP_PATH}/service"
export PROJ_TEMP_DIR="${PROJ_DATA_TOP_PATH}/temp"
export PROJ_WS_DIR="${PROJ_DATA_TOP_PATH}/ws"

export PROJ_LOGFILE="${PROJ_WS_DIR}/rails/log/development.log"
export PROJ_VERSION_FILE="${PROJ_DATA_TOP_PATH}/version.txt"

LOCALHOST="127.0.0.1"

# MAC OS: $OSTYPE = darwin
if [[ "$OSTYPE" == *win* ]]; then 
	echo "****************************************************************************"
	echo "* Your OS is Mac!"
	echo "****************************************************************************"
fi
