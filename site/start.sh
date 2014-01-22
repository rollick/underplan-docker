#!/bin/bash

export METEOR_SETTINGS="$(curl $CONFIG_URL)"
export MONGO_URL="mongodb://$DB_PORT_27017_TCP_ADDR:$DB_PORT_27017_TCP_PORT/underplan"

# Start services
/usr/bin/supervisord -n