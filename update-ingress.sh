#!/usr/bin/env bash
set -e

# get your current external IP (use whatever service you like)
IP=$(curl -fsS https://ifconfig.me)

# annotate the ingress in the default namespace
microk8s kubectl annotate ingress orion-ingress \
  external-dns.alpha.kubernetes.io/target="$IP" \
  --overwrite
.
