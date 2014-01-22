#!/bin/bash
 
#Force file syncronization and lock writes
mongo admin --eval "printjson(db.fsyncLock())"

MONGODUMP_PATH="/usr/bin/mongodump"
MONGO_HOST="localhost"
MONGO_PORT="27017"
MONGO_DATABASE="underplan"
 
TIMESTAMP=`date +%F-%H%M`
S3_BUCKET_NAME="underplan"
S3_BUCKET_PATH="mongodb-backups"
 
# Create backup
$MONGODUMP_PATH -h $MONGO_HOST:$MONGO_PORT -d $MONGO_DATABASE
 
# Add timestamp to backup
MONGODUMP_NAME="mongodb-$TIMESTAMP-$HOSTNAME"
mv dump $MONGODUMP_NAME

if [[ -z "$MONGO_BACKUP_PASSWD" ]]; then
  TAR_NAME="$MONGODUMP_NAME.tar"
  tar cf $TAR_NAME $MONGODUMP_NAME
else
  echo "++ Creating encrypted backup"

  TAR_NAME="$MONGODUMP_NAME.tar.enc"
  tar --create --file - --posix --gzip -- $MONGODUMP_NAME | openssl enc -aes-256-cbc -k $MONGO_BACKUP_PASSWD -e -out $TAR_NAME
fi
 
# Upload to S3
s3cmd put $TAR_NAME \
  s3://$S3_BUCKET_NAME/$S3_BUCKET_PATH/$TAR_NAME

#Unlock database writes
mongo admin --eval "printjson(db.fsyncUnlock())"

# Delete dump and tar files
rm -Rf $MONGODUMP_NAME* $TAR_NAME
