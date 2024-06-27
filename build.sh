#!/bin/bash

DOCKER=$(which docker)

# Build the image
TAG_NAME="$1"

"${DOCKER}" buildx build --platform linux/amd64 --load -t "${TAG_NAME}" .

echo "Image built: ${TAG_NAME}" 