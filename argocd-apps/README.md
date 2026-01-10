# ArgoCD Apps Module

Creates the bootstrap ArgoCD Application that manages ARC deployment using the App-of-Apps GitOps pattern.

## Architecture

```
Terraform                     ArgoCD                     Kubernetes
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ - Namespaces    │────▶│ Bootstrap App   │────▶│ arc-systems/    │
│ - GitHub Secret │     │ (syncs repo)    │     │ arc-runners/    │
│ - Bootstrap App │     └─────────────────┘     └─────────────────┘
└─────────────────┘
```

This module:
1. Creates `arc-systems` and `arc-runners` namespaces
2. Creates the GitHub token secret for runner registration
3. Applies a bootstrap ArgoCD Application CRD

ArgoCD then syncs the specified repo path and manages runner infrastructure.

## Usage

```hcl
module "argocd_apps" {
  source = "git::https://github.com/Matchpoint-AI/rackspace-spot-terraform-modules.git//argocd-apps?ref=v1.0.0"

  cluster_endpoint       = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
  cluster_token          = module.cloudspace.cluster_token
  github_token           = var.github_token
  repo_url               = "https://github.com/your-org/your-runners-repo"
  target_revision        = "main"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| kubernetes | >= 2.23.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_endpoint | Kubernetes API endpoint | string | n/a | yes |
| cluster_ca_certificate | Base64-encoded CA cert | string | n/a | yes |
| cluster_token | Auth token | string | n/a | yes |
| github_token | GitHub PAT for runners | string | n/a | yes |
| repo_url | Git repo for ArgoCD sync | string | n/a | yes |
| target_revision | Git ref to sync | string | "main" | no |
| bootstrap_app_name | ArgoCD app name | string | "github-runners-bootstrap" | no |

## Outputs

| Name | Description |
|------|-------------|
| bootstrap_application_name | Name of bootstrap app |
| runner_namespace | Runner pods namespace |
| arc_controller_namespace | ARC controller namespace |
