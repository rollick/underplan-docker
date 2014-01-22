############################################################
# Dockerfile to run Underplan Site Bundle Containers
# Based on Ubuntu Image
############################################################

# Set the base image to use to Ubuntu
FROM stackbrew/ubuntu:13.04

# Set the file maintainer
MAINTAINER rollick

###
# Initial Setup

ENV HOME /root

# This container should be run with a reference to a data-only container 
# for the sites node/meteor code
# We are using /var/www as the existing scripts assume some things about 
# the directory structure...
RUN mkdir /var/www/

# link the shared volume (/www) so that it will be available for the
# the bundled app code
RUN ln -sf /www /var/www/underplan

# Setup ssh keys
RUN mkdir /.ssh
ADD ssh/id_rsa /root/.ssh/
ADD ssh/id_rsa.pub /root/.ssh/
RUN chmod 600 -R /root/.ssh

# Copy start script
ADD start.sh /root/
RUN chmod u+x /root/start.sh

# Copy deploy scripts
RUN mkdir /root/scripts
ADD scripts/deploy.sh /root/scripts/
RUN chmod u+x /root/scripts/deploy.sh

# Install tools for bundling meteor apps
RUN apt-get install -y --force-yes software-properties-common python python-setuptools
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get -y update
RUN apt-get install -y nodejs git-core curl

RUN echo tlsv1 > $HOME/.curlrc
RUN curl https://install.meteor.com | /bin/sh -x
RUN npm install -g meteorite

###
# Checkout Code

# Ensure bitbucket public key has already been accepted
RUN echo "|1|Lh1C7wk23V6hmT8mmf4LFkW5pZA=|GUrsD6+i36DjgKVjwxpQ/AuXEqg= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw==" >> /root/.ssh/known_hosts
ENV PKEY /root/.ssh/id_rsa

# Bundle app into shared volume: /var/www/underplan
CMD ["/root/start.sh"]