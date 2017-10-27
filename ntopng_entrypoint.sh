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
elif [ "$1" = 'workspace' ]; then
    echo -e "Binding workspace directories..."
    #ln -s /home/ntopng/workspace/scripts /usr/share/ntopng/scripts/lua/scripts
    rm -f /home/ntopng/workspace/scripts/lua/myscripts
    cp -r /usr/share/ntopng/scripts /home/ntopng/workspace/scripts
    ln -s /home/ntopng/workspace/myscripts /home/ntopng/workspace/scripts/lua/myscripts
    chown -R ntopng:ntopng /home/ntopng/workspace/scripts
    #cp -r /usr/share/ntopng/httpdocs /home/ntopng/workspace/httpdocs

    su -c "redis-cli hset ntopng.host_labels 172.17.0.2 DEKSTOP-ULJ721" ntopng

    echo "Starting ntopng..."
    su -c "ntopng -2 /home/ntopng/workspace/scripts -i workspace/sample_malware_sites.pcap --community --disable-login 1" ntopng
    #exec bash
else
    # can use this to run ntopng in the background for example
    exec "$@"
fi
