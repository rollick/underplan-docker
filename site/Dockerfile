############################################################
# Dockerfile to run Underplan Website Containers
# Based on Ubuntu Image
############################################################

# Running the container:
# docker run 
#  -e CONFIG_URL=foo \
#  -e ROOT_URL=bar \ 
#  ....

# Set the base image to use to Ubuntu
FROM stackbrew/ubuntu:13.04

# Set the file maintainer
MAINTAINER rollick

ENV HOME /root

###
# Install Node

RUN apt-get install -y --force-yes software-properties-common python python-setuptools
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get -y update
RUN apt-get install -y nodejs curl supervisor mongodb-clients

# Install supervisor
ADD Supervisorfile /etc/supervisor/conf.d/meteor.conf

###
# Meteor App

# install meteor
RUN echo tlsv1 > $HOME/.curlrc
RUN curl https://install.meteor.com | /bin/sh -x
RUN npm install -g meteorite

# Port to expose
EXPOSE 3000

# Add startup script
ADD start.sh $HOME/
RUN chmod +x $HOME/start.sh
RUN chown root: $HOME/start.sh

# run supervisor
CMD ["/bin/bash", "/root/start.sh"]