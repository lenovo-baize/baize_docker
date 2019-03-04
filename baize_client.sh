#!/bin/bash

function bootIpfsPeer {
    index=$1
    hostName=ipfs_host_client_${index}

    ipfs_staging=/tmp/ipfs_staging_client_${index}
    rm -rf $ipfs_staging
    mkdir -p $ipfs_staging

    ipfs_data=/tmp/ipfs_data_client_${index}
    rm -rf $ipfs_data
    mkdir -p $ipfs_data

    echo "Creating ${hostName} ..."
    echo ${ipfs_data}
    echo ${ipfs_staging}
    echo $index
    docker run -d --name ${hostName} \
        -v ${ipfs_staging}:/export \
        -v ${ipfs_data}:/data/ipfs \
        -p $((4002 + index)):4001 \
        -p $((5002 + index)):5001 \
        -p 127.0.0.1:$((8090 + index)):8080 \
        baize_client:v1

}

function setupIpfsNetwork {
    for (( i=0; i<$1; i++ ))
    do
        bootIpfsPeer ${i}
    done
}

function rmIpfsHosts {
    dockerContainers=$(docker ps -a | awk '$2~/client/ {print $1}')
    if [ "$dockerContainers" != "" ]; then
       echo "Deleting existing docker containers ..."
       docker rm -f $dockerContainers
    fi
}

function showResult {
    docker ps -a
}

function main {
    rmIpfsHosts
    setupIpfsNetwork $1

    showResult
}

if [ "$#" -ne 1 ]; then
    echo "ERROR: Peers number must be set for private ipfs network"
    echo "usage: start.sh \${peerNumber}"
    echo "For example: Run this command"
    echo "                 ./start.sh 3"
    echo "             A private ipfs network with 3 peers will be setup locally"
    exit 1
else
    main $1
fi

