SHELL := /bin/bash

# ---------- Variables (override via make VAR=...) ----------
OWNER ?= IsaiahHarvi
REPO ?= homelab
BRANCH ?= main
GITHUB_TOKEN ?= # set in env or pass on cmdline


# ---------- Helpers ----------
.PHONY: help
help:
	@echo "Targets:"
	@echo "  make sops-agegen             Generate an age keypair for SOPS"
	@echo "  make flux-bootstrap OWNER=... REPO=... BRANCH=...  Bootstrap Flux to this repo"
	@echo "  make apply-cluster           Apply top-level cluster kustomization (post-bootstrap)"
	@echo "  make validate                Run kubeconform + yamllint locally (requires tools installed)"

.PHONY: sops-agegen
sops-agegen:
	@echo "Generating age keypair (private key stays local; commit only public recipient into .sops.yaml)"
	@if ! command -v age-keygen >/dev/null 2>&1; then echo "Install age: https://github.com/FiloSottile/age"; exit 1; fi
	@age-keygen -o .agekey
	@echo ""
	@echo "Public key (recipient):"
	@grep -E "^# public key: " .agekey | sed 's/# public key: //'
	@echo ""
	@echo "IMPORTANT: Add the public key to .sops.yaml under 'age:' recipients."

.PHONY: flux-bootstrap
flux-bootstrap:
	@if ! command -v flux >/dev/null 2>&1; then echo "Install flux CLI: https://fluxcd.io/flux/installation/"; exit 1; fi
	@if [ -z "$(GITHUB_TOKEN)" ]; then echo "Set GITHUB_TOKEN env var (a GitHub PAT)"; exit 1; fi
	flux bootstrap github \
	  --owner=$(OWNER) \
	  --repository=$(REPO) \
	  --branch=$(BRANCH) \
	  --path=clusters/homelab \
	  --personal

.PHONY: apply-cluster
apply-cluster:
	kubectl apply -k clusters/homelab

.PHONY: validate
validate:
	@echo "Running kubeconform + yamllint (install them first)"
	@find . -name '*.yaml' -o -name '*.yml' | xargs -I{} kubeconform -output tap -summary {}
	@yamllint .
