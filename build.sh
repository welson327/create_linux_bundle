#!/bin/bash

source "change_version.sh"
source "data/path.sh"

echo "Old version = $(get_current_version)"

ver="$(promote_version)"
tmpfolder=$(mktemp -d /tmp/tmp.XXXXXXXX)
tmpbin="${tmpfolder}/install.bin"
tmpdata="${tmpfolder}/data"
tmp_rails_home="${tmpdata}/ws/rails"
bin="output_bin/myapp_installer-${ver}.bin"

RAILS_REPO_HOME="$1"
TAR="servicedata.tar.gz"

prepare_data() {
	mkdir -p ${tmpdata}
	mkdir -p output_bin

	echo "cp -rf data/* ${tmpdata}"
	cp -rf data/* ${tmpdata}

	# drop softlink
	echo "Remove softlink:"
	echo "rm -rf ${tmp_rails_home}/public/sitemap"
	rm -rf ${tmp_rails_home}/public/sitemap
	echo "rm -rf ${tmp_rails_home}/public/temp"
	rm -rf ${tmp_rails_home}/public/temp

	# drop log,tmp file
	echo "Drop ${tmp_rails_home}/log/*"
	rm -rf ${tmp_rails_home}/log/*
	echo "Drop ${tmp_rails_home}/tmp/*"
	rm -rf ${tmp_rails_home}/tmp/*
}


if [ ! -d "${RAILS_REPO_HOME}" ]; then
	# RAILS_REPO_HOME="data/ws/rails"
	echo "Argument 1, ws_folder_path, is not found!"
	exit
else
	prepare_data
fi


if [[ "$OSTYPE" == *win* ]]; then 
	# mac, unix
	tar --exclude=.svn --exclude=.git -czf $TAR -C ${tmpfolder} .
else
	# linux
	tar --exclude-vcs -czf $TAR -C ${tmpfolder} .
fi
cat init_server.sh $TAR >> $tmpbin
chmod +x $tmpbin
mv -f $tmpbin $bin

echo "rm -rf ${tmpfolder} ..."
rm -rf ${tmpfolder}


echo "New version = $(get_current_version)"