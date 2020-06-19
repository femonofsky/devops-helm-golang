#!/usr/bin/env bash

## Complete the following steps to get Docker running locally

# Step 1:
# Build image and add a descriptive tag
docker build --tag=web-app-$1 --build-arg app_env=$1 --build-arg app_port=$2 .

# Step 2:
# List docker images
docker image ls

# Step 3:
# Run golang app
docker run -p $2:$2 web-app-$1

