#!/bin/bash

TIME=$(date +%s)

sudo apt-key update
sudo apt-get update
sudo apt-get install -y --allow-unauthenticated iftop iputils-* lynx net-tools netcat vim wget \
  python3-pip \
  docker.io \ 
  mysql-server libmysqlclient-dev libopenssl-dev &&

sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
  sudo chmod +x /usr/local/bin/docker-compose &&

sudo usermod -a -G docker $USER
