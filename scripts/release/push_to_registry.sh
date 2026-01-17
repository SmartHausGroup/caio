#!/usr/bin/env bash
set -euo pipefail

# Push a CAIO image to the private registry.
# Usage: REGISTRY_HOST=registry.example.com IMAGE_TAG=v0.1.0 ./scripts/release/push_to_registry.sh

REGISTRY_HOST="${REGISTRY_HOST:-registry.smarthaus.group}"
REPOSITORY="${REPOSITORY:-caio}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
SOURCE_IMAGE="${SOURCE_IMAGE:-${REPOSITORY}:${IMAGE_TAG}}"
TARGET_IMAGE="${REGISTRY_HOST}/${REPOSITORY}:${IMAGE_TAG}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required to push images." >&2
  exit 1
fi

echo "Pushing ${SOURCE_IMAGE} -> ${TARGET_IMAGE}"
docker tag "${SOURCE_IMAGE}" "${TARGET_IMAGE}"
docker push "${TARGET_IMAGE}"
