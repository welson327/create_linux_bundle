#!/bin/bash

TOMCAT_DIR="/usr/local/tomcat7"

YIABI_DATA_TOP_PATH="/yiabi"
YIABI_DATA_TOP_VIRTUAL_PATH="/yiabiRoot"
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

YIABI_WEBUSER_SOFTLINK_DIR="${YIABI_WEBUSER_DIR}/softlink"
YIABI_WEBUSER_POSTTEMP_DIR="${YIABI_WEBUSER_DIR}/posttemp"
YIABI_WEBUSER_ZIPSEND_DIR="${YIABI_WEBUSER_DIR}/zipsend"

YIABI_LOGFILE="${TOMCAT_DIR}/logs/catalina.out"
YIABI_VERSION_FILE="${YIABI_DATA_TOP_PATH}/version.txt"

HOME_WEBUSER="/home/webuser"
if [[ "$OSTYPE" == *win* ]]; then 
	HOME_WEBUSER="${YIABI_WEBSERVICE_DIR}"
fi
TOMCAT_WAR_DIR="${HOME_WEBUSER}/JservRoot"
HTML_WAR_DIR="${HOME_WEBUSER}/HtmlRoot"
PHANTOMJS_DIR="${HOME_WEBUSER}/phantomjs"
RAMDISK_DIR="${HOME_WEBUSER}/rd"

# MapDB sub-level
YIABI_BROWSING_COUNTER_DIR="${YIABI_MAPDB_DIR}/browsing_counter"
YIABI_COUNT24HR_DIR="${YIABI_MAPDB_DIR}/count24hr"
YIABI_CUTTING_COUNTER_DIR="${YIABI_MAPDB_DIR}/cutting_counter"

LOCALHOST="127.0.0.1"

# MAC OS: $OSTYPE = darwin
if [[ "$OSTYPE" == *win* ]]; then 
	echo "****************************************************************************"
	echo "* Your OS is Mac! /home/webuser will be changed into ${YIABI_WEBSERVICE_DIR}"
	echo "* Please remember re-edit:"
	echo "*   (1) Apache httpd.conf of with DocumentRoot \"${HTML_WAR_DIR}\""
	echo "*   (2) Tomcat server.xml of with <Context docBase=\"${TOMCAT_WAR_DIR}\"/>"
	echo "* Good Luck!~"
	echo "****************************************************************************"
fi
