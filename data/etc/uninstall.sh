#/bin/bash

ts=$(date +%Y%m%d%H%M%S)

TARGET="/yiabi"
TARGETLINK="/yiabiRoot"
USERDATA="$TARGET/webuser"

MEMBER_DUP_DIR="/tmp/yiabi_${ts}"1

java_kill() {
	pkill -9 java
}

mongo_kill(){
	pkill -9 mongod
	rm -f /tmp/mongodb*
}

yiabi_duplicate_memberdata() {
	read -p "Do you want to duplicate member data? (y/n)" yesno
	if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then

		if [ -d "$USERDATA" ]; then
			mkdir -p ${MEMBER_DUP_DIR}
			echo "Copy member data to ${MEMBER_DUP_DIR} ..."
			cp -rf ${USERDATA}/* ${MEMBER_DUP_DIR}
		fi
		
		echo ""
		echo ""
		echo ""
		echo "Copy successfully!"
	fi
}

yiabi_uninstall() {
	read -p "Do you want to uninstall yiabi? (y/n)" yesno
	if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then

		echo "Uninstalling ..."
		rm -rf /tmp/selfextract.*

		#java_kill
		#mongo_kill

		if [ -d "$TARGET" ]; then
			rm -rf $TARGET
			rm -rf $TARGETLINK
			rm -rf $TARGET/uninstall.sh
		else
			echo "$TARGET not found!!"
		fi
		
		echo ""
		echo ""
		echo ""
		echo "Uninstall successfully!"
	fi
}


## main
	yiabi_duplicate_memberdata
	yiabi_uninstall


