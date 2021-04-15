#!/bin/bash

USERNAME=$1
PASSWORD=$2
ACME_MAIL="YOUR@MAIL"
YOUR_DOMAIN="monitor.yourdomain.here"

DOCKER=$(which docker)
DOCKER_COMPOSE=$(which docker-compose)
STATIC_FILE="$(pwd)/traefik.toml"
DYNAMIC_FILE="$(pwd)/traefik_dynamic.toml"
LOG_DIR="/var/log/traefik"

echo "-------------- INSTALLING DEPENDENCIES --------------"

sudo curl -fsSL https://get.docker.com | bash
sudo apt install apache2-utils docker-compose

echo "-------------- CREATING DOCKER NETWORK WEB --------------"

$DOCKER network create web

echo "-------------- CREATING CREDENTIALS FOR MONITORING WEBSITE --------------"

CREDENTIALS=$($(which htpasswd) -nb $USERNAME $PASSWORD | cut -d " " -f 3)
sed -i "s/PLEASEREPLACEME/"$CREDENTIALS"/g" $DYNAMIC_FILE
sed -i "s/YOURDOMAIN/"$YOUR_DOMAIN"/g" $DYNAMIC_FILE
sed -i "s/PLEASEREPLACEMAIL/"$ACME_MAIL"/g" $STATIC_FILE

echo "-------------- PREPARING NOW TRAEFIK CONTAINER --------------"

mkdir -p $LOG_DIR
$DOCKER_COMPOSE up -d

echo "-------------- FINISHED --------------"
