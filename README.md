# cluster-addons

Source-of-truth for cluster infrastructure and addons. Argo CD syncs this repo continuously.

The user-facing apps half lives in [`cluster-applications`](https://github.com/rayabueg/cluster-applications).

## Structure

```
cluster-addons/
├── addons/                          # One folder per addon
│   └── <name>/
│       ├── base/
│       │   ├── latest/              # Output of the most recent render
│       │   │   ├── bundle.yaml      # Rendered Helm output (helm template)
│       │   │   └── kustomization.yaml
│       │   └── stable/              # Promoted copy of latest (what wave1 points at)
│       │       ├── bundle.yaml
│       │       └── kustomization.yaml
│       └── hack/
│           ├── render.sh            # Re-renders bundle.yaml from Helm chart
│           ├── promote.sh           # Copies latest/ → stable/
│           └── values.yaml          # Helm values used by render.sh
├── waves/
│   ├── wave1/                       # Production-track: refs addons/*/base/stable
│   │   └── <name>/kustomization.yaml
│   └── wave2/                       # Canary-track: refs addons/*/base/latest
│       └── <name>/kustomization.yaml
├── clusters/
│   └── k8s-lab/
│       ├── kustomization.yaml       # Renders the ApplicationSet
│       ├── applicationset.yaml      # Discovers clusters/k8s-lab/addons/*
│       └── addons/
│           └── <name>/
│               └── kustomization.yaml  # Points to waves/wave1/<name>
└── bootstrap/
    └── argocd/
        └── root-app.yaml            # Bootstrap: apply once to seed Argo CD
```

**Non-Helm addons** (namespaces, core-dns, crds, envoy-gateway) store raw YAML in `base/latest/`
and have no `hack/` folder. Wave1 references `base/latest` directly for these.

**HTTPRoutes belong to the app they route to:**
- `argocd-config` addon owns the ArgoCD HTTPRoute (`argocd-httproute.yaml`)
- `hubble` addon owns the Hubble UI HTTPRoute (`httproute.yaml`)
- App HTTPRoutes live in `cluster-applications/apps-envs/<app>/httproute.yaml`

**`envoy-gateway` addon is pure infrastructure** — only `eg-gateway.yaml` (Gateway) and
`eg-envoyproxy.yaml` (EnvoyProxy config). No application resources.

## Addons

| Addon | Type | Notes |
|---|---|---|
| `argocd-config` | Raw YAML | Insecure mode ConfigMap + ArgoCD HTTPRoute |
| `cert-manager` | Helm | CRDs + controller |
| `core-dns` | Raw YAML | Custom DNS entries ConfigMap |
| `crds` | Raw YAML | Gateway API + Envoy Gateway CRDs |
| `descheduler` | Helm | Pod descheduler |
| `envoy-gateway` | Raw YAML | Gateway + EnvoyProxy only |
| `external-dns` | Helm | DNS record automation |
| `external-secrets` | Helm | Secret sync from external stores |
| `hubble` | Helm (Cilium) | Hubble relay + UI + HTTPRoute |
| `istio` | Helm | Base, CNI, istiod, ztunnel |
| `namespaces` | Raw YAML | Cluster namespace definitions |

## Bootstrap

Edit `bootstrap/argocd/root-app.yaml` to point at your fork (if applicable), then apply once:

```bash
export KUBECONFIG="$HOME/.kube/lima-k8s-lab"
kubectl apply -f cluster-addons/bootstrap/argocd/root-app.yaml
kubectl apply -f cluster-applications/bootstrap/argocd/root-app.yaml
kubectl -n argocd get applications
```

## Updating a Helm addon

```bash
# 1) Edit hack/values.yaml as needed, then re-render
bash addons/<name>/hack/render.sh

# 2) Review the diff in base/latest/bundle.yaml, then promote to stable
bash addons/<name>/hack/promote.sh

# 3) Commit and push — Argo CD picks up the change automatically
git add -A && git commit -m "addons(<name>): ..." && git push
```

## Contributing

Format: `scope: summary`  
Examples: `addons: add descheduler`, `crds: bump gateway-api`, `envoy-gateway: add listener`

If working from the parent `k8s-lab` repo, this folder is a **git submodule**:
1. Commit + push changes here first
2. Commit the updated submodule pointer in the parent repo
