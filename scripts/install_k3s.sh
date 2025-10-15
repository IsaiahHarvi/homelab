#!/usr/bin/env bash
set -euo pipefail

# Install single-node k3s and disable bundled Traefik (we'll use ingress-nginx via GitOps)
# Also label the node for potential scheduling tweaks later.

if ! command -v curl >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y curl; fi

export INSTALL_K3S_EXEC="--disable traefik"
curl -sfL https://get.k3s.io | sh -

# kubeconfig is at /etc/rancher/k3s/k3s.yaml. For convenience:
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# label the single node (optional)
NODE=$(kubectl get nodes -o name | head -n1 | cut -d'/' -f2)
kubectl label node "$NODE" node-role.kubernetes.io/homelab=true --overwrite

echo "k3s installed. kubectl get nodes:"
kubectl get nodes -o wide
