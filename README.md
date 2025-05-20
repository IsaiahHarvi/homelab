#Homelab kubernetes service orchestration

**Updating Kubernetes deployments**


```bash
# 1. Upgrade the Helm release to pull the new image tag
#    (assumes chart at services/charts/service)
microk8s helm3 upgrade orion services/charts/service \
  --reuse-values

# 2. force-restart without a chart change:
kubectl rollout restart deployment/name
````

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

## Adding new services
```bash
helm create servicename
```
- Edit Chart.yaml: set name, description, appVersion
- Adjust values.yaml: set container name, ingress, registry
- Double check deployment.yaml
- Use the templates under flux-system/


## Flux
### Modifying files under flux-system/overlay
```bash
flux reconcile source git flux-system
flux reconcile kustomization flux-system
```
### See what Flux has fetched & when
```
flux get sources git -n flux-system
flux get kustomizations flux-system -n flux-system
```

### Inspect your app release
```
flux get helmrelease orion         -n default
flux get helmreleases -n default
```

### Inspect image automation
```
flux get image repository          -n flux-system
flux get image policy              -n flux-system
flux get image update automation   -n flux-system
```

### Force Flux to re-pull Git, rebuild manifests, or bump tags
```
flux reconcile source git flux-system           -n flux-system
flux reconcile kustomization flux-system        -n flux-system
flux reconcile helmrelease orion                -n default
flux reconcile helmrelease grafana              -n default
flux reconcile image update automation orion    -n flux-system
```

### Flux CF sealed secret
```
kubectl create secret generic cf-ddns-secrets \
  --namespace external-dns \
  --from-literal=CF_AUTH_EMAIL="@gmail.com" \
  --from-literal=CF_AUTH_KEY="$CF_GLOBAL_API_KEY" \
  --dry-run=client -o yaml \
| kubeseal --cert=public-cert.pem --format=yaml \
> flux-system/overlay/cf-ddns-sealedsecret.yaml
```
