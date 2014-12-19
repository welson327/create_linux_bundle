#!/bin/bash

source "change_version.sh"

echo "Old version = $(get_current_version)"


tmpfolder=$(mktemp -d /tmp/tmp.XXXXXXXX)
ver="$(promote_version)"
tmpbin="${tmpfolder}/install.bin"
bin="output_bin/yiabi_installer-${ver}.bin"


WAR_HOME="/Users/welson/_share/war"
TAR="servicedata.tar.gz"

mkdir -p output_bin/ok

#~ cp -rf data ${tmpfolder}
#~ cp -rf init_server.sh ${tmpfolder}
#~ #cp -rf extract.sh $tmpbin
if [ ! -d "${WAR_HOME}" ]; then
	echo "${WAR_HOME} is not found!"
	exit
else
	mkdir -p data/war
	rm -rf data/war/*.war
	cp -rf ${WAR_HOME}/*.war data/war
fi

#tar --exclude-vcs -czf $TAR data windows
tar -czf $TAR data windows
cat init_server.sh $TAR >> $tmpbin
chmod +x $tmpbin
cp -f $tmpbin $bin

rm -rf ${tmpfolder}


echo "New version = $(get_current_version)"
