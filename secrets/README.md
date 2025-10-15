Place your encrypted secrets here. Example workflow:

1. `make sops-agegen` and add your **public** age key to `.sops.yaml`.
2. Create a secret file, e.g. `secrets/registry-creds.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: registry-creds
  namespace: apps
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <BASE64_JSON>
```

3. Encrypt it:
`sops -e -i secrets/registry-creds.yaml`

4. Commit the encrypted file. Flux will apply it as-is and the controller will decrypt using your age key.
