#!/bin/bash

# ============================================================
# Purpose: 	  
# Parameter:
# Remark:		MAC OS: $OSTYPE = darwin
# Author:		Welson
# ============================================================
is_mac() {
	if [[ "$OSTYPE" == *win* ]]; then
		echo "true"
	else
		echo "false"
	fi
}

to_lowercase() {
	s="$1"
	if [ $(is_mac) = "true" ]; then
		echo $(echo $s | tr [:upper:] [:lower:])
	else
		echo ${s,,}
	fi
}

to_uppercase() {
	s="$1"
	if [ $(is_mac) = "true" ]; then
		echo $(echo $s | tr [:lower:] [:upper:])
	else
		echo ${s^^}
	fi
}


json_drop_brace() {
	# drop '{' and '}'
	json="$1"
	
	if [ -z "$json" ]; then
		echo ""
	else
		echo "${json:1:${#json}-2}"
	fi
}

json_get_value() {
	_key="$2"
	json=$(json_drop_brace "$1")
	value=""
	
	cnt=1
	while true; do
		# get key   --> -d':' -f1
		# get value --> -d':' -f2
		key="$(echo $json | cut -d',' -f$cnt | cut -d':' -f1)"	
		key="$(json_drop_brace $key)" # drop Quote(")
		
		if [ "$key" = "$_key" ]; then
			value="$(echo $json | cut -d',' -f$cnt | cut -d':' -f2)"
			break
		elif [ -z "$key" ]; then
			value=""
			break
		else
			cnt=$(($cnt+1))
		fi
	done 
	echo "$value"
}

bash_yesno_prompt() {
	yesno=""
	msg="$1"
	
	while [ -z "$yesno" ]; do
		read -p "$msg (y/n) " yesno
	done
	
	if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
		echo "yes"
	else
		echo "no"
	fi
}

bash_linefeed() {
	lines=$1
	for ((i=0; i<lines; i++)); do
		echo ""
	done
}

bash_check_mountpath() {
	path="$1"
	
	# remove last char '/'
	if [ $(bash_lastchar "$path") = "/" ]; then
		path="$(dirname $path)/$(basename $path)"
	fi
	
	cnt=$(df | grep "$path" | wc -l)
	if [ $cnt -gt 0 ]; then
		echo "true"
	else
		echo "false"
	fi
}

# =====================================================
# Purpose:     	Get last character
# Parameters:	
# Return:		
# Remark:
# Author: 		welson
# ===================================================== 
bash_lastchar() {
	str="$1"
	echo "${str:${#str}-1:1}"
}

bash_substr() {
	str="$1"
	start_index=$2
	echo "${str:$start_index:${#str}}"
}

bash_strcmp() {
	s1="$1"
	s2="$2"
	if [[ ${s1} > ${s2} ]]; then
    echo "1"
  elif [[ ${s1} == ${s2} ]]; then
    echo "0"
  else
    echo "-1"
  fi
}

