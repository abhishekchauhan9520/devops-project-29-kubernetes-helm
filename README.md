# Project 29 — Production Helm Deployment

A reusable, production-oriented Helm chart for deploying a secure Kubernetes web workload across staging and production environments.

## What this demonstrates

- Helm chart design and templating
- Values-driven environments
- Helm schema validation
- Rolling upgrades
- `--wait --atomic` deployment safety
- Helm test hooks
- HPA with scale-up/scale-down behavior
- PodDisruptionBudget
- Ingress + TLS
- NetworkPolicy
- Pod/container hardening
- Config checksum rollouts
- Topology spreading and anti-affinity
- CI linting and rendering

## Layout

```text
chart/
├── Chart.yaml
├── values.yaml
├── values.schema.json
├── values-staging.yaml
├── values-production.yaml
└── templates/
    ├── _helpers.tpl
    ├── resources.yaml
    └── tests/healthcheck.yaml
```

## Validate

```bash
helm lint ./chart --strict
helm template staging ./chart -f ./chart/values-staging.yaml
helm template production ./chart -f ./chart/values-production.yaml
bash tests/test_chart.sh
```

`helm lint` checks charts for issues and `helm template` renders Kubernetes manifests locally; both are standard Helm chart validation commands. citeturn180432search1turn180432search2

## Install / upgrade

```bash
helm upgrade --install myapp ./chart \
  --namespace myapp \
  --create-namespace \
  -f ./chart/values-staging.yaml \
  --wait --atomic
```

The `--atomic` pattern makes a failed upgrade roll back automatically while Helm waits for readiness.

## Production

```bash
helm upgrade --install myapp ./chart \
  --namespace production \
  --create-namespace \
  -f ./chart/values-production.yaml \
  --set image.repository=ghcr.io/YOUR_ORG/YOUR_IMAGE \
  --set image.tag=YOUR_IMMUTABLE_TAG \
  --wait --atomic
```

## Rollback

```bash
helm history myapp -n production
helm rollback myapp <REVISION> -n production --wait
```

## Test the release

```bash
helm test myapp -n production --logs
```

## Design notes

The chart uses `apiVersion: v2`, compatible with current Helm 3/4 chart workflows. Helm's current stable release is v4.2.4. citeturn180432search6turn180432search14

The default workload runs non-root, drops Linux capabilities, uses a read-only root filesystem, and disables automatic service-account-token mounting. Runtime configuration changes trigger a Deployment rollout through a ConfigMap checksum annotation.

The NetworkPolicy ingress selector is configurable by values. Real environments should set it to the exact ingress-controller or caller identity used by the platform.
