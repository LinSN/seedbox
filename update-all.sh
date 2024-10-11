#!/bin/bash

# Create/update http_auth file according to values in .env file
set -a
source /home/linsn/seedbox/.env
set +a

# Use the environment variables to create the http_auth file
# echo "${HTTP_USER}:${HTTP_PASSWORD}" > /home/linsn/seedbox/traefik/http_auth

# source /home/linsn/seedbox/.env
# echo "${HTTP_USER}:${HTTP_PASSWORD}" > traefik/http_auth

echo "[$0] ***** Pulling all images... *****"
# /usr/local/bin/docker-compose pull
echo "[$0] ***** Recreating containers if required... *****"
/usr/local/bin/docker-compose up -d --remove-orphans
echo "[$0] ***** Done updating containers *****"
echo "[$0] ***** Clean unused images... *****"
# docker image prune -af
echo "[$0] ***** Done! *****"
exit 0
