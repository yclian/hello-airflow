#!/bin/bash

TIME=$(date +%s)

mkdir -p apps/
cd apps/

# https://airflow.apache.org/installation.html
AIRFLOW_GPL_UNIDECODE=1 pip3 install apache-airflow[mysql,s3]

# Exec: ?

# https://superset.incubator.apache.org/installation.html
git clone https://github.com/apache/incubator-superset/ superset && \
  cd superset && \
  cp contrib/docker/{docker-build.sh,docker-compose.yml,docker-entrypoint.sh,docker-init.sh,Dockerfile} . && \
  cp contrib/docker/superset_config.py superset/ && \
  sudo bash -x docker-build.sh 

sudo docker-compose up -d
sudo docker-compose exec superset bash -c \
  "pip install click==6.7 sqlalchemy-redshift --user; \
   fabmanager create-admin --app superset --firstname YC --lastname L --email yc@servicerocket.com --username admin --password 9j8ibda1; \
   superset db upgrade; \
   superset init; \
   cd superset/assets && npm run build && cd ../../;"
sudo chown ubuntu:ubuntu -R ~/apps/superset
crontab -l | { cat; echo "@reboot cd /home/ubuntu/apps/superset && /usr/local/bin/docker-compose exec -T superset bash -c 'superset worker & superset runserver -d' > superset.log 2>&1"; } | crontab -
