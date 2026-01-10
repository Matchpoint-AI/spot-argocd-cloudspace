# ArgoCD Bootstrap Module

Creates a bootstrap ArgoCD Application that syncs from a Git repository.

## Overview

This is a **generic** module that only creates the ArgoCD Application CRD.
Any application-specific resources (namespaces, secrets, ConfigMaps, etc.)
should be managed by ArgoCD via manifests in the synced repository.

This follows the "App of Apps" GitOps pattern where:
1. Terraform creates the cluster and installs ArgoCD
2. Terraform creates a bootstrap Application pointing to your repo
3. ArgoCD syncs and manages all other applications from Git

## Usage

```hcl
module "argocd_bootstrap" {
  source = "git::https://github.com/Matchpoint-AI/rackspace-spot-terraform-modules.git//argocd-bootstrap?ref=v1.1.0"

  # Cluster authentication (from cloudspace module)
  cluster_endpoint       = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
  cluster_token          = module.cloudspace.cluster_token

  # Application configuration
  application_name = "my-app-bootstrap"
  repo_url         = "https://github.com/my-org/my-app"
  sync_path        = "argocd/applications"
  target_revision  = "main"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_endpoint | Kubernetes API server endpoint | `string` | n/a | yes |
| cluster_ca_certificate | Base64-encoded cluster CA certificate | `string` | n/a | yes |
| cluster_token | Authentication token for the cluster | `string` | n/a | yes |
| application_name | Name of the bootstrap ArgoCD Application | `string` | n/a | yes |
| repo_url | Git repository URL for ArgoCD to sync from | `string` | n/a | yes |
| sync_path | Path in the Git repository to sync applications from | `string` | n/a | yes |
| target_revision | Git branch, tag, or commit SHA | `string` | `"main"` | no |
| argocd_namespace | Namespace where ArgoCD is installed | `string` | `"argocd"` | no |
| argocd_project | ArgoCD project to use | `string` | `"default"` | no |
| auto_prune | Enable automatic pruning of resources | `bool` | `true` | no |
| self_heal | Enable automatic self-healing | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| application_name | Name of the bootstrap ArgoCD Application |
| application_namespace | Namespace of the ArgoCD Application |
| sync_source | ArgoCD sync source configuration (repo_url, target_revision, path) |

## Example: GitHub Actions Runners

For GitHub Actions runners, the synced repository should contain:

```
argocd/
├── applications/
│   ├── arc-prereqs.yaml      # Namespaces + ExternalSecrets
│   ├── arc-controller.yaml   # ARC controller Helm chart
│   └── arc-runners.yaml      # Runner scale set Helm chart
```

The `arc-prereqs.yaml` would create:
- `arc-systems` namespace for the controller
- `arc-runners` namespace for runner pods
- ExternalSecret to pull GitHub token from secret manager

## Migration from argocd-apps

If migrating from the `argocd-apps` module:

1. Create ArgoCD manifests for namespaces and secrets in your app repo
2. Update terragrunt to use `argocd-bootstrap` instead of `argocd-apps`
3. Remove `github_token` from terragrunt inputs
4. Run `terraform plan` to verify no infrastructure changes

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| kubernetes | >= 2.23.0 |

## Dependencies

This module should be applied after:
1. `cloudspace` module (Kubernetes cluster)
2. `cluster-base` module (ArgoCD installation)
