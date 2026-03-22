# GitOps (Argo CD) repo skeleton

This folder is intended to be pushed to a **separate GitHub repo** and then used as the source-of-truth for your Lima Kubernetes lab cluster.

## 1) Create a GitHub repo

Create a new GitHub repo (public is simplest for a lab) and note its URL, e.g.

- `https://github.com/rayabueg/gitops-lab.git`

## 2) Initialize + push this folder

From the workspace root:

```bash
cd gitops-lab

git init
git add .
git commit -m "initial gitops skeleton"
git branch -M main

git remote add origin https://github.com/rayabueg/gitops-lab.git
git push -u origin main
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