# ============================================================
# Purpose: 	  Check if s1 include s2
# Parameter:
# Remark:		
# Author:		  Welson
# ============================================================
bash_strstr() {
	s1="$1"
	s2="$2"
	if [[ ${s1} == *${s2}* ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# ============================================================
# Purpose: 		MD5 a folder
# Parameter: 	$1: folder full path
# Remark:		This is a very restrict API, any modification 
#				of foler results in different md5.
# Author:		Welson
# ============================================================
md5_folder() {
	
	folder_path="$1"
	
	md5=$(find "$folder_path" -type f -name '*' -exec md5sum {} + | awk '{print $1}' | \
	sort | \
	md5sum | \
	awk '{print $1}'\
	)
	
	echo "$md5"
}

# ============================================================
# Purpose: 		MD5 a folder tree
# Parameter: 	$1: folder full path
# Remark:		Only to get md5 of folder structure
# Author:		Welson
# ============================================================
md5_folder_tree() {
	
	folder_path="$1"
	
	# get md5: find . -name '*' | xargs ls --full-time -lu | awk '{print $9}' | md5sum
	# get 1st column of md5 result: awk '{print $1}'
	#g_md5=$(find . -name '*' | xargs ls --full-time -lu | awk '{print $9}' | md5sum | awk '{print $1}')
	
	md5=$(find "$folder_path" -name '*' | \
	xargs ls --full-time -lu | awk '{print $9}' | \
	md5sum | \
	awk '{print $1}'\
	)
	
	echo "$md5"
}

# ============================================================
# Purpose: 		check input regex
# Parameter: 	
# Remark:		
# Author:		Welson
# ============================================================
is_alnum() {
	cnt=$(echo "$1" | grep "[^[:alnum:]]" | wc -l)
	if [ $cnt -eq 0 ]; then
		echo "true"
	else
		echo "false"
	fi
}
is_digit() {
	cnt=$(echo "$1" | grep "[^[:digit:]]" | wc -l)
	if [ $cnt -eq 0 ]; then
		echo "true"
	else
		echo "false"
	fi
}
is_ip_number() { # not ready
	ip=$1
	#cnt=$(echo "$ip" | grep "(^[1-9][0-9]*)(\.[[:digit:]]+){3}" | wc -l)
	cnt=$(echo "$ip" | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | wc -l)
	if [ $cnt -gt 0 ]; then
		echo "true"
	else
		echo "false"
	fi
}
is_port_number() {
	port=$1
	cnt=$(echo "$port" | grep "^[1-9][0-9]*" | wc -l)
	if [ $cnt -gt 0 ] && [ $port -ge 0 ] && [ $port -le 65535 ]; then
		echo "true"
	else
		echo "false"
	fi
}

# ============================================================
# Purpose: 		get ver. number bin BIN name
# Parameter: 	
# Return:     input: cosa-1.5.6.bin, output:1.5.6
# Remark:		  Format must be xxxxx-1.2.3.bin, where xxxxx should be alnum or underline
# Author:		  Welson
# ============================================================
version_get() {
  bin_name="$1"
  ver=$(echo ${bin_name} | cut -d'-' -f2 | sed 's/\([1-9\.]*\)\.bin/\1/')
  echo "$ver"
}

# ============================================================
# Purpose: 		version compare
# Parameter: 	
# Return:     (1,0,-1) ----> (>,=,<)
# Remark:		  format: 1.2.34 or 1.2.3.4, ... etc.
# Author:		  Welson
# ============================================================
version_compare() {
	v1="$1"
	v2="$2"
	
	i=1
	while true; do
		n1=$(echo $v1 | cut -d'.' -f $i)
		n2=$(echo $v2 | cut -d'.' -f $i)
		
		if [ -z "$n1" ] && [ -z "$n2" ]; then
			echo "0"
			break
		elif [ -z "$n1" ] && [ ! -z "$n2" ]; then
			echo "-1"
			break			
		elif [ ! -z "$n1" ] && [ -z "$n2" ]; then
			echo "1"
			break		
		else
			if [ $n1 -gt $n2 ]; then
				echo "1"
				break
			elif [ $n1 -lt $n2 ]; then
				echo "-1"
				break
			else
				i=$(($i+1))
				continue
			fi
		fi
  done
}

# =====================================================
# Purpose:     	Get the value of pattern 'key:value' in a file
# Parameters:	$1: config_file, $2: key 	
# Return:		value of key
# Remark:		#: left strip, %: right strip
# Author: 		welson
# ===================================================== 
keyvalue_info_get() {
	conf="$1"
	keyword="$2"
	
	cat "$conf" | while read line; do
		if [ "$line" != "" ]; then
			key=$(echo "$line" | cut -d':' -f1)
			if [ "$key" = "$keyword" ]; then
				#value=$(echo "$line" | cut -d':' -f2)
				value=$(echo ${line#*:})
				echo "$value"
				return
			fi
		fi
	done
}

## example
	#~ if [ $(bash_yesno_prompt "yes?") = "yes" ]; then
		#~ echo "do something ... yes"
	#~ else
		#~ echo "do something ... no"
	#~ fi

	#~ ips=("192.168.0.1" "0.168.10.1" "1.2.3.4" "0.a.0.0" "i2y43wrlkwj.")
	#~ for ip in ${ips[@]}; do
		#~ echo "$ip => $(is_ip_number "$ip")"
	#~ done
  
  
  #~ bin1="cosa-2.1.5.3.bin"
  #~ bin2="cosa_installer-2.1.5.23.bin"
  #~ ver1=$(version_get "$bin1")
  #~ ver2=$(version_get "$bin2")
  #~ echo $(version_compare $ver1 $ver2)
  #~ echo $(version_compare "" "1.2.4")
  
  #~ echo $(to_lowercase "abcDEF")
  #~ echo $(to_uppercase "abcDEF")
