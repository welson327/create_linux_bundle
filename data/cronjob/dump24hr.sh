#!/bin/bash

dump24hr() {
	
	rslt="$(curl localhost:80/pus/stat/count24hr?action=dump)"

	if [ -z "$rslt" ]; then
		echo "Try 8080 port: curl localhost:8080/pus/stat/count24hr?action=dump"
		rslt="$(curl localhost:8080/pus/stat/count24hr?action=dump)"
	fi

	sleep 1
	echo "$rslt"
}
	
dump24hr
