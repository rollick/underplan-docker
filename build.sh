#!/bin/sh

DOCKER_OPTIONS=$1
CONTAINERS='db-data db site-data site-bundle site proxy'

for name in $CONTAINERS; do
    echo "++ Building underplan/$name."
    docker $DOCKER_OPTIONS build -t underplan/$name $name
    echo ""
done