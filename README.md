# GitOps (Argo CD) repo

This repo is the **source-of-truth** for your lab cluster (Argo CD `Application`s, addons, gateway resources, etc.).

Keep the **bootstrap** scripts (Lima VM + kubeadm + CNI + initial Argo CD install) in a separate repo (for example the `lima/` folder in this workspace).

## 1) Create a GitHub repo

Create a new GitHub repo (public is simplest for a lab) and note its URL, e.g.

- `https://github.com/<you>/gitops-lab.git`

For sharing, the simplest flow is:

- You keep this repo as the “upstream”, and your colleague forks it, OR
- You both work from a shared org repo.

## 2) Fork / clone

If you’re starting from this workspace, `gitops-lab/` is already a git repo.

To clone:

```bash
git clone https://github.com/<you>/gitops-lab.git
cd gitops-lab
```

## 3) Point Argo CD at your repo

Edit `bootstrap/argocd/root-app.yaml` and set `spec.source.repoURL` to your repo URL.

Then apply it to the cluster:

```bash
export KUBECONFIG="$HOME/.kube/lima-sdp-lab"

kubectl apply -f bootstrap/argocd/root-app.yaml
kubectl -n argocd get applications
```

## 4) Verify the first Git-managed resource

This repo includes a tiny smoke test `ConfigMap`.

```bash
kubectl -n demo get configmap gitops-smoke-test -o yaml
```

## Notes: CRDs first

Some addons (like Envoy Gateway) rely on CRDs. This repo vendors those CRDs under `clusters/sdp-lab/crds/` and applies them first using an Argo CD sync wave.

For Envoy Gateway, the Gateway API CRDs are pinned to a version compatible with the Envoy Gateway release (currently Gateway API v1.4.1 for Envoy Gateway v1.7.x), and the Envoy Gateway CRDs are pinned to the Envoy Gateway release version.

