#!/bin/bash

set -e

TEST_IMAGE_NAME="integration_test"
TEST_CONTAINER_NAME="ci_test"

# Run unit test
echo -e "\nRunning integration test"

docker run --rm --name $TEST_CONTAINER_NAME \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /tmp:/tmp \
        -it $TEST_IMAGE_NAME \
        npm test integration_test/run.js