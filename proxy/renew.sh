#!/bin/sh

NAME=proxy

docker exec -ti ${NAME}-container certbot --renew-by-default
