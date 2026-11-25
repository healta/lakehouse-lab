#!/bin/sh
# Creates .env with random secrets. Safe to run again: it never overwrites an existing .env.
#   sh make-env.sh           this machine only, data in Docker volumes
#   sh make-env.sh truenas   open to your network, data in ./data, files owned by the apps user (568)
set -eu
cd "$(dirname "$0")"

BIND_IP=127.0.0.1
OWNER=1000
DATA=""

if [ "${1:-}" = truenas ]; then
  BIND_IP=0.0.0.0
  OWNER=568
  DATA="
# Where data is kept
POSTGRES_DATA=$PWD/data/postgres
S3_DATA=$PWD/data/s3
AIRFLOW_LOGS=$PWD/data/airflow-logs"
  mkdir -p data/postgres data/s3 data/airflow-logs
  chown 10001:10001 data/s3
  chown 50000:0 data/airflow-logs
  chown -R 568:568 notebooks dags dbt
fi

if [ -e .env ]; then echo ".env already exists, kept as it is"; exit 0; fi

rand() { head -c "$1" /dev/urandom | od -An -tx1 | tr -d ' 
'; }
PASSWORD=$(rand 10)

umask 077
cat > .env <<ENV
# One password for everything. User name: lab
LAB_PASSWORD=$PASSWORD

# Used inside Airflow only
FERNET_KEY=$(head -c 32 /dev/urandom | base64 | tr '+/' '-_')
SIGNING_KEY=$(rand 32)

# 127.0.0.1 = this machine only. 0.0.0.0 = everyone on your network.
BIND_IP=$BIND_IP

# Memory for Spark
SPARK_MEMORY=2g

# Owner of the notebooks, dags and dbt folders
LAB_UID=$OWNER
LAB_GID=$OWNER
$DATA
ENV
echo "Created .env. User: lab  Password: $PASSWORD"
