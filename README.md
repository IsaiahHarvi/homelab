# Homelab (k3s + Flux)


## Repo Layout

```
clusters/
  homelab/
    kustomization.yaml          # entrypoint for cluster
    flux-system/                # post-bootstrap patches
    infra/                      # infra kustomization
    apps/                       # apps kustomization
infrastructure/
  base/
    namespaces/
    ingress-nginx/
    cert-manager/
    metallb/
    longhorn/
apps/
  base/
    echo-server/
flux/
  image-automation/
  sources/
.github/workflows/validate.yml
scripts/
  install_k3s.sh
  teardown_microk8s.sh
  bootstrap_flux.sh
Makefile
.sops.yaml
```

### Notes

- **Ingress**: defaults to `ingress-nginx` (disables k3s’ bundled Traefik via install script). Switch to Traefik by removing nginx and editing infra kustomizations accordingly.
- **Storage**: includes Longhorn as an example (optional). You can keep k3s’ `local-path` storage by skipping Longhorn.
- **LoadBalancer**: uses MetalLB with a **placeholder** address pool. Update `values.yaml` with a block from your LAN.
- **DNS/Certs**: cert-manager is ready; add a ClusterIssuer later (e.g., Let’s Encrypt) and optional `external-dns` if you use public DNS.

## Next Steps

- Replace placeholders (TODOs) in `metallb/values.yaml`, `cert-manager/`, and any Helm values.
- Bring back your real apps: add HelmReleases under `apps/base/` or plain Kustomize overlays.
- If your services publish to GHCR or another registry, see `flux/image-automation/` for an example ImageRepository+Policy+Update.
- Add cluster-unique overlays under `apps/overlays/` if you have multiple clusters later.
