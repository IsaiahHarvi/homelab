#!/usr/bin/env bash
set -euo pipefail

if ! command -v microk8s >/dev/null 2>&1; then
  echo "microk8s not found; nothing to do."
  exit 0
fi

echo "Stopping MicroK8s..."
sudo microk8s stop || true

echo "Resetting MicroK8s..."
sudo microk8s reset || true

echo "Removing MicroK8s snap..."
sudo snap remove microk8s || true

echo "Removing leftover directories..."
sudo rm -rf /var/snap/microk8s || true

echo "Done. You can now proceed with k3s installation."
