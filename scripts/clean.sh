#!/bin/sh
#
# Clean build related artefacts
#
# Usage:
#   ./scripts/clean.sh
#
echo "Cleaning cargo cache..."
rm -rf .cargo/
echo "Cleaning useless docker images"
docker images -f 'dangling=true' -q | xargs docker rmi -f
