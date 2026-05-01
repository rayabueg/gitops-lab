#!/usr/bin/env bash
# Renders the external-secrets Helm chart to install.yaml.
# Re-run this script to update when bumping targetRevision.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VERSION="2.3.0"

helm repo add external-secrets https://charts.external-secrets.io --force-update >/dev/null
helm repo update external-secrets >/dev/null

helm template external-secrets external-secrets/external-secrets \
  --version "${VERSION}" \
  --namespace external-secrets \
  --include-crds \
  -f "${SCRIPT_DIR}/values.yaml" \
  > "${SCRIPT_DIR}/install.yaml"

echo "Rendered external-secrets ${VERSION} → install.yaml"
