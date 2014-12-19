#!/bin/bash

source "/yiabi/path.sh"
source "$YIABI_SERVICE_DIR/account/account_api.sh"

account="$1"
nickname="$2"
mobilephone=""

# main
if [ "$account" = "yiabiadmin@yiabi.com" ]; then
	initChar="${account:0:1}"
	
	account_dir="$YIABI_WEBUSER_DIR/$(to_lowercase $initChar)/$account"

	create_account_folder_tree "$account" "$nickname" "$mobilephone"
	cp ${YIABI_ETC_DIR}/${account}.json ${account_dir}
else
	echo "Create admin error: Input error!"
fi

