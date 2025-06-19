# Homelab Kubernetes Service Orchestration

**Updating Kubernetes deployments**

```bash
# 1. Upgrade the Helm release to pull the new image tag
#    (assumes chart at services/charts/service)
microk8s helm3 upgrade orion services/charts/service \
  --reuse-values

# 2. force-restart without a chart change:
kubectl rollout restart deployment/name
```

---

## Common Helm Commands

* `helm list`
  List all releases.

* `helm status service`
  See details & notes for the specified service.

* `helm upgrade service services/charts/service [--set key=val]`
  Apply chart changes or new image tags.

* `helm rollback orion <revision>`
  Revert to a previous revision.

* `helm uninstall service`
  Tear down the release.

---

## kubectl Commands

### Inspecting Resources

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl describe pod pod-name-xxxxx
kubectl logs deployment/pod-name
```

### Debugging & Access

```bash
kubectl rollout status deployment/pod-name

kubectl port-forward deployment/pod-name 5000:80

kubectl exec -it deployment/pod-name -- sh
```

### Rolling Updates & Scaling

```bash
# Restart pods on spec change
kubectl rollout restart deployment/pod-name

# Scale replicas
kubectl scale deployment/pod-name --replicas=3
```

### Applying Raw Manifests

```bash
kubectl apply -f path/to/manifest.yaml
kubectl delete -f path/to/manifest.yaml
```

---

## TLS & DNS

* **ExternalDNS**
  Watch logs to confirm DNS sync:

  ```bash
  kubectl -n external-dns logs -f deployment/external-dns
  ```

---

## Adding New Services

```bash
helm create servicename
```

* Edit Chart.yaml: set name, description, appVersion
* Adjust values.yaml: set container name, ingress, registry
* Double-check deployment.yaml
* Configure templates under `flux-system/`

---

## Flux

### Managing Sources & Kustomizations

```bash
# Re-sync Git sources
flux reconcile source git flux-system     -n flux-system
flux reconcile source git vd-charts        -n flux-system

# Core flux-system kustomization
flux reconcile kustomization flux-system   -n flux-system

# Overlay kustomization for apps & HelmReleases
flux reconcile kustomization homelab-overlay -n flux-system

# View status
flux get sources git      -n flux-system
flux get kustomizations    -n flux-system
flux get helmreleases --all-namespaces
kubectl get pods,svc --all-namespaces
```

### Creating & Patching Resources

```bash
# Create a new overlay kustomization
flux create kustomization homelab-overlay \
  --namespace=flux-system \
  --source=GitRepository/flux-system \
  --path="./flux-system/overlay" \
  --prune=true \
  --interval=5m

# Patch GitRepository branch
kubectl -n flux-system patch gitrepository flux-system \
  --type merge \
  -p '{"spec":{"ref":{"branch":"reorg"}}}'
```

### HelmRelease & Image Automation

```bash
flux get helmreleases            -n flux-system

# HelmChart & HelmRelease troubleshooting
kubectl get helmrelease orion -n flux-system -o yaml
flux get helmrelease vd          -n flux-system

# Image automation
flux get image repository         -n flux-system
flux get image policy             -n flux-system
flux get image update automation  -n flux-system
flux get images policy vd-api     -n flux-system

# Force Flux to re-pull or apply
flux reconcile source git flux-system        -n flux-system
flux reconcile source git vd-charts           -n flux-system
flux reconcile kustomization flux-system      -n flux-system
flux reconcile kustomization homelab-overlay  -n flux-system
flux reconcile helmrelease orion              -n flux-system
flux reconcile helmrelease vd                 -n flux-system
flux reconcile helmrelease grafana            -n flux-system
flux reconcile image update automation orion  -n flux-system
```

### CF & Sealed Secret Example

```bash
kubectl create secret generic cf-ddns-secrets \
  --namespace external-dns \
  --from-literal=CF_AUTH_EMAIL="<email>" \
  --from-literal=CF_AUTH_KEY="$CF_GLOBAL_API_KEY" \
  --dry-run=client -o yaml \
  | kubeseal --cert=public-cert.pem --format=yaml \
  > flux-system/overlay/cf-ddns-sealedsecret.yaml
```

