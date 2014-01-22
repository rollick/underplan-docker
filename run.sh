#!/bin/sh

set -e

CREATE_VOLUMES=$1

if [ $CREATE_VOLUMES ]; then
  echo "++ Creating data container for db."
  docker $DOCKER_OPTIONS run -name db-data -t -d underplan/db-data
else
  echo "-- Skipping creation of data container for db."
fi

echo "++ Creating mongodb container."
docker $DOCKER_OPTIONS run -name db -volumes-from db-data -d -t -e AWS_S3_BUCKET=underplan -e AWS_ACCESS_KEY=$AWS_ACCESS_KEY -e AWS_SECRET_KEY=$AWS_SECRET_KEY -e MONGO_BACKUP_PASSWD=$MONGO_BACKUP_PASSWD underplan/db

echo "++ Creating data container for site."
if [ $CREATE_VOLUMES ]; then
  docker $DOCKER_OPTIONS run -name site-data -t -d underplan/site-data
else
  echo "-- Skipping creation of data container for site."
fi

echo "++ Deploy site to site-data container."
docker $DOCKER_OPTIONS run -volumes-from site-data underplan/site-bundle

echo "++ Creating site container."
docker $DOCKER_OPTIONS run -name site -link db:db -volumes-from site-data -p 127.0.0.1:3000:3000 -d -t -e CONFIG_URL=$CONFIG_URL -e ROOT_URL=$UNDERPLAN_ROOT_URL underplan/site

echo "++ Creating proxy container for site"
docker $DOCKER_OPTIONS run -name proxy -volumes-from site-data -link site:upstream -p 80:80 -d -t underplan/proxy