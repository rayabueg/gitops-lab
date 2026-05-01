#!/usr/bin/env bash
# Renders the descheduler Helm chart to base/latest/bundle.yaml.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VERSION="0.34.0"

helm repo add descheduler https://kubernetes-sigs.github.io/descheduler/ --force-update >/dev/null
helm repo update descheduler >/dev/null

helm template descheduler descheduler/descheduler \
  --version "${VERSION}" \
  --namespace kube-system \
  -f "${SCRIPT_DIR}/values.yaml" \
  > "${SCRIPT_DIR}/../base/latest/bundle.yaml"

echo "Rendered descheduler ${VERSION} → base/latest/bundle.yaml"
