#!/bin/bash
export PATH="/usr/bin:/usr/sbin:/sbin:/bin"

eval "echo \"`cat $HOME/upstream-ssl.template`\"" >> /etc/nginx/sites-available/underplan-ssl

# Create the logs dir in the site-data shared volume
# TODO: the site-data directory should be available in env variable
#       so that it can be set when calling "docker run"
mkdir -p /site-data/logs/nginx

# Start services
/usr/bin/supervisord -n