#!/bin/bash

source "/yiabi/path.sh"
source "$YIABI_SERVICE_DIR/account/account_api.sh"

account="$1"
nickname="$2"
mobilephone="$3"

# main
create_account_folder_tree "$account" "$nickname" "$mobilephone"
