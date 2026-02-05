#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="${APPS_DIR:-$SCRIPT_DIR}"
CHART_TGZ="${CHART_TGZ:-$APPS_DIR/helm-template_v0.11.1.tgz}"

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required but not found in PATH" >&2
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required but not found in PATH" >&2
  exit 1
fi

if [[ ! -f "$CHART_TGZ" ]]; then
  echo "Helm chart not found at: $CHART_TGZ" >&2
  exit 1
fi

# Finds all values.yaml under the applications directory, excluding the chart package and this script.
mapfile -t VALUES_FILES < <(
  find "$APPS_DIR" -type f -name "values.yaml" \
    ! -path "*/charts/*" \
    ! -path "*/.git/*" \
    | sort
)

if [[ ${#VALUES_FILES[@]} -eq 0 ]]; then
  echo "No values.yaml files found under $APPS_DIR" >&2
  exit 1
fi

echo "Using chart: $CHART_TGZ"
echo "Found ${#VALUES_FILES[@]} app values files."

for values_path in "${VALUES_FILES[@]}"; do
  # Determine namespace = first-level directory name under applications
  rel_path="${values_path#$APPS_DIR/}"
  namespace="${rel_path%%/*}"

  # Determine release name:
  # - If values.yaml is directly under namespace, release = namespace
  # - If nested (e.g., cart/apps/values.yaml), release = namespace-subdir
  rel_dir="$(dirname "$rel_path")"
  if [[ "$rel_dir" == "$namespace" ]]; then
    release="$namespace"
  else
    subpath="${rel_dir#${namespace}/}"
    release="${namespace}-${subpath//\//-}"
  fi

  echo "------------------------------------------------------------"
  echo "Deploying release: $release"
  echo "Namespace: $namespace"
  echo "Values: $values_path"

  kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -

  helm upgrade --install "$release" "$CHART_TGZ" \
    --namespace "$namespace" \
    --create-namespace \
    --values "$values_path"
done

echo "All applications deployed."
