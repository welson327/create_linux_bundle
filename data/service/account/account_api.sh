#!/bin/bash

source "/yiabi/path.sh"
source "$YIABI_SERVICE_DIR/util.sh"

get_account_dir() {
	account="$1"
	initChar="${account:0:1}"
	
	#account_dir="$YIABI_WEBUSER_DIR/${initChar,,}/$account"
	account_dir="$YIABI_WEBUSER_DIR/$(to_lowercase $initChar)/$account"
	
	echo "$account_dir"
}

create_account_folder_tree() {
	account="$1"
	nickname="$2"
	mobilephone="$3"
	
	account_dir="$(get_account_dir $account)"
	
	#if [ ! -d ${account_dir} ]; then
		mkdir -p ${account_dir}/apk
		mkdir -p ${account_dir}/image
		mkdir -p ${account_dir}/txt
		mkdir -p ${account_dir}/zipsend
		chmod -R 777 ${account_dir}
		chown -R webuser:webuser ${account_dir}

		# json profile: not exist, but still create link
		jsonFile="${account_dir}/${account}.json"

		# symbolic link
		if [ ! -z "$account" ]; then
			ln -sf ${jsonFile} ${YIABI_WEBUSER_SOFTLINK_DIR}/${account}
		fi
		if [ ! -z "$nickname" ]; then
			ln -sf ${jsonFile} ${YIABI_WEBUSER_SOFTLINK_DIR}/${nickname}
		fi
		if [ ! -z "$mobilephone" ]; then
			ln -sf ${jsonFile} ${YIABI_WEBUSER_SOFTLINK_DIR}/${mobilephone}
		fi
	#fi
}

get_account_profile_json() {
	# password: yiabi1234
	hashPassword="5052C030CED4EEBE809486F5CC828C1C34FB488846F7F8FEA0B90363777F88A6"

	createTime="$(date +%s)000"
	
	accountOnRegister="$1"
	account="$(to_lowercase $1)"
	nicknameOnRegister="$2"
	nickname="$2"
	mobile="$3"
	level="$4"
	
	jsonStr="{\
		\"accessToken\":\"\",\
		\"account\":\"$account\",\
		\"accountOnRegister\":\"$accountOnRegister\",\
		\"createTime\":$createTime,\
		\"birthday\":\"\",\
		\"expiryDate\":\"2050-12-31\",\
		\"firstName\":\"\",\
		\"gender\":\"\",\
		\"lastName\":\"\",\
		\"level\":$level,\
		\"nickname\":\"$nickname\",\
		\"nicknameOnRegister\":\"$nicknameOnRegister\",\
		\"ownerUid\":\"$account\",\
		\"password\":\"$hashPassword\",\
		\"phoneNumber\":\"\",\
		\"mobile\":\"$mobile\"\
	}"
	
	# remove whitespace|tag
	jsonStr=$(echo $jsonStr | sed -e "s/\s\{1,\}//g")
	
	echo "$jsonStr"
}


