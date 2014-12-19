#!/bin/bash

safe_restart_mongod() {
	mkdir -p /mongodata/
	/usr/bin/mongod --shutdown --dbpath /mongodata/
	/usr/bin/mongod -f /etc/mongod.conf &
}
	
safe_restart_mongod
