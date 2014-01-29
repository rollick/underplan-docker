#!/bin/sh

# Defaults
DOCKER_OPTIONS="-H=tcp://localhost:9090";
CONTAINERS="db-data db site-data site-bundle site proxy"

usage () {
  echo "Usage of $0"
  echo "-s container_name: Build a single container"
  echo "-o docker_options: Docker options"
}

while getopts "s:o:h" option; do
  case "$option" in
    s)  CONTAINERS="$OPTARG" ;;
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

for name in $CONTAINERS; do
    echo "++ Building underplan/$name."
    docker $DOCKER_OPTIONS build -t underplan/$name $name
    echo ""
done