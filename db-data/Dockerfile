############################################################
# Dockerfile to run data-only container for Underplan DB
# Based on Busybox Image
############################################################

FROM stackbrew/busybox:latest
MAINTAINER rollick

# Create db-data directory
RUN mkdir /db-data
RUN touch /db-data/DB_DATA

# Create /db-data volume
VOLUME /db-data