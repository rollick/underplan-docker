#!/bin/bash

MONGO_DIR=$1
MONGORESTORE_PATH="/usr/bin/mongorestore"
MONGODUMP_PATH="/usr/bin/mongodump"
MONGO_HOST="localhost"
MONGO_PORT="27017"
MONGO_DATABASE="underplan"

S3_BUCKET_NAME="underplan"
S3_BUCKET_PATH="mongodb-backups"

# Fetch last backup from S3
BACKUP_URL=`s3cmd ls s3://$S3_BUCKET_NAME/$S3_BUCKET_PATH/* | tail -1 | awk '{print $4}'`

echo "Fetching Backup - $BACKUP_URL"
cd /tmp

# Fetch the backup tar file
s3cmd get --force $BACKUP_URL

TIMESTAMP=`date +%F-%H%M`
BACKUP_FILENAME=$(basename "$BACKUP_URL")
BACKUP_DIR="mongodb-$TIMESTAMP-$HOSTNAME"

mkdir $BACKUP_DIR && cd $BACKUP_DIR
# Extract the backup files
if [[ -z "$MONGO_BACKUP_PASSWD" ]]; then
  tar -xvf --strip-components 1 $BACKUP_FILENAME
else
  echo "++ Extracting encrypted backup"
  openssl enc -in ../$BACKUP_FILENAME -aes-256-cbc -d -k $MONGO_BACKUP_PASSWD | tar --strip-components 1 -xzvf -
fi

if [[ -z "$MONGO_DIR" ]]; then
  #Force file syncronization and lock writes
  mongo admin --eval "printjson(db.fsyncLock())"

  # Restore backup to running mongodb service
  $MONGORESTORE_PATH -h $MONGO_HOST:$MONGO_PORT --db $MONGO_DATABASE $MONGO_DATABASE --drop
  
  #Unlock database writes
  mongo admin --eval "printjson(db.fsyncUnlock())"
else
  # Restore backup to shared directory - dropping any existing db files
  $MONGORESTORE_PATH --dbpath $MONGO_DIR --db $MONGO_DATABASE $MONGO_DATABASE --drop
fi

# Delete dump file and directory
rm -Rf $BACKUP_FILENAME $BACKUP_DIR