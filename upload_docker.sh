#!/usr/bin/env bash
# This file tags and uploads an image to Docker Hub

# Assumes that an image is built via `run_docker.sh`

# Step 1:
# Create dockerpath
# dockerpath=<your docker ID/path>
echo $1

dockerpath=nofsky/web-app-$1

# Step 2:
# Authenticate & tag
echo "Docker ID and Image: $dockerpath"
docker login --username nofsky
docker image tag web-app-$2 $dockerpath

# Step 3:
# Push image to a docker repository
docker push $dockerpath