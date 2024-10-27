#!/bin/bash

# Create/update http_auth file according to values in .env file
# set -a
# source /home/linsn/seedbox/.env
# set +a

# Use the environment variables to create the http_auth file
# echo "${HTTP_USER}:${HTTP_PASSWORD}" > /home/linsn/seedbox/traefik/http_auth

# source /home/linsn/seedbox/.env
# echo "${HTTP_USER}:${HTTP_PASSWORD}" > traefik/http_auth

# Change to the seedbox directory
# Define the log file path
log_file="/home/linsn/logs/update-all.log"

# Define a logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Change to the seedbox directory
cd /home/linsn/seedbox

log "***** Starting update-all.sh script *****"

log "Pulling all images..."
docker compose -f docker-compose.yml --env-file .env pull

log "Recreating containers if required..."
docker compose -f docker-compose.yml --env-file .env up -d --remove-orphans

log "Cleaning unused images..."
docker image prune -af

log "***** Finished update-all.sh script *****"
exit 0
