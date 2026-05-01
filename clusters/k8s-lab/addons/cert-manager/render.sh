#!/usr/bin/env bash
# Renders the cert-manager Helm chart to install.yaml.
# Re-run this script to update when bumping targetRevision.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VERSION="v1.20.0"

helm repo add jetstack https://charts.jetstack.io --force-update >/dev/null
helm repo update jetstack >/dev/null

helm template cert-manager jetstack/cert-manager \
  --version "${VERSION}" \
  --namespace cert-manager \
  --include-crds \
  -f "${SCRIPT_DIR}/values.yaml" \
  > "${SCRIPT_DIR}/install.yaml"

echo "Rendered cert-manager ${VERSION} → install.yaml"
