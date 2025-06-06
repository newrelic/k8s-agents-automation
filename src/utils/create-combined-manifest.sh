#!/usr/bin/env bash
set -o errexit
set -o pipefail

DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-""}
DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG:-""}
IS_PRERELEASE=${IS_PRERELEASE:-"true"}

export GGCR_DISABLE_CACHE=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --docker-image-name) DOCKER_IMAGE_NAME="$2"; shift 2 ;;
    --docker-image-tag) DOCKER_IMAGE_TAG="$2"; shift 2 ;;
    --is-prerelease) IS_PRERELEASE="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "${DOCKER_IMAGE_NAME}" ]]; then
  echo "Error: DOCKER_IMAGE_NAME is required."
  exit 1
fi
if [[ -z "${DOCKER_IMAGE_TAG}" ]]; then
  echo "Error: DOCKER_IMAGE_TAG is required."
  exit 1
fi
if [[ -z "${IS_PRERELEASE}" ]]; then
  echo "Error: IS_PRERELEASE is required."
  exit 1
fi

if [[ "${IS_PRERELEASE}" != "false" ]]; then 
  IMAGE_TAG="${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}-pre"
else
  IMAGE_TAG="${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
fi
echo "IMAGE_TAG=${IMAGE_TAG}"

linux_manifest=$(regctl manifest get "${IMAGE_TAG}" --format '{{jsonPretty .}}')
echo "Extracted Linux manifest: "
echo "${linux_manifest}"

arm64_digest=$(jq -r '.manifests[] | select(.platform.architecture=="arm64" and .platform.os=="linux") | .digest' <<< "$linux_manifest")
armv7_digest=$(jq -r '.manifests[] | select(.platform.architecture=="arm" and .platform.variant=="v7" and .platform.os=="linux") | .digest' <<< "$linux_manifest")
amd64_digest=$(jq -r '.manifests[] | select(.platform.architecture=="amd64" and .platform.os=="linux") | .digest' <<< "$linux_manifest")
all_attestations=$(jq -r '.manifests[] | select(.platform.architecture=="unknown" and .platform.os=="unknown" and .annotations["vnd.docker.reference.type"]=="attestation-manifest")' <<< "$linux_manifest")
attestations_array=$(echo ${all_attestations} | jq -s '.')
windows2019_image="${IMAGE_TAG}-windows-ltsc2019"
windows2022_image="${IMAGE_TAG}-windows-ltsc2022"

declare -A images=(
  [arm64]="${DOCKER_IMAGE_NAME}@${arm64_digest}"
  [armv7]="${DOCKER_IMAGE_NAME}@${armv7_digest}"
  [amd64]="${DOCKER_IMAGE_NAME}@${amd64_digest}"
  [win2019]="${windows2019_image}"
  [win2022]="${windows2022_image}"
)

for arch in "${!images[@]}"; do
  [[ -n "${images[$arch]}" ]] && echo "${arch^^} image: ${images[$arch]}"
done

echo "Creating new manifest..."
manifest_cmd="docker manifest create ${IMAGE_TAG}"
for img in "${images[@]}"; do
  [[ -n "$img" ]] && manifest_cmd+=" --amend $img"
done

echo "Executing: ${manifest_cmd}"
eval $manifest_cmd
echo "Manifest created successfully."

echo "Adding linux image attestation-manifests"
docker manifest inspect "${IMAGE_TAG}" > new_manifest.json
jq --argjson atts "${attestations_array}" '.manifests += $atts' new_manifest.json > updated_manifest.json
regctl manifest put ${IMAGE_TAG} < updated_manifest.json
regctl manifest get "${IMAGE_TAG}" --format '{{jsonPretty .}}'
