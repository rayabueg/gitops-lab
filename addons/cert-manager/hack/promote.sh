#!/usr/bin/env bash
# Promotes base/latest → base/stable.
# Run after validating latest in a non-prod context.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rm -rf "${SCRIPT_DIR}/../base/stable"
cp -r  "${SCRIPT_DIR}/../base/latest" "${SCRIPT_DIR}/../base/stable"
echo "Promoted latest → stable"
