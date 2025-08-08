#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <NEW_TAG>

Updates vd-api, vd-gui and vd-db deployments to use the specified image tag.

Example:
  $(basename "$0") 0.0.21
EOF
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

NEW_TAG=$1
NAMESPACE=default

echo "Updating deployments in namespace '$NAMESPACE' to tag '$NEW_TAG'..."

kubectl set image deployment/vd-api \
  api=ghcr.io/verus-datum/api:"${NEW_TAG}" \
  -n "${NAMESPACE}"

kubectl set image deployment/vd-gui \
  gui=ghcr.io/verus-datum/gui:"${NEW_TAG}" \
  -n "${NAMESPACE}"

kubectl set image deployment/vd-db \
  db=ghcr.io/verus-datum/db:"${NEW_TAG}" \
  -n "${NAMESPACE}"

echo "Done."

