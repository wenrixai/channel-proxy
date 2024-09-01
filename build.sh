#!/bin/bash

DOCKER=$(which docker)

# Check if `--push=true` is passed
PUSH=false
if [ "$1" = "--push=true" ]; then
    PUSH=true
fi

# Build the image
TAG_NAME="wenrix/channel-proxy:latest"
ADDITIONAL_TAGS="wenrix/channel-proxy:1.0 public.ecr.aws/wenrix/wenrix-channel-proxy:latest public.ecr.aws/wenrix/wenrix-channel-proxy:1.0"

"${DOCKER}" buildx build --platform linux/amd64 --load -t "${TAG_NAME}" .
echo "Built image: ${TAG_NAME}"

for additional_tag in ${ADDITIONAL_TAGS}; do
    "${DOCKER}" tag "${TAG_NAME}" "${additional_tag}"
    echo "Tagged ${TAG_NAME} as ${additional_tag}"
done

if [ "${PUSH}" = true ]; then
    "${DOCKER}" push "${TAG_NAME}"
    for additional_tag in ${ADDITIONAL_TAGS}; do
        "${DOCKER}" push "${additional_tag}"

        echo "Pushed ${additional_tag}"
    done
fi
