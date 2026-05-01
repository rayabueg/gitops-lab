#!/usr/bin/env bash
# Renders all four Istio Helm charts to individual install-*.yaml files.
# Re-run this script to update when bumping targetRevision or changing values.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VERSION="1.24.3"

helm repo add istio https://istio-release.storage.googleapis.com/charts --force-update >/dev/null
helm repo update istio >/dev/null

echo "Rendering istio-base ${VERSION}..."
helm template istio-base istio/base \
  --version "${VERSION}" \
  --namespace istio-system \
  --include-crds \
  > "${SCRIPT_DIR}/install-base.yaml"

echo "Rendering istiod ${VERSION}..."
helm template istiod istio/istiod \
  --version "${VERSION}" \
  --namespace istio-system \
  -f "${SCRIPT_DIR}/values-istiod.yaml" \
  > "${SCRIPT_DIR}/install-istiod.yaml"

echo "Rendering istio-cni ${VERSION}..."
helm template istio-cni istio/cni \
  --version "${VERSION}" \
  --namespace istio-system \
  -f "${SCRIPT_DIR}/values-cni.yaml" \
  > "${SCRIPT_DIR}/install-cni.yaml"

echo "Rendering ztunnel ${VERSION}..."
helm template ztunnel istio/ztunnel \
  --version "${VERSION}" \
  --namespace istio-system \
  > "${SCRIPT_DIR}/install-ztunnel.yaml"

echo "Done: install-base.yaml, install-istiod.yaml, install-cni.yaml, install-ztunnel.yaml"
