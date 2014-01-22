############################################################
# Dockerfile to run Underplan MongoDB Containers
# Based on Ubuntu Image
############################################################

# Running the container:
# docker run 
#  -e AWS_S3_BUCKET=foo \
#  -e AWS_ACCESS_KEY=bar \
#  -e AWS_SECRET_KEY=blah \
#  -e MONGO_BACKUP_PASSWD=yada \
#  ....

# Set the base image to use to Ubuntu
FROM stackbrew/ubuntu:13.04

# Set the file maintainer
MAINTAINER rollick

ENV HOME /root

# Install Mongo
RUN apt-get update
RUN apt-get install -y mongodb git-core curl s3cmd supervisor cron

# Setup s3cmd config
RUN /bin/echo -e '[default]\naccess_key=$AWS_ACCESS_KEY\nsecret_key=$AWS_SECRET_KEY' > $HOME/.s3cfg

# Add scripts
ADD start.sh $HOME/
ADD scripts/s3_backup.sh $HOME/
ADD scripts/s3_restore.sh $HOME/
RUN chmod +x $HOME/*.sh
RUN chown root: $HOME/*.sh

# Add db backup cron job
RUN crontab -l | { cat; echo "0 0 * * * /bin/bash /root/s3_backup.sh 2>&1 >> /root/backup.log"; } | crontab -

# Install supervisor
ADD Supervisorfile /etc/supervisor/conf.d/mongo.conf

# Port to expose
EXPOSE 27017

# run supervisor
CMD ["/bin/bash", "/root/start.sh"]