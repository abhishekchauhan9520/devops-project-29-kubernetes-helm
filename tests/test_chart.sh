#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHART="$ROOT/chart"

command -v helm >/dev/null 2>&1 || { echo "helm CLI is required for chart tests" >&2; exit 127; }

helm lint "$CHART" --strict
helm template test "$CHART" --values "$CHART/values-staging.yaml" >/tmp/project29-staging.yaml
helm template test "$CHART" --values "$CHART/values-production.yaml" >/tmp/project29-production.yaml

for f in /tmp/project29-staging.yaml /tmp/project29-production.yaml; do
  grep -q '^kind: Deployment$' "$f"
  grep -q '^kind: Service$' "$f"
  grep -q '^kind: HorizontalPodAutoscaler$' "$f"
  grep -q '^kind: PodDisruptionBudget$' "$f"
  grep -q '^kind: NetworkPolicy$' "$f"
  grep -q 'readOnlyRootFilesystem: true' "$f"
  grep -q 'runAsNonRoot: true' "$f"
  grep -q 'type: RuntimeDefault' "$f"
  grep -q 'startupProbe:' "$f"
  grep -q 'readinessProbe:' "$f"
  grep -q 'livenessProbe:' "$f"
done

echo 'Project 29 Helm chart tests passed.'
