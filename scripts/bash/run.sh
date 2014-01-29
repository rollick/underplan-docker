#!/bin/sh

set -e

CONTAINERS=("db-data" "db" "site-data" "site-bundle" "site" "proxy")
DOCKER_OPTIONS="-H=tcp://localhost:9090"

runContainer () {
  local e
  for e in "${CONTAINERS[@]}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

usage () {
  echo "Usage of $0"
  echo "-v: Also create volumes"
  echo "-s container_name: Run a single container"
  echo "-o docker_options: Docker options"
}

while getopts "vs:o:h" option; do
  case "$option" in
    v)  CREATE_VOLUMES=true ;;
    s)  CONTAINERS=("$OPTARG") ;;
    o)  DOCKER_OPTIONS="$OPTARG" ;;
    h)  usage
        exit 0 
        ;;
    :)  echo "Error: -$option requires an argument" 
        usage
        exit 1
        ;;
    ?)  echo "Error: unknown option -$option" 
        usage
        exit 1
        ;;
  esac
done

if runContainer "db-data" && [ $CREATE_VOLUMES ]; then
  echo "++ Creating DB data container"
  docker $DOCKER_OPTIONS run -name db-data -t -d underplan/db-data
else
  echo "-- Skipping db data container"
fi

if runContainer "db" ; then
  echo "++ Running mongodb container"
  docker $DOCKER_OPTIONS run -name db -volumes-from db-data -d -t -p 127.0.0.1:27017:27017 -e AWS_S3_BUCKET=underplan -e AWS_ACCESS_KEY=$AWS_ACCESS_KEY -e AWS_SECRET_KEY=$AWS_SECRET_KEY -e MONGO_BACKUP_PASSWD=$MONGO_BACKUP_PASSWD underplan/db
else
  echo "-- Skipping DB container"
fi

if runContainer "site-data" && [ $CREATE_VOLUMES ]; then
  echo "++ Creating site data container"
  docker $DOCKER_OPTIONS run -name site-data -t -d underplan/site-data
else
  echo "-- Skipping site data container"
fi

if runContainer "site-bundle" ; then
  echo "++ Deploy site to site-data container"
  docker $DOCKER_OPTIONS run -volumes-from site-data -e UNDERPLAN_REPO_URL=$UNDERPLAN_REPO_URL underplan/site-bundle
else
  echo "-- Skipping site deploy"
fi

if runContainer "site" ; then
  echo "++ Running site container"
  docker $DOCKER_OPTIONS run -name site -link db:db -volumes-from site-data -d -t -e CONFIG_URL=$UNDERPLAN_CONFIG_URL -e ROOT_URL=$UNDERPLAN_ROOT_URL underplan/site
else
  echo "-- Skipping site container"
fi

if runContainer "site-bundle" ; then
  echo "++ Running proxy container for site"
  docker $DOCKER_OPTIONS run -name proxy -volumes-from site-data -link site:upstream -p 80:80 -p 443:443 -d -t underplan/proxy
else
  echo "-- Skipping proxy container"
fi