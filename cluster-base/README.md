# Cluster Base Module

Installs ArgoCD on the cluster and optionally creates a bootstrap Application.

## Overview

This module provides a complete GitOps foundation:
1. Installs ArgoCD via Helm
2. Optionally creates a bootstrap Application pointing to your Git repository
3. ArgoCD then syncs and manages all other resources from Git

## Usage

**IMPORTANT:** This module requires provider configuration from the caller. Use a terragrunt
`generate` block or root module provider blocks to configure the kubernetes and helm providers.

### Terragrunt Usage (Recommended)

```hcl
# terragrunt.hcl
terraform {
  source = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git//cluster-base?ref=v4.1.0"
}

dependency "cloudspace" {
  config_path = "../1-cloudspace"
}

# Generate provider configuration - required for this module
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubernetes" {
      host                   = "${dependency.cloudspace.outputs.cluster_endpoint}"
      cluster_ca_certificate = base64decode("${dependency.cloudspace.outputs.cluster_ca_certificate}")
      token                  = "${dependency.cloudspace.outputs.cluster_token}"
    }
    provider "helm" {
      kubernetes {
        host                   = "${dependency.cloudspace.outputs.cluster_endpoint}"
        cluster_ca_certificate = base64decode("${dependency.cloudspace.outputs.cluster_ca_certificate}")
        token                  = "${dependency.cloudspace.outputs.cluster_token}"
      }
    }
  EOF
}

inputs = {
  # Enable bootstrap Application
  bootstrap_enabled         = true
  bootstrap_app_name        = "my-app-bootstrap"
  bootstrap_repo_url        = "https://github.com/my-org/my-app"
  bootstrap_sync_path       = "argocd"
  bootstrap_target_revision = "main"
}
```

### Plain Terraform Usage

```hcl
# Configure providers in your root module
provider "kubernetes" {
  host                   = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cloudspace.cluster_ca_certificate)
  token                  = module.cloudspace.cluster_token
}

provider "helm" {
  kubernetes {
    host                   = module.cloudspace.cluster_endpoint
    cluster_ca_certificate = base64decode(module.cloudspace.cluster_ca_certificate)
    token                  = module.cloudspace.cluster_token
  }
}

module "cluster_base" {
  source = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git//cluster-base?ref=v4.1.0"

  # Enable bootstrap Application
  bootstrap_enabled         = true
  bootstrap_app_name        = "my-app-bootstrap"
  bootstrap_repo_url        = "https://github.com/my-org/my-app"
  bootstrap_sync_path       = "argocd"
  bootstrap_target_revision = "main"
}
```

## 2-Stage Architecture

With bootstrap enabled, you only need 2 Terraform stages:

```
Stage 1: cloudspace      → Creates Kubernetes cluster
Stage 2: cluster-base    → Installs ArgoCD + Bootstrap Application
                           └─> ArgoCD syncs from Git:
                               ├── prereqs/
                               │   ├── namespaces.yaml
                               │   └── external-secrets.yaml
                               └── applications/
                                   └── my-app.yaml
```

## Inputs

**Note:** Cluster authentication is configured via provider blocks, not module inputs.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| argocd_chart_version | ArgoCD Helm chart version | `string` | `"5.51.6"` | no |
| argocd_namespace | Kubernetes namespace for ArgoCD | `string` | `"argocd"` | no |
| bootstrap_enabled | Enable bootstrap ArgoCD Application | `bool` | `false` | no |
| bootstrap_app_name | Name of the bootstrap Application | `string` | `"bootstrap"` | no |
| bootstrap_repo_url | Git repository URL to sync from | `string` | `""` | no |
| bootstrap_sync_path | Path in Git repository to sync | `string` | `"argocd"` | no |
| bootstrap_target_revision | Git branch, tag, or commit SHA | `string` | `"main"` | no |

## Outputs

| Name | Description |
|------|-------------|
| argocd_namespace | Namespace where ArgoCD is installed |
| argocd_chart_version | Installed ArgoCD Helm chart version |
| bootstrap_enabled | Whether bootstrap application was created |
| bootstrap_app_name | Name of the bootstrap Application |
| bootstrap_sync_source | ArgoCD sync source configuration |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| kubernetes | >= 2.23.0 |
| helm | >= 2.11.0 |
