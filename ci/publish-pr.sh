#!/bin/bash
# This script will publish built docker image to ACR.
# Requires Azure Container Service Username and Password
# Also requires IMAGE_NAME defined

set -e

: "${ACR_USR?ACR_USR is required}"
: "${ACR_PSW?ACR_PSW is required}"

GIT_SHORT="${GIT_COMMIT:0:8}"

IMAGE_NAME="${IMAGE_NAME:-cennznet-node}"

# remove 'origin/' from branch name and replace any '/' with '_'
BRANCH="${GIT_BRANCH/origin\//}"
BRANCH=${BRANCH/\//_}

IMAGE_TAG="$BRANCH-$GIT_SHORT"

# Azure container registry
ACR_HOSTNAME=centralitycontainerregistry-on.azurecr.io

FULL_IMAGE="${ACR_HOSTNAME}/centrality/${IMAGE_NAME}:${IMAGE_TAG}"

# GET IMAGE ID TO ADD TAG ON IT
IMAGE_ID=$(docker images --format "{{.ID}}" "${IMAGE_NAME}")

docker login -u "${ACR_USR}" -p "${ACR_PSW}" "${ACR_HOSTNAME}"

## PUBLISH IMAGE TO Azure Container Repository
echo "Uploading image: $FULL_IMAGE"

docker tag "${IMAGE_ID}" "$FULL_IMAGE"

docker push "$FULL_IMAGE"

# Remove image after pushing to azure container registry
docker rmi -f "${IMAGE_ID}"