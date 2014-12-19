#!/bin/bash

source "/yiabi/path.sh"

book_last3() {
	bookId="$1"
	len="${#bookId}"
	last3="${bookId:$len-3:$len-1}"
	echo "$last3"
}
book_last3_root() {
	last3="$(book_last3 $1)"
	last3RootPath="${YIABI_EBOOKLIB_DIR}/${last3}"
	echo "${last3RootPath}"
}

clone_ebook() {
	srcBookId="$1"
	dstBookId="$2"
	
	srcBookLast3="$(book_last3 $srcBookId)"
	dstBookLast3="$(book_last3 $dstBookId)"
	
	srcBookRoot="$(book_last3_root $srcBookId)/$srcBookId"
	dstBookRoot="$(book_last3_root $dstBookId)/$dstBookId"
	
	echo "srcBookRoot => $srcBookRoot" 
	echo "dstBookRoot => $dstBookRoot" 
	
	filelist=$(find ${srcBookRoot} -type f -name '*')
	for srcFilePth in ${filelist[@]}; do
		# not add "" for ${str/pattern/replacement}
		dstFilePth=${srcFilePth//${srcBookId}/${dstBookId}}
		dstFilePth=${dstFilePth/\/${srcBookLast3}\//\/${dstBookLast3}\/}
		
		dstDirPath=$(dirname $dstFilePth)
		if [ ! -d "$dstDirPath" ]; then
			echo "mkdir -p $dstDirPath"
			mkdir -p ${dstDirPath}
		fi
		
		echo "cp -rf $srcFilePth $dstFilePth"
		cp -rf ${srcFilePth} ${dstFilePth}
	done
	
	echo "chmod 755 -R ${dstBookRoot}"
	chmod 755 -R ${dstBookRoot}
}

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Argument 1(src bookId) or 2(dst bookId) is required!"
else
	clone_ebook "$1" "$2"
fi
