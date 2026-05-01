#!/usr/bin/env bash
# Renders the Cilium Helm chart (with Hubble) to install.yaml.
# Re-run this script to update when bumping targetRevision or changing values.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VERSION="1.19.1"

helm repo add cilium https://helm.cilium.io --force-update >/dev/null
helm repo update cilium >/dev/null

helm template cilium cilium/cilium \
  --version "${VERSION}" \
  --namespace kube-system \
  -f "${SCRIPT_DIR}/values.yaml" \
  > "${SCRIPT_DIR}/install.yaml"

echo "Rendered cilium (hubble) ${VERSION} → install.yaml"
