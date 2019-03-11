#!/bin/bash
# This script will publish built docker image to ACR.
# Requires Azure Container Service Username and Password
# Also requires IMAGE_NAME defined

set -e

: "${ACR_USR?ACR_USR is required}"
: "${ACR_PSW?ACR_PSW is required}"

GIT_SHORT="${GIT_COMMIT:0:8}"

IMAGE_NAME="${IMAGE_NAME:-cennznet}"

IMAGE_TAG="rimu-$GIT_SHORT"

# Azure container registry
ACR_HOSTNAME=centralitycontainerregistry-on.azurecr.io

RIMU_COMMIT="${ACR_HOSTNAME}/centrality/${IMAGE_NAME}:${IMAGE_TAG}"
RIMU_LATEST="${ACR_HOSTNAME}/centrality/${IMAGE_NAME}:rimu"

# GET IMAGE ID TO ADD TAG ON IT
IMAGE_ID=$(docker images --format "{{.ID}}" "${IMAGE_NAME}")

docker login -u "${ACR_USR}" -p "${ACR_PSW}" "${ACR_HOSTNAME}"

## PUBLISH IMAGE TO Azure Container Repository
echo "Uploading image: $RIMU_COMMIT and latest"

docker tag "${IMAGE_ID}" "$RIMU_COMMIT"
docker tag "${IMAGE_ID}" "$RIMU_LATEST"

docker push "$RIMU_COMMIT"
docker push "$RIMU_LATEST"

# Remove image after pushing to azure container registry
docker rmi -f "${IMAGE_ID}"