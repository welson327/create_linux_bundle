#!/bin/bash

source "/yiabi/path.sh"

check_item=""
declare -A hostMap=()

remote_cmd() {
	host="$1"
	cmd="$2"
	echo $(ssh webuser@${host} ${cmd})
}

load_dfs_hosts_config() {
	while read line; do 
		local host="$(echo $line | cut -d':' -f1)"
		local value="$(echo ${line#*:})"
		
		hostMap[${host}]=${value}
		echo "[Parse dfs_hosts.conf] hostMap[$host] => ${hostMap[$host]}, hostMap.length => ${#hostMap[@]}"
	done < ${YIABI_ETC_DIR}/dfs_hosts.conf
}


query_check_item() {
	echo "Installation supports following items for you:"
	#echo "  (h) --Help--"
	echo "  (1) Parse dfs_hosts.conf of localhost"
	echo "  (2) Parse dfs_hosts.conf of Member-Server"
	echo "  (3) Parse dfs_hosts.conf of Download-Server"
	echo "  (4) Parse dfs_hosts.conf of LIB-Server"
	echo "  (5) Parse dfs_hosts.conf of PDF-Server"
	echo "  (6) Parse dfs_hosts.conf of Corgi-Server"
	echo "  (7) Check PchomeBypass-Server"
	echo "  (q) Quit"
	read -p "Select item to check?(1/2/3/...): " check_item
	
	case ${check_item} in
		"2")
			echo ">> Check Member-Server:"
			host=$(echo ${hostMap[memberServerHost]} | cut -d':' -f2)
			cmd="ls -l ${TOMCAT_WAR_DIR}/pus.war; cat ${YIABI_ETC_DIR}/dfs_hosts.conf"
			;;
		"3")
			echo ">> Check Download-Server:"
			host=$(echo ${hostMap[downloadServerHost]} | cut -d':' -f2)
			cmd="ls -l ${TOMCAT_WAR_DIR}/downloadss.war; cat ${YIABI_ETC_DIR}/dfs_hosts.conf"
			;;
		"4")
			echo ">> Check LIB-Server:"
			host=$(echo ${hostMap[libAccessServerHost]} | cut -d':' -f2)
			cmd="ls -l ${TOMCAT_WAR_DIR}/Akita.war; cat ${YIABI_ETC_DIR}/dfs_hosts.conf"
			;;
		"5")
			echo ">> Check PDF-Server:"
			host=$(echo ${hostMap[pdfConversionServerHost]} | cut -d':' -f2)
			cmd="ls -l ${TOMCAT_WAR_DIR}/Akita.war; cat ${YIABI_ETC_DIR}/dfs_hosts.conf"
			;;
		"6")
			echo ">> Check Corgi-Server:"
			host=$(echo ${hostMap[corgiServerHost]} | cut -d':' -f2)
			cmd="ls -l ${TOMCAT_WAR_DIR}/Corgi.war; cat ${YIABI_ETC_DIR}/dfs_hosts.conf"
			;;
		"7")
			echo ">> Check PchomeBypass-Server:"
			host=$(echo ${hostMap[pchomeBypassHost]})
			#cmd="ls -l ${TOMCAT_WAR_DIR}/thirdparty_auth.war"
			cmd="curl ${host}/thirdparty_auth/helloworld"
			;;
		"q")
			exit 0
			;;
		*)
			echo ">> Check localhost:"
			host="//localhost"
			cmd="ls -l ${TOMCAT_WAR_DIR}; cat ${YIABI_ETC_DIR}/dfs_hosts.conf"
			;;
	esac
	
	
	host=${host:2} # trim //
	
	
	case ${check_item} in
		"1") #localhost
			echo ">> Run command: [${cmd}]"
			$cmd
			;;
		"7") #pchomeBypassHost
			echo ">> Run command: [${cmd}]"
			$cmd
			;;
		*)
			echo ">> ssh to [${host}] with [${cmd}]"
			remote_cmd $host $cmd
			;;
	esac

	echo ""
	echo ""
	echo ""
	query_check_item	
}

load_dfs_hosts_config
query_check_item
