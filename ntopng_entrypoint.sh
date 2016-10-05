#!/bin/bash

set -e

MTA_DIR=malware_traffic_analysis
MTA_PWD=infected

# start the local redis server
sudo service redis-server start

function malware_traffic_analysis {
    mkdir -p ${MTA_DIR}

    if [ "x$2" != "x" ]; then
	MTA_PWD="$2"
    fi

    echo "Downloading $1 in ${MTA_DIR}"
    
    cd ${MTA_DIR}

    wget -nd -e robots=off --recursive --no-parent --level=1 --accept=zip "$1"

    # delete possible non-zip files
    find . -type f -not -name '*.zip' -exec rm -rf {} \;

    # unzip downloaded files
    find . -type f -name '*.zip' -exec unzip -P "${MTA_PWD}" {} \;

    # list downloaded and extracted files
    ls -lX | grep -v pcap$
    ls -lX | grep  pcap$

    # cd -
    
    # finally start the bash
    exec bash
}


if [ "$1" = 'malware-traffic-analysis' ]; then
    if [ "$#" -lt 2 ]; then
	echo -e "Please provide an url as second parameter to download zip files. Example"
	echo -e "malware-traffic-analysis http://malware-traffic-analysis.net/2016/09/06/index.html"
	exit 1
    fi

    shift 1
    malware_traffic_analysis "$@"
elif [ "$1" = 'shell' ]; then
    echo -e "Enterning ntopng container in shell (interactive) mode"
    exec bash
else
    # can use this to run ntopng in the background for example
    exec "$@"
fi
