# ARC Prerequisites Module

Creates the Kubernetes resources required before ArgoCD can sync ARC (Actions Runner Controller) applications.

## Overview

This module provisions:
- **arc-systems namespace** - For the ARC controller
- **arc-runners namespace** - For runner pods
- **GitHub token secret** - For runner registration with GitHub

This module should be applied **BEFORE** `argocd-bootstrap`, which creates the ArgoCD Application that syncs the actual ARC deployments.

## Usage

```hcl
module "arc_prereqs" {
  source = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git//arc-prereqs?ref=v1.2.0"

  # Cluster authentication (from cloudspace module)
  cluster_endpoint       = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
  cluster_token          = module.cloudspace.cluster_token

  # GitHub token for runner registration
  github_token = var.github_token
}
```

## GitHub Token Requirements

The GitHub PAT requires the following scopes:
- `admin:org` - For organization-level runner management
- `manage_runners:org` - For creating/deleting runners

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_endpoint | Kubernetes API server endpoint | string | - | yes |
| cluster_ca_certificate | Base64-encoded cluster CA certificate | string | - | yes |
| cluster_token | Authentication token for the cluster | string | - | yes |
| github_token | GitHub PAT for runner registration | string | - | yes |
| arc_namespace | Namespace for ARC controller | string | `"arc-systems"` | no |
| arc_runners_namespace | Namespace for runner pods | string | `"arc-runners"` | no |
| github_secret_name | Name of the K8s secret for GitHub token | string | `"arc-org-github-secret"` | no |

## Outputs

| Name | Description |
|------|-------------|
| arc_namespace | Namespace for ARC controller |
| runner_namespace | Namespace for runner pods |
| github_secret_name | Name of the GitHub token secret |
| github_secret_namespace | Namespace containing the secret |

## Deployment Order

```
1. cloudspace       -> Creates Kubernetes cluster
2. cluster-base     -> Installs ArgoCD via Helm
3. arc-prereqs      -> Creates namespaces + secret (THIS MODULE)
4. argocd-bootstrap -> Creates ArgoCD Application
                       └─> ArgoCD syncs ARC controller + runners
```

## Migration from argocd-apps

If migrating from the combined `argocd-apps` module:

```bash
# Move namespace and secret state to new module
terraform state mv \
  'module.argocd_apps.kubernetes_namespace_v1.arc_systems' \
  'module.arc_prereqs.kubernetes_namespace_v1.arc_systems'

terraform state mv \
  'module.argocd_apps.kubernetes_namespace_v1.arc_runners' \
  'module.arc_prereqs.kubernetes_namespace_v1.arc_runners'

terraform state mv \
  'module.argocd_apps.kubernetes_secret_v1.github_token' \
  'module.arc_prereqs.kubernetes_secret_v1.github_token'
```

Then update your terragrunt/terraform to use this module.
