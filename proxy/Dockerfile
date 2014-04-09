############################################################
# Dockerfile to run Underplan Nginx Containers
# Based on Ubuntu Image
############################################################

# Set the base image to use to Ubuntu
FROM stackbrew/ubuntu:13.10

# Set the file maintainer
MAINTAINER rollick

ENV HOME /root

###
# Web Stuff

# Install Nginx
RUN apt-get update

# Ensure openssl is updated for Heart Bleed Bug
RUN apt-get install openssl libssl1.0.0
RUN openssl version -a

RUN apt-get install -y software-properties-common python-setuptools
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN apt-get install -y nginx

# Remove worker_processes line from nginx conf so we can set using supervisord
RUN sed -i '/worker_processes/d' /etc/nginx/nginx.conf

# Setup SSL certs
RUN mkdir /etc/nginx/ssl
ADD ssl/underplan.io.key /etc/nginx/ssl/
ADD ssl/underplan.io.combined.crt /etc/nginx/ssl/
RUN chmod 600 /etc/nginx/ssl/underplan.io.key
RUN chmod 644 /etc/nginx/ssl/underplan.io.combined.crt

# Add conf for underplan
ADD sites-available/underplan /etc/nginx/sites-available/
ADD sites-available/underplan-ssl /etc/nginx/sites-available/
ADD sites-available/upstream-ssl.template $HOME/
RUN ln -sf /etc/nginx/sites-available/underplan /etc/nginx/sites-enabled/underplan
RUN ln -sf /etc/nginx/sites-available/underplan-ssl /etc/nginx/sites-enabled/underplan-ssl

# Remove default config
RUN rm /etc/nginx/sites-enabled/default

# Setup some standard directories and error pages
RUN mkdir -p /var/www/errors
ADD www/50x.html /var/www/errors/

# Install supervisor
RUN apt-get install -y supervisor
ADD Supervisorfile /etc/supervisor/conf.d/nginx.conf

# Add startup script
ADD start.sh $HOME/
RUN chmod +x $HOME/start.sh
RUN chown root: $HOME/start.sh