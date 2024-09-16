#!/bin/bash

# DockerHub API URL for the elixir image
DOCKER_IMAGE="elixirprotocol/validator:v3"
DOCKER_HUB_API="https://registry.hub.docker.com/v2/repositories/elixirprotocol/validator/tags/v3"
VALIDATOR_ENV_PATH="/path/to/validator.env"  # Change this to the correct path

# Function to get the image digest from Docker Hub
get_remote_digest() {
  curl -s $DOCKER_HUB_API | jq -r '.digest'
}

# Function to get the image digest from the local machine
get_local_digest() {
  docker inspect --format='{{index .RepoDigests 0}}' $DOCKER_IMAGE | cut -d'@' -f2
}

# Function to print logs with timestamps
log_with_timestamp() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Get the latest remote digest from Docker Hub
REMOTE_DIGEST=$(get_remote_digest)
if [ -z "$REMOTE_DIGEST" ]; then
  log_with_timestamp "Failed to fetch the latest digest from Docker Hub."
  exit 1
fi

log_with_timestamp "Latest digest from Docker Hub: $REMOTE_DIGEST"

# Get the local image digest
LOCAL_DIGEST=$(get_local_digest)
if [ -z "$LOCAL_DIGEST" ]; then
  log_with_timestamp "Failed to get the local image digest."
  exit 1
fi

log_with_timestamp "Local digest: $LOCAL_DIGEST"

# Compare the digests and update if necessary
if [ "$REMOTE_DIGEST" != "$LOCAL_DIGEST" ]; then
  log_with_timestamp "Image is outdated. Running container update script..."
  
  # Kill and remove the existing container
  echo "Killing and removing existing 'elixir' Docker container..."
  docker kill elixir && docker rm elixir

  # Pull the latest image
  echo "Pulling the latest 'elixirprotocol/validator:v3' image..."
  docker pull elixirprotocol/validator:v3
  if [ $? -ne 0 ]; then
    log_with_timestamp "Failed to pull the latest image. Exiting."
    exit 1
  fi

  # Run the container with updated image
  echo "Running the 'elixir' container..."
  docker run -d \
    --env-file "$VALIDATOR_ENV_PATH" \
    --name elixir \
    --restart unless-stopped \
    elixirprotocol/validator:v3
  if [ $? -ne 0 ]; then
    log_with_timestamp "Failed to start the container. Exiting."
    exit 1
  fi

  # Prune unused images
  echo "Deleting unused images..."
  docker image prune -af
  log_with_timestamp "Completed setup and cleanup."
else
  log_with_timestamp "Image is up-to-date."
fi

log_with_timestamp "----------------------------"
