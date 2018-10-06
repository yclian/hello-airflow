#!/bin/bash

TIME=$(date +%s)

mkdir -p apps/
cd apps/

# https://airflow.apache.org/installation.html
# https://airflow.apache.org/start.html
# https://airflow.apache.org/security.html
export AIRFLOW_HOME=/home/ubuntu/apps/airflow
mkdir -p airflow
AIRFLOW_GPL_UNIDECODE=1 pip3 install apache-airflow[kubernetes,mysql,postgres,s3] flask_bcrypt > airflow-setup.log 2>&1
airflow initdb >> airflow-setup.log 2>&1
crontab -l | { cat; echo "@reboot AIRFLOW_HOME=$AIRFLOW_HOME airflow webserver -p 8080 > airflow.log 2>&1"; } | crontab -
crontab -l | { cat; echo "@reboot AIRFLOW_HOME=$AIRFLOW_HOME airflow scheduler > airflow-scheduler.log 2>&1"; } | crontab -

# Exec: ?

# https://superset.incubator.apache.org/installation.html
git clone https://github.com/apache/incubator-superset/ superset && \
  cd superset && \
  cp contrib/docker/{docker-build.sh,docker-compose.yml,docker-entrypoint.sh,docker-init.sh,Dockerfile} . && \
  cp contrib/docker/superset_config.py superset/ && \
  sudo bash -x docker-build.sh > superset-setup.log 2>&1

sudo docker-compose up -d
sudo docker-compose exec superset bash -c \
  "pip install click==6.7 sqlalchemy-redshift --user; \
   fabmanager create-admin --app superset --firstname YC --lastname L --email yc@servicerocket.com --username admin --password 9j8ibda1; \
   superset db upgrade; \
   superset init; \
   cd superset/assets && npm run build && cd ../../;" >> superset-setup.log 2>&1

sudo chown ubuntu:ubuntu -R ~/apps/superset

crontab -l | { cat; echo "@reboot cd /home/ubuntu/apps/superset && /usr/local/bin/docker-compose exec -T superset bash -c 'superset worker & superset runserver -d' > superset.log 2>&1"; } | crontab -
