#!/bin/bash

# Restore
$HOME/s3_restore.sh /db-data

# Start services
/usr/bin/supervisord -n