Basic usage
===========

Clearing out the old images and containers

    docker rm $(docker ps -a -q)
    docker rmi $(docker images -a | grep "^<none>" | awk '{print $3}')

*Using Ruby Scripts*

Files are in ./scripts/ruby

*Using Bash Scripts*

Files are in ./scripts/bash

Build the images

    DOCKER_OPTIONS="-H=tcp://localhost:8000" ./build.sh 

Run the containers. Add true (or anything..) as argument to script to also create the data-only containers for db and site

    DOCKER_OPTIONS="-H=tcp://localhost:8000" ./run.sh true
