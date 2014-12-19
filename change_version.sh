#!/bin/bash

VERSION="version.txt"
MAX="9999"

addition_level="$1"

get_current_version() {
	echo "$(cat $VERSION)"
}

get_new_version() {
	
	old="$(get_current_version)"
	
	if [ -z "$old" ]; then
		old="0.0.1"
	fi
	
	digit1="$(echo $old | cut -d'.' -f1)"
	digit2="$(echo $old | cut -d'.' -f2)"
	digit3="$(echo $old | cut -d'.' -f3)"
	
	case "${addition_level}" in
		"1") # from 1.2.3 --> 2.0.0
			digit1=$(($digit1 + 1))
			digit2=0
			digit3=0
			;;
			
		"2") # from 1.2.3 --> 1.3.0
			digit2=$(($digit2 + 1))
			digit3=0
			;;

		"none")
			;;
			
		*) # from 1.2.3 --> 1.2.4
			digit3=$(($digit3 + 1))
			if [ $digit3 -gt $MAX ]; then
				digit2=$(($digit2 + 1))
				digit3=0
			fi
			if [ $digit2 -gt $MAX ]; then
				digit1=$(($digit1 + 1))
				digit2=0
			fi
			;;
	esac
	
	echo "${digit1}.${digit2}.${digit3}"
}

promote_version() {
	new_version="$(get_new_version)"
	echo "$new_version" > "$VERSION"
	echo "$(get_current_version)"
}

## main
	# echo "Old version = $(get_current_version)"
	# echo "New version = $(promote_version)"
