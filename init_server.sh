#!/bin/bash

echo "========================="
echo "    Service Installer"
echo "========================="

rm -rf /tmp/selfextract.*
BIN_FILE="$0"

export TMPDIR=`mktemp -d /tmp/selfextract.XXXXXX`

echo "Extract $BIN_FILE ..."
ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $BIN_FILE`
tail -n+$ARCHIVE $BIN_FILE | tar xzv -C $TMPDIR >/dev/null 2>/dev/null

#currdir="$(dirname $(readlink -f $0))"
CRONTAB_FILE="/etc/crontab"
DATA_DIR="${TMPDIR}/data"
echo "DATA_DIR=${DATA_DIR}"

source "${DATA_DIR}/path.sh"

install_version=""
ramdisk_root=""
restful_site="localhost:80/pus"

# ============================================================
# Purpose: 		get ver. number bin BIN name
# Parameter: 	
# Return:     input: abcd-1.5.6.bin, output:1.5.6
# Remark:		  Format must be xxxxx-1.2.3.bin, where xxxxx should be alnum or underline
# Author:		  Welson
# ============================================================
version_get() {
	bin_name="$1"
	ver=$(echo ${bin_name} | cut -d'-' -f2 | sed 's/\([1-9\.]*\)\.bin/\1/')
	echo "$ver"
}

print_red() {
	rslt="$1"
	printf "%*s%s\n" "$(tput cols)" "[$(tput setaf 1)${rslt}$(tput sgr0)]"
}
print_green() {
	rslt="$1"
	printf "%*s%s\n" "$(tput cols)" "[$(tput setaf 2)${rslt}$(tput sgr0)]"
}

is_windows() {
	# if os can run this script, almost is using cygwin
	if [[ "$OSTYPE" == *win* ]]; then 
		echo "true"
	else
		echo "false"
	fi
}

still_install?() {
	read -e -p "Still install? (y/n)" yesno
	if [ "$yesno" != "y" ]; then
		exit 0
	fi
}

query_install_version() {
	echo "Installation supports following items for you:"
	echo "  (h) --Help--"
	echo "  (1) Official (WEB-server)"
	echo "  (2) Engineer (default)"
	echo "  (3) Only pus (MEMBER-server)"
	echo "  (4) Only Akita"
	echo "  (5) Only eagle"
	echo "  (6) Only downloadss"
	echo "  (t) Only folder tree"
	echo "  (w) Only copy war"
	read -e -p "Which item to install?(1/2/3/4/5/6/t/w): " install_version
	
	case ${install_version} in
		"h" | "H")
			echo "* Official: Install [pus,Akita] in [${TOMCAT_WAR_DIR}], [puppy,member_system] in [${HTML_WAR_DIR}]."
			echo "* Engineer: Install all project in [${TOMCAT_WAR_DIR}]."
			echo "* Only pus: Install [pus] in [${TOMCAT_WAR_DIR}]."
			echo "* Only Akita: Install [Akita] in [${TOMCAT_WAR_DIR}]."
			echo "* Only eagle: Install [eagle] in [${TOMCAT_WAR_DIR}]."
			echo "* Only downloadss: Install [downloadss] in [${TOMCAT_WAR_DIR}]."
			echo "* Only folder tree: mkdir -p ${YIABI_DATA_TOP_PATH} and its child folders."
			read -e -p "Back to install menu? (y/n)" yesno
			if [ "$yesno" = "y" ]; then
				query_install_version
			else
				exit 0
			fi
			;;
		"1")
			echo "------> Prepare to install [Official] version."
			ramdisk_root="${RAMDISK_DIR}"
			;;
		"3")
			echo "------> Prepare to install [pus]."
			;;
		"4")
			echo "------> Prepare to install [Akita]."
			;;
		"5")
			echo "------> Prepare to install [eagle]."
			;;
		"6")
			echo "------> Prepare to install [downloadss]."
			;;
		"t")
			echo "------> Prepare to mkdir folder tree."
			create_init_folder
			exit 0
			;;
		"w")
			echo "------> Prepare to copy war."
			query_path_and_copy_war
			exit 0
			;;
		*)
			echo "------> Prepare to install [Engineer] version."
			;;
	esac
	echo ""
	echo ""
	echo ""	
	
	
	# define env
	#(1)
	echo "ramdiskRoot:${ramdisk_root}" > ${DATA_DIR}/etc/env.conf
	#(2)
	#read -e -p "Install production environment? (y/n)" yesno
	#if [ "$yesno" = "y" ]; then
		echo "isProduction:true" >> ${DATA_DIR}/etc/env.conf
	#else
	#	echo "isProduction:false" >> ${DATA_DIR}/etc/env.conf
	#fi

}

change_permission() {
	dir="$1"
	
	case "$install_version" in
		"4" | "5") # library server
			if [ "$dir" = "${YIABI_DATA_TOP_PATH}" ] || [ "$dir" = "${YIABI_EBOOKLIB_DIR}" ]; then
				cnt=$(ls ${YIABI_EBOOKLIB_DIR} | wc -l)
				if [ "$cnt" -gt 100 ]; then
					return
				fi
			fi
			;;
		*)
			;;
	esac
	
	chmod -R 777 $dir
	chown -R webuser:webuser $dir
}

check_os() {
	os="$(uname)"
	echo "Your OS is [${os}]"
	
	case "$os" in
		Linux)
			;;
		Darwin)
			echo "Please Make sure ${TOMCAT_WAR_DIR} and ${HTML_WAR_DIR} are exist!"
			still_install?
			;;
		*)
			;;
	esac
}

check_env() {
	cnt=$(grep 'crossContext="true"' /usr/local/*tomcat*/conf/context.xml -r  | wc -l)
	if [ $cnt -gt 0 ]; then
		print_green "Check [crossContext=\"true\"] OK."
	else
		echo "!!!!!!!!!!!!!!!!!!!!!"
		echo "'crossContext=\"true\"' not found in context.xml,"
		still_install?
	fi 
	
	cnt=$(grep '<Alias>localhost</Alias>' /usr/local/*tomcat*/conf/server.xml -r  | wc -l)
	if [ $cnt -gt 0 ]; then
		print_green "Check [<Alias>localhost</Alias>] OK."
	else
		echo "!!!!!!!!!!!!!!!!!!!!!"
		echo "'<Alias>localhost</Alias>' not found in server.xml,"
		still_install?
	fi
	
	cnt=$(grep 'URIEncoding="UTF-8"' /usr/local/*tomcat*/conf/server.xml -r  | wc -l)
	if [ $cnt -gt 0 ]; then
		print_green "Check [URIEncoding=\"UTF-8\"] OK."
	else
		echo "!!!!!!!!!!!!!!!!!!!!!"
		echo "'URIEncoding=\"UTF-8\"' not found in server.xml,"
		still_install?
	fi
}

check_dependency() {
	local isSomethingNotFound="false"
	
	echo "===================================================="
	echo "Check Dependency:"
	
	echo "  Check [curl]:"
	if [ -z "$(which curl)" ]; then
		isSomethingNotFound="true"
		print_red "NOT FOUND"
	else
		print_green "OK"
	fi
	
	echo "  Check [mongo]:"
	if [ -z "$(which mongo)" ]; then
		isSomethingNotFound="true"	
		print_red "NOT FOUND"
	else
		print_green "OK"
	fi
	
	echo "  Check [ruby]:"
	if [ -z "$(which ruby)" ]; then
		isSomethingNotFound="true"	
		print_red "NOT FOUND"
	else
		print_green "OK"
	fi
	
	echo "  Check [json.rb]:"
	if [ -z "$(locate 'json.rb')" ]; then
		isSomethingNotFound="true"	
		print_red "NOT FOUND"
	else
		print_green "OK"
	fi

	if [ "$isSomethingNotFound" = "true" ]; then
		echo "------------------------------"
		echo "!!!!!!!!!!!!!!!!!!!!!"
		echo "Some dependency not found in your system!"
		still_install?
	fi
	echo "===================================================="
}

create_init_folder() {
	if [ ! -d $YIABI_DATA_TOP_PATH ]; then
		mkdir -p $YIABI_DATA_TOP_PATH
	fi
	
	ln -nsf $YIABI_DATA_TOP_PATH /yiabiRoot
	chown -R webuser:webuser /yiabiRoot
	change_permission $YIABI_DATA_TOP_PATH
	
	
	mkdir -p $YIABI_BACKUP_DIR
	mkdir -p $YIABI_CRONJOB_DIR
	mkdir -p $YIABI_ETC_DIR
	mkdir -p $YIABI_EBOOKLIB_DIR

	# mapdb
	mkdir -p $YIABI_BROWSING_COUNTER_DIR
	mkdir -p $YIABI_COUNT24HR_DIR
	mkdir -p $YIABI_CUTTING_COUNTER_DIR

	mkdir -p $YIABI_SERVICE_DIR
	mkdir -p $YIABI_TEMP_DIR

	mkdir -p $YIABI_WEBSERVICE_DIR

	# webuser
	mkdir -p $YIABI_WEBUSER_DIR
	mkdir -p $YIABI_WEBUSER_DIR/cache
	mkdir -p $YIABI_WEBUSER_DIR/doclib/html_converted
	mkdir -p $YIABI_WEBUSER_DIR/doclib/log
	mkdir -p $YIABI_WEBUSER_DIR/doclib/upload_doc
	mkdir -p $YIABI_WEBUSER_DIR/doclib/zip_temp
	mkdir -p $YIABI_WEBUSER_POSTTEMP_DIR
	mkdir -p $YIABI_WEBUSER_ZIPSEND_DIR
	for ch in {a..z}; do
		mkdir -p $YIABI_WEBUSER_DIR/$ch
	done
	for dd in {0..9}; do
		mkdir -p $YIABI_WEBUSER_DIR/$dd
	done
	
	if [ ! -d $YIABI_WEBUSER_SOFTLINK_DIR ]; then
		mkdir -p $YIABI_WEBUSER_SOFTLINK_DIR
	fi
	
	# for jsp compile
	chown -R webuser:webuser $TOMCAT_DIR
	
	# ramdisk dir
	mkdir -p $RAMDISK_DIR
	rm -rf $RAMDISK_DIR/*
	change_permission $RAMDISK_DIR
}

query_path_and_copy_war() {
	read -e -p "Please input your path to copy war: " cpPath
	version="$(version_get ${BIN_FILE})"
	cpPath="${cpPath}/v${version}"
	mkdir -p "${cpPath}"
	echo "cp -rf ${DATA_DIR}/war/*.war ${cpPath} ..."
	cp -rf ${DATA_DIR}/war/*.war ${cpPath}
}

has_cronjob() {
	task_tag="$1"
	
	if [ $(grep "$task_tag" "$CRONTAB_FILE" -nHr | wc -l) -gt 0 ]; then
		echo "true"
	else
		echo "false"
	fi
}

set_crontab() {
	case ${install_version} in
		"1" | "2") # Official|Engineer
				echo "cp -f ${DATA_DIR}/etc/crontab /etc/crontab"
				cp -f ${DATA_DIR}/etc/crontab /etc/crontab
			;;
		# ----------------------------> Handled by IT
		#"3") # only_pus
		#		read -e -p "Keep original crontab? (y/n)" isKeep
		#		if [ "$isKeep" = "n" ]; then
		#			echo "cp -f ${DATA_DIR}/etc/crontab /etc/crontab"
		#			cp -f ${DATA_DIR}/etc/crontab /etc/crontab
		#		fi
		#	;;
		"6") # downloadss
				echo "cp -f ${DATA_DIR}/etc/crontab-downloadss /etc/crontab"
				cp -f ${DATA_DIR}/etc/crontab-downloadss /etc/crontab
			;;
		*)
			;;
	esac
}

make_version_file() {
	file="${YIABI_VERSION_FILE}"
	
	echo "" >> $file

	echo "##[ INSTALL ]##" >> $file
	echo "date:$(date +%Y-%m-%d@%H:%M:%S)" >> $file
	echo "version:$(version_get ${BIN_FILE})" >> $file
}

create_poweruser() {
	poweruser="yiabiadmin@yiabi.com"
	
	echo "Check PowerUser:"
	if [ -f "${YIABI_WEBUSER_SOFTLINK_DIR}/$poweruser" ]; then
		print_green "$poweruser is already exist."
	else
		echo "Create poweruser, ${poweruser}, ..."
		${DATA_DIR}/service/account/create_poweruser.sh "$poweruser" "yiabiadmin"
		print_green "OK"
	fi
	
	echo ""
	echo ""
}

create_special_users() {
	
	echo "Check SpecialUser:"
	
	user="yiabiunregister@yiabi.com"
	if [ -f "${YIABI_WEBUSER_SOFTLINK_DIR}/$user" ]; then
		print_green "$user is already exist."
	else
		echo "Create user, ${user}, ..."
		${DATA_DIR}/service/account/create_special_account.sh "$user" "未註冊會員" "" 310
		print_green "OK"
	fi
	
	user="yiabiextractor@yiabi.com"
	if [ -f "${YIABI_WEBUSER_SOFTLINK_DIR}/$user" ]; then
		print_green "$user is already exist."
	else
		echo "Create user, ${user}, ..."
		${DATA_DIR}/service/account/create_special_account.sh "$user" "yiabiextractor" "" 310
		print_green "OK"
	fi
	
	user="yiabitester@yiabi.com"
	if [ -f "${YIABI_WEBUSER_SOFTLINK_DIR}/$user" ]; then
		print_green "$user is already exist."
	else
		echo "Create user, ${user}, ..."
		${DATA_DIR}/service/account/create_special_account.sh "$user" "yiabitester" "" 400
		print_green "OK"
	fi
	
	echo ""
	echo ""
}

remove_genFooBooks() {
	# change permission of API: /genFooBooks
	rm -f "${YIABI_ETC_DIR}/genFooBooks"
}

modify_numbers_of_bookcover() {
	jsFile="$1"
	coverHome="${YIABI_SERVICE_DIR}/ebook/cover"
	
	if [ -d "${coverHome}" ]; then
		cover_num="$(find ${coverHome}/* -name 'cover*.*' | wc -l)"
		echo "Change numbers of bookcover into ${cover_num} ...."
		sed -i "s-\(var COVER_NUM =\ \).*-\1${cover_num};-" $jsFile
	fi
}

deploy_ebook_coverimg() {
	apache_proj_home="${HTML_WAR_DIR}/puppy"
	tomcat_proj_home="${TOMCAT_WAR_DIR}/puppy"
	apache_ws="${apache_proj_home}/img/cover"
	tomcat_ws="${tomcat_proj_home}/img/cover"
	
	if [ -d "${HTML_WAR_DIR}/puppy" ]; then
		mkdir -p ${apache_ws}
	fi
	if [ -d "${TOMCAT_WAR_DIR}/puppy" ]; then
		mkdir -p ${tomcat_ws}
	fi


	if [ -d "${apache_ws}" ]; then
		echo "copy ${YIABI_SERVICE_DIR}/ebook/cover/* to ${apache_ws}"
		cp -rf ${YIABI_SERVICE_DIR}/ebook/cover/* ${apache_ws}
		#modify_numbers_of_bookcover "${apache_proj_home}/js/pages/complete_upload_page.js"
	fi
	if [ -d "${tomcat_ws}" ]; then
		echo "copy ${YIABI_SERVICE_DIR}/ebook/cover/* to ${tomcat_ws}"
		cp -rf ${YIABI_SERVICE_DIR}/ebook/cover/* ${tomcat_ws}
		#modify_numbers_of_bookcover "${tomcat_proj_home}/js/pages/complete_upload_page.js"
	fi
}

deploy_chromestore_certification() {
	case ${install_version} in
		"1" | "2")
			cp -rf ${YIABI_ETC_DIR}/yiabi_cutting/google*.html ${TOMCAT_WAR_DIR}
			cp -rf ${YIABI_ETC_DIR}/yiabi_cutting/google*.html ${HTML_WAR_DIR}
			;;
		*)
			;;
	esac
}

deploy_phantomjs() {
	phantomjs_bin="${PHANTOMJS_DIR}/phantomjs-1.9.7-linux-i686/bin/phantomjs"
	phantomjs_tar="${PHANTOMJS_DIR}/phantomjs-1.9.7-linux-i686.tar.bz2"
	
	if [ ! -f "${phantomjs_bin}" ]; then
		mkdir -p $PHANTOMJS_DIR
		
		echo "cp ${DATA_DIR}/etc/phantomjs/* ${PHANTOMJS_DIR}"
		cp -rf ${DATA_DIR}/etc/phantomjs/* ${PHANTOMJS_DIR}
		
		echo "tar -xf ${phantomjs_tar} -C ${PHANTOMJS_DIR}"
		tar -xf ${phantomjs_tar} -C ${PHANTOMJS_DIR}
		echo "${phantomjs_bin} is deployed successfully!~"
	else
		echo "${phantomjs_bin} has been deployed."
	fi
	
	change_permission /tmp/phantomjs.out
	change_permission ${PHANTOMJS_DIR}
}

check_service() {
	case ${install_version} in
		"4")
			proj="Akita"
			;;
		"5")
			proj="eagle"
			;;
		"6")
			proj="downloadss"
			;;
		*)
			proj="pus"
			;;
	esac
	
	if [ "$(curl localhost:80/${proj}/services/helloworld)" = "Hello_World" ]; then 
		echo "true"
	elif [ "$(curl localhost:8080/${proj}/services/helloworld)" = "Hello_World" ]; then 
		echo "true"
	else
		echo "false"
	fi
}

wait_for_service_ready() {
	sleep 3
	cnt=0
	isReady="true"
	
	while [ "$(check_service)" = "false" ]; do
		echo "Wait for service ready ..."
		cnt=$(($cnt+1))
		sleep 3
		
		if [ $cnt -gt 10 ]; then
			isReady="false"
			break
		fi
	done
	
	echo ""
	echo ""
	if [ "$isReady" = "true" ]; then
		print_green "Service is ready"
	else
		print_red "Service is not ready!!! (timeout)"
	fi
	echo ""
	echo ""
}

refresh_website() {
	case ${install_version} in
		"1" | "2")
			${YIABI_ETC_DIR}/refresh_website.sh
			;;
		*)
			;;
	esac
}

check_dfs_hosts_conf() {
	if [ -f "${YIABI_ETC_DIR}/dfs_hosts.conf" ]; then
		read -e -p "${YIABI_ETC_DIR}/dfs_hosts.conf is exist! Keep original file? (y/n)" isKeep
		if [ "$isKeep" = "y" ]; then
			echo "Keep original dfs_hosts.conf."
			cp -rf ${YIABI_ETC_DIR}/dfs_hosts.conf ${DATA_DIR}/etc
		fi
	fi
}

check_web_list() {
	if [ -f "${YIABI_ETC_DIR}/web_list" ]; then
		read -e -p "${YIABI_ETC_DIR}/web_list is exist! Keep original file? (y/n)" isKeep
		if [ "$isKeep" = "y" ]; then
			echo "Keep original web_list."
			cp -rf ${YIABI_ETC_DIR}/web_list ${DATA_DIR}/etc
		fi
	fi
}

create_softlink() {
	echo "ln -nsf ${ramdisk_root}${YIABI_EBOOKLIB_DIR} ${HTML_WAR_DIR}/eb"
	echo "ln -nsf ${ramdisk_root}${YIABI_WEBUSER_DIR}/mfs/member ${HTML_WAR_DIR}/fo"
	echo "ln -nsf ${ramdisk_root}${YIABI_WEBUSER_DIR} ${HTML_WAR_DIR}/m"
	echo "ln -nsf ${YIABI_STATIC_DATA_DIR} ${HTML_WAR_DIR}/st"
	ln -nsf ${ramdisk_root}${YIABI_EBOOKLIB_DIR} ${HTML_WAR_DIR}/eb
	ln -nsf ${ramdisk_root}${YIABI_WEBUSER_DIR}/mfs/member ${HTML_WAR_DIR}/fo
	ln -nsf ${ramdisk_root}${YIABI_WEBUSER_DIR} ${HTML_WAR_DIR}/m
	ln -nsf ${YIABI_STATIC_DATA_DIR} ${HTML_WAR_DIR}/st
}

deploy() {
	# clear /yiabi/war
	rm -rf ${YIABI_DATA_TOP_PATH}/war
	
	# tomcat/temp (for file upload)
	if [ -d "${TOMCAT_DIR}" ]; then
		mkdir -p ${TOMCAT_DIR}/temp
		change_permission ${TOMCAT_DIR}/temp
	fi
	
	# fix sun.awt.X11GraphicsEnvironment not found
	if [ -d "${TOMCAT_DIR}/bin" ]; then
		if [ ! -f "${TOMCAT_DIR}/bin/setenv.sh" ]; then
			cp -rf ${DATA_DIR}/etc/setenv.sh ${TOMCAT_DIR}/bin
		fi
	fi
	
	check_dfs_hosts_conf
	check_web_list
	
	cp -rf ${DATA_DIR}/* ${YIABI_DATA_TOP_PATH}/
	
	if [ -d "${DATA_DIR}/war" ]; then
	
		mkdir -p ${TOMCAT_WAR_DIR}
		mkdir -p ${HTML_WAR_DIR}
		create_softlink
		
		
		case ${install_version} in
			"1") # official
				echo "------> Copy official-version data ..."
				
				deploy_phantomjs
				
				# mv servlet API 
				echo "cp -f ${DATA_DIR}/war/Akita.war ${TOMCAT_WAR_DIR}"
				cp -rf ${DATA_DIR}/war/Akita.war ${TOMCAT_WAR_DIR}
				echo "cp -f ${DATA_DIR}/war/pus.war ${TOMCAT_WAR_DIR}"
				cp -rf ${DATA_DIR}/war/pus.war ${TOMCAT_WAR_DIR}
				echo "cp -f ${DATA_DIR}/war/pipe.war ${TOMCAT_WAR_DIR}"
				cp -rf ${DATA_DIR}/war/pipe.war ${TOMCAT_WAR_DIR}
				
				# mv web pages
				member_system_home="${HTML_WAR_DIR}/member_system"
				webpage_home="${HTML_WAR_DIR}/puppy"
				
				mkdir -p ${member_system_home}
				mkdir -p ${webpage_home}
				
				echo "cp -f ${DATA_DIR}/war/member_system.war ${member_system_home}"
				cp -rf ${DATA_DIR}/war/member_system.war ${member_system_home}
				
				echo "cp -f ${DATA_DIR}/war/puppy.war ${webpage_home}"
				cp -rf ${DATA_DIR}/war/puppy.war ${webpage_home}
				
				## Use 'jar -xf FILE -C DIR' is fail
				cd ${member_system_home}
				jar -xf ${member_system_home}/member_system.war
				cd -
				cd ${webpage_home}
				jar -xf ${webpage_home}/puppy.war
				cd -
				
				#rm -f ${member_system_home}/member_system.war
				#rm -f ${webpage_home}/puppy.war
				
				# redirected page
				#cp -rf ${DATA_DIR}/etc/index.html ${HTML_WAR_DIR}
				cp -rf ${DATA_DIR}/etc/redirect/RedirectRoot ${HOME_WEBUSER}
				cp -rf ${DATA_DIR}/etc/redirect/RedirectRoot ${HTML_WAR_DIR}
				;;
				
			"3")
				echo "------> Copy [pus] data ..."
				echo "cp -f ${DATA_DIR}/war/pus.war ${TOMCAT_WAR_DIR}"
				cp -rf ${DATA_DIR}/war/pus.war ${TOMCAT_WAR_DIR}
				;;
				
			"4")
				#~ echo "!! Stop [Akita] tasks threads (doc) ..."
				#~ curl localhost:80/Akita/DocConversionServer?stop=1
				#~ sleep 1
				#~ echo "!! Stop [Akita] tasks threads (pdf) ..."
				#~ curl localhost:80/Akita/PDFConversionServer?stop=1
				#~ sleep 1
				#~ echo "!! Stop [Akita] tasks threads (lib) ..."
				#~ curl localhost:80/Akita/LibraryServer?stop=1
				#~ sleep 5
				echo "------> Copy [Akita] data ..."
				echo "cp -f ${DATA_DIR}/war/Akita.war ${TOMCAT_WAR_DIR}"
				cp -rf ${DATA_DIR}/war/Akita.war ${TOMCAT_WAR_DIR}
				;;
				
			"5")
				echo "------> Copy [eagle] data ..."
				echo "cp -f ${DATA_DIR}/war/eagle.war ${TOMCAT_WAR_DIR}"
				cp -rf ${DATA_DIR}/war/eagle.war ${TOMCAT_WAR_DIR}
				;;
			"6")
				echo "------> Copy [downloadss] data ..."
				echo "cp -f ${DATA_DIR}/war/downloadss.war ${TOMCAT_WAR_DIR}"
				cp -rf ${DATA_DIR}/war/downloadss.war ${TOMCAT_WAR_DIR}
				;;
							
			*)
				echo "------> Copy engineer-version data ..."
				
				deploy_phantomjs
				
				echo "cp -f ${DATA_DIR}/war/*.war ${TOMCAT_WAR_DIR}"
				cp -rf ${DATA_DIR}/war/*.war ${TOMCAT_WAR_DIR}
				
				# redirected page
				#cp -rf ${DATA_DIR}/etc/index.html ${TOMCAT_WAR_DIR}
				;;
		esac
	fi

	set_crontab

	wait_for_service_ready
	
	create_poweruser
	create_special_users
	deploy_ebook_coverimg
	deploy_chromestore_certification
	refresh_website
	
	make_version_file

	change_permission $YIABI_DATA_TOP_PATH
	change_permission $TOMCAT_WAR_DIR
	change_permission $HTML_WAR_DIR
}

clear_tmp() {
	rm -rf $TMPDIR
}


## main
check_env
check_dependency
query_install_version

create_init_folder
deploy
clear_tmp


echo ""
echo ""
echo ""
echo "Install completed. 881~"
exit 0

###############################################
__ARCHIVE_BELOW__
