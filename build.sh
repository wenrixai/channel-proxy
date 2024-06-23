#!/bin/bash

DOCKER=$(which docker)

# Build the image
TAG_NAME="wenrix-proxy:$1"

"${DOCKER}" build --platform linux/amd64 -t "${TAG_NAME}" .

echo "Image built: ${TAG_NAME}" 