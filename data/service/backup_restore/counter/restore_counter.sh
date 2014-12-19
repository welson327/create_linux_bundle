#!/bin/bash

#dumpedName="$1"
PORT="8080"
ts="$(date +%Y-%m-%d)"
browsingCounterDumpedName="BrowsingCounter_dump_${ts}.txt"
cuttingCounterDumpedName="CuttingCounter_dump_${ts}.txt"

restore_counter_mapdb() {
	echo "Restore ${browsingCounterDumpedName} ..."
	curl localhost:${PORT}/beagle/browsingCount?action=restore\&dumpedName=${browsingCounterDumpedName}

	echo -e
	echo -e

	echo "Restore ${cuttingCounterDumpedName} ..."
	curl localhost:${PORT}/beagle/cuttingCount?action=restore\&dumpedName=${cuttingCounterDumpedName}
}

read -p "Please input the hostname: " inputHostName
if [ "${inputHostName}" != "$(hostname)" ]; then
	echo "Sorry! Hostname mis-match! 881~"
else
	dumpedPath="/yiabi/backup/${browsingCounterDumpedName}"
	
	if [ -f "${dumpedPath}" ]; then
		echo -e
		restore_counter_mapdb
		echo -e
		echo "Restore counter mapdb successfully!~ 881~"
	else
		echo -e
		echo "${dumpedPath} not found!!!!!~ 881~"
	fi
fi
