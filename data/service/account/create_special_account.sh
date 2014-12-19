#!/bin/bash

source "/yiabi/path.sh"
source "$YIABI_SERVICE_DIR/account/account_api.sh"

account="$1"
nickname="$2"
mobilephone="$3"
level="$4"


create_profile_json() {
	accountOnRegister="$1"
	account="$(to_lowercase $1)"
	nicknameOnRegister="$2"
	nickname="$(to_lowercase $2)"
	mobile="$3"
	level="$4"
	
	account_dir="$(get_account_dir $account)"
	jsonFile="${account_dir}/${account}.json"
	
	cp -f ${YIABI_ETC_DIR}/yiabiadmin@yiabi.com.json $jsonFile
	
	jsonStr=$(get_account_profile_json "$accountOnRegister" "$nicknameOnRegister" "$mobile" "$level")
	echo $jsonStr > $jsonFile
}

is_email_format() {
	if [[ "$1" == *@* ]]; then 
		echo "true"; 
	else
		echo "false"
	fi
}


# main
if [ -z "$account" ]; then
	echo "Four arguments required. [1]email, (2)nickname, (3)mobilephone, (4)level"
elif [ -z "$nickname" ]; then
	echo "Four arguments required. (1)email, [2]nickname, (3)mobilephone, (4)level"
#elif [ -z "$mobilephone" ]; then
#	echo "Four arguments required. (1)email, (2)nickname, [3]mobilephone, (4)level"
elif [ -z "$level" ]; then
	echo "Four arguments required. (1)email, (2)nickname, (3)mobilephone, [4]level"
else
	
	accountLink="${YIABI_WEBUSER_SOFTLINK_DIR}/$account"
	nicknameLink="${YIABI_WEBUSER_SOFTLINK_DIR}/$nickname"
	mobileLink="${YIABI_WEBUSER_SOFTLINK_DIR}/$mobilephone"

	if [ -f "$accountLink" ]; then
		echo "Account, $account, exist!!"
	elif [ "$(is_email_format $account)" = "false" ]; then
		echo "$account is not email format!!"
	elif [ -f "$nicknameLink" ]; then
		echo "Nickname, $nickname, exist!!"
	elif [ -f "$mobileLink" ]; then
		echo "MobilePhone, $mobilephone, exist!!"
	else
		create_account_folder_tree "$account" "$nickname" "$mobilephone"
		create_profile_json "$account" "$nickname" "$mobilephone" $level
		
		echo "$(to_lowercase $account)" >> ${YIABI_STATIC_DATA_DIR}/special_account_list.txt
	fi
fi
