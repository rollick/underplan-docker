############################################################
# Dockerfile to run data-only container for Underplan Site
# Based on Busybox Image
############################################################

FROM stackbrew/busybox:latest
MAINTAINER rollick

# Create site-data directory
RUN mkdir /site-data
RUN touch /site-data/SITE_DATA

# Create /site-data volume
VOLUME /site-data