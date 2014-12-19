#!/bin/bash

source "/yiabi/path.sh"

PORT="8080"

reload() {
	if [ -d "${TOMCAT_WAR_DIR}/Akita" ]; then
		echo "curl localhost:${PORT}/Akita/reloaddfshost"
		curl localhost:${PORT}/Akita/reloaddfshost
		echo ""
	fi

	if [ -d "${TOMCAT_WAR_DIR}/pus" ]; then
		echo "curl localhost:${PORT}/pus/reloaddfshost"
		curl localhost:${PORT}/pus/reloaddfshost
		echo ""
	fi
	
	if [ -d "${TOMCAT_WAR_DIR}/downloadss" ]; then
		echo "curl localhost:${PORT}/downloadss/reloaddfshost"
		curl localhost:${PORT}/downloadss/reloaddfshost
		echo ""
	fi
}

reload
