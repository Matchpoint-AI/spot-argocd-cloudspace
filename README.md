# Spot ArgoCD Cloudspace

Terraform modules for deploying GitHub Actions runners on Rackspace Spot infrastructure with ArgoCD GitOps.

## Modules

| Module | Description |
|--------|-------------|
| [cloudspace](./cloudspace) | Rackspace Spot managed Kubernetes cluster and node pool |
| [cluster-base](./cluster-base) | ArgoCD installation via Helm |
| [arc-prereqs](./arc-prereqs) | ARC namespaces and GitHub token secret |
| [argocd-bootstrap](./argocd-bootstrap) | Generic ArgoCD Application bootstrap (App-of-Apps pattern) |
| [argocd-apps](./argocd-apps) | Bootstrap ArgoCD Application for ARC deployment (legacy) |

## Deployment Order

```
1. cloudspace       -> Creates Kubernetes cluster
2. cluster-base     -> Installs ArgoCD via Helm
3. arc-prereqs      -> Creates namespaces + GitHub secret
4. argocd-bootstrap -> Creates ArgoCD Application
                       └─> ArgoCD syncs ARC controller + runners
```

## Usage with Terragrunt

These modules are designed to be used with Terragrunt for managing live infrastructure.

### Version Management

Create a `versions.hcl` file to centralize module version control:

```hcl
# infrastructure/live/versions.hcl
locals {
  tf_modules_base    = "github.com/Matchpoint-AI/spot-argocd-cloudspace.git"
  tf_modules_repo    = "git::https://${local.tf_modules_base}"
  tf_modules_version = "v1.2.0"
}
```

### Using Modules

```hcl
# terragrunt.hcl
locals {
  source_config = read_terragrunt_config(find_in_parent_folders("versions.hcl"))
}

terraform {
  source = "${local.source_config.locals.tf_modules_repo}//cloudspace?ref=${local.source_config.locals.tf_modules_version}"
}
```

### Upgrading Versions

To upgrade all modules, change the version in `versions.hcl`:

```diff
locals {
  tf_modules_base    = "github.com/Matchpoint-AI/spot-argocd-cloudspace.git"
  tf_modules_repo    = "git::https://${local.tf_modules_base}"
- tf_modules_version = "v1.2.0"
+ tf_modules_version = "v1.3.0"
}
```

## Direct Terraform Usage

```hcl
module "cloudspace" {
  source = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git//cloudspace?ref=v1.2.0"

  cluster_name         = "my-runners"
  region               = "us-central-dfw-1"
  rackspace_spot_token = var.rackspace_spot_token
}

module "cluster_base" {
  source = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git//cluster-base?ref=v1.2.0"

  cluster_endpoint       = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
  cluster_token          = module.cloudspace.cluster_token
}

module "arc_prereqs" {
  source = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git//arc-prereqs?ref=v1.2.0"

  cluster_endpoint       = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
  cluster_token          = module.cloudspace.cluster_token
  github_token           = var.github_token
}

module "argocd_bootstrap" {
  source = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git//argocd-bootstrap?ref=v1.2.0"

  cluster_endpoint       = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
  cluster_token          = module.cloudspace.cluster_token
  application_name       = "github-runners-bootstrap"
  repo_url               = "https://github.com/your-org/your-runners-repo"
  sync_path              = "argocd/applications"
  target_revision        = "main"
}
```

## Local Development

For local testing, use `--terragrunt-source` to override the remote source:

```bash
terragrunt plan --terragrunt-source ../../../spot-argocd-cloudspace//cloudspace
```

## License

MIT
