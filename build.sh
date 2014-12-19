#!/bin/bash

source "change_version.sh"

echo "Old version = $(get_current_version)"


tmpfolder=$(mktemp -d /tmp/tmp.XXXXXXXX)
ver="$(promote_version)"
tmpbin="${tmpfolder}/install.bin"
bin="output_bin/yiabi_installer-${ver}.bin"


PACK_DATA_HOME="/Users/welson/rails/wels"
TAR="servicedata.tar.gz"

mkdir -p output_bin/ok

#~ cp -rf data ${tmpfolder}
#~ cp -rf init_server.sh ${tmpfolder}
#~ #cp -rf extract.sh $tmpbin
if [ ! -d "${PACK_DATA_HOME}" ]; then
	echo "${PACK_DATA_HOME} is not found!"
	exit
else
	mkdir -p data/rails
	rm -rf data/rails/*
	cp -rf ${PACK_DATA_HOME}/* data/rails
fi

#tar --exclude-vcs -czf $TAR data windows
tar -czf $TAR data
cat init_server.sh $TAR >> $tmpbin
chmod +x $tmpbin
cp -f $tmpbin $bin

rm -rf ${tmpfolder}


echo "New version = $(get_current_version)"
