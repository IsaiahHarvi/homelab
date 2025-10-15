#!/usr/bin/env bash
set -euo pipefail

OWNER=${OWNER:-"IsaiahHarvi"}
REPO=${REPO:-"homelab"}
BRANCH=${BRANCH:-"main"}

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Set GITHUB_TOKEN environment variable to a GitHub PAT with repo perms."
  exit 1
fi

flux bootstrap github \
  --owner="$OWNER" \
  --repository="$REPO" \
  --branch="$BRANCH" \
  --path=clusters/homelab \
  --personal
