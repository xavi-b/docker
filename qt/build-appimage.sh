#!/bin/bash

set -xe

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATE=`date +%Y%m%d`

mkdir -p $PWD/output/$DATE/$1
mkdir -p $PWD/logs/$DATE

#Build
docker build -f Dockerfile.QtAppImage -t qtappimage .

docker run \
    --name $1-$DATE \
    -v $DIR:/input \
    -v $PWD/app:/data \
    -v $PWD/output/$DATE:/output \
    -e "APP_NAME=$1" \
    qtappimage \
    /input/build-appimage-daily.sh $(id -u)

#Save the logs!
docker logs $1-$DATE > $PWD/logs/$DATE/$1

#Kill the container!
docker rm $1-$DATE

# remove all but the latest 5 dailies
/bin/ls -t $PWD/output | awk 'NR>6' | xargs rm -fr
