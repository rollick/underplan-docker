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
FROM ubuntu:13.10

# Set the file maintainer
MAINTAINER rollick

ENV HOME /root

###
# Install Node / nvm requirements

RUN apt-get update
RUN apt-get install -y git curl mongodb-clients phantomjs
RUN git clone https://github.com/creationix/nvm.git /.nvm
RUN echo ". /.nvm/nvm.sh" >> /etc/bash.bashrc
RUN /bin/bash -c '. /.nvm/nvm.sh && nvm install v0.10.30 && nvm use v0.10.30 && nvm alias default v0.10.30 && ln -s /.nvm/v0.10.30/bin/node /usr/bin/node && ln -s /.nvm/v0.10.30/bin/npm /usr/bin/npm'

###
# Meteor App

# install meteor
RUN echo tlsv1 > $HOME/.curlrc
RUN curl https://install.meteor.com | /bin/sh -x
RUN npm install meteorite

# install node runner
RUN npm install -g forever

# Port to expose
EXPOSE 3000

# Add startup script
ADD start.sh $HOME/
RUN chmod +x $HOME/start.sh
RUN chown root: $HOME/start.sh