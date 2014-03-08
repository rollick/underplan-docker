#!/bin/bash

export METEOR_SETTINGS="$(curl -L $CONFIG_URL)"
export MONGO_URL="mongodb://$DB_PORT_27017_TCP_ADDR:$DB_PORT_27017_TCP_PORT/underplan"
export UNDERPLAN_PATH="/site-data/underplan"
# NOTE: set MAIL_URL to enable sending of emails
# export MAIL_URL="smtp://localhost:25/"
export PORT=3000

# Create log dir
mkdir -p /site-data/logs

# Start services
cd /site-data/underplan/
forever -a -l /site-data/logs/forever.log -o /site-data/logs/site.log -e /site-data/logs/site_error.log main.js