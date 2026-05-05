# BudgettedChart

Helm chart repository for running [Actual Budget](https://actualbudget.org/docs/install/) on Kubernetes, with optional [Enable Actual](https://github.com/2manyvcos/enable-actual) (Enable Banking integration).

## What this repository contains

- `charts/actual-budget`: Parent chart for Actual Budget.
- `charts/enable-actual`: Standalone chart for Enable Actual.
- Optional dependency from `actual-budget` to `enable-actual`, controlled by `enableActual.enabled`.
- GitHub Actions workflows to lint, package, and publish charts.

## Chart relationship

`actual-budget` declares an optional dependency on `enable-actual`:

- condition: `enableActual.enabled`
- alias: `enableActual`

All dependency values are configured under `enableActual.*` in `charts/actual-budget/values.yaml`.

## Quick start

### Install parent chart only (Actual Budget)

```bash
helm dependency build ./charts/actual-budget
helm upgrade --install actual-budget ./charts/actual-budget \
  --namespace actual-budget \
  --create-namespace
```

### Install parent chart with optional dependency enabled

```bash
helm dependency build ./charts/actual-budget
helm upgrade --install actual-budget ./charts/actual-budget \
  --namespace actual-budget \
  --create-namespace \
  --set enableActual.enabled=true
```

### Install `enable-actual` standalone

```bash
helm upgrade --install enable-actual ./charts/enable-actual \
  --namespace actual-budget \
  --create-namespace
```

## Storage

Actual Budget persistence (required):

- `actual.persistence.enabled=true`
- `actual.persistence.size=10Gi`

Enable Actual persistence:

- `enableActual.persistence.enabled=true`
- `enableActual.persistence.size=5Gi`

Use existing claims if needed:

```bash
helm upgrade --install actual-budget ./charts/actual-budget \
  --namespace actual-budget \
  --set actual.persistence.existingClaim=actual-data-pvc \
  --set enableActual.enabled=true \
  --set enableActual.persistence.existingClaim=enable-actual-data-pvc
```

## Important values

| Value | Description | Default |
| --- | --- | --- |
| `actual.image.repository` | Actual Budget image | `actualbudget/actual-server` |
| `actual.image.tag` | Actual Budget tag | `latest` |
| `actual.service.port` | Actual container/service port | `5006` |
| `actual.persistence.enabled` | Create PVC for Actual | `true` |
| `actual.persistence.size` | PVC size for Actual | `10Gi` |
| `actual.ingress.enabled` | Expose Actual through ingress | `false` |
| `enableActual.enabled` | Install `enable-actual` dependency | `false` |
| `enableActual.image.repository` | Enable Actual image | `2manyvcos/enable-actual` |
| `enableActual.service.port` | Enable Actual port | `3000` |
| `enableActual.actualServerUrl` | URL used by Enable Actual to reach Actual | `""` |
| `enableActual.persistence.enabled` | Create PVC for Enable Actual | `true` |
| `enableActual.persistence.size` | PVC size for Enable Actual | `5Gi` |
| `enableActual.ingress.enabled` | Expose Enable Actual through ingress | `false` |
| `enableActual.podSecurityContext.fsGroup` | Group ownership applied to mounted volume files | `1000` |
| `enableActual.containerSecurityContext.runAsUser` | Runtime UID for Enable Actual container | `1000` |

If `enableActual.actualServerUrl` is empty, the subchart defaults to `http://<release>-actual-budget-actual:5006`.

If your storage backend enforces existing ownership, you can override these IDs to match the volume permissions.

## CI/CD and publishing

Two workflows are provided:

- `.github/workflows/helm-lint.yaml`
  - Builds dependencies
  - Lints `charts/actual-budget` and `charts/enable-actual`
  - Renders manifests with and without optional dependency
- `.github/workflows/helm-release.yaml`
  - Publishes chart releases/index to GitHub Pages (via chart-releaser)
  - Pushes both charts to GitHub Container Registry (OCI) on tags (`v*`)

### Versioning strategy

The release workflow runs on every push to `main` and computes a clean SemVer version from the git history — no manual tagging required for publishing.

- **After a `vX.Y.Z` tag**: `X.Y.(Z + commits_since_tag)` — e.g. after `v1.4.2`, the 3rd push publishes `1.4.5`.
- **No tag yet**: `0.0.<total-commit-count>` — e.g. the 10th commit publishes `0.0.10`.

Optional git tags (`vX.Y.Z`) can still be used as version anchors to reset the patch counter and signal intentional milestones, but they are not required for publishing.

### Required repository settings

1. Enable **GitHub Pages** with source branch `gh-pages` (root).
2. Ensure Actions has write permissions (Settings -> Actions -> General -> Workflow permissions -> Read and write).
3. No extra secrets are required for GitHub-only publishing because workflows use `GITHUB_TOKEN`.

### Published chart endpoints

- Helm repo index (Pages): `https://<github-user>.github.io/<repo-name>`
- OCI registry: `oci://ghcr.io/<github-user>/charts`

Example OCI install:

```bash
helm install actual-budget oci://ghcr.io/<github-user>/charts/actual-budget --version 0.1.0
helm install enable-actual oci://ghcr.io/<github-user>/charts/enable-actual --version 0.1.0
```
