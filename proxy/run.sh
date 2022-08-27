#!/bin/sh

NAME=proxy

docker kill ${NAME}-container
docker rm ${NAME}-container
docker build -t ${NAME}-image .
docker run --name ${NAME}-container -d -p 80:80 -p 443:443 -v $PWD:/usr/share/nginx/html ${NAME}-image
docker exec -ti ${NAME}-container /bin/bash
