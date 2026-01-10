# Rackspace Spot Terraform Modules

Reusable Terraform modules for deploying GitHub Actions runners on Rackspace Spot infrastructure.

## Modules

| Module | Description |
|--------|-------------|
| [cloudspace](./cloudspace) | Rackspace Spot managed Kubernetes cluster and node pool |
| [cluster-base](./cluster-base) | ArgoCD installation via Helm |
| [argocd-apps](./argocd-apps) | Bootstrap ArgoCD Application for ARC deployment |

## Usage with Terragrunt

These modules are designed to be used with Terragrunt for managing live infrastructure.

### Version Management

Create a `versions.hcl` file to centralize module version control:

```hcl
# infrastructure/live/versions.hcl
locals {
  tf_modules_base    = "github.com/Matchpoint-AI/rackspace-spot-terraform-modules.git"
  tf_modules_repo    = "git::https://${local.tf_modules_base}"
  tf_modules_version = "v1.0.0"
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
  tf_modules_base    = "github.com/Matchpoint-AI/rackspace-spot-terraform-modules.git"
  tf_modules_repo    = "git::https://${local.tf_modules_base}"
- tf_modules_version = "v1.0.0"
+ tf_modules_version = "v1.1.0"
}
```

## Direct Terraform Usage

```hcl
module "cloudspace" {
  source = "git::https://github.com/Matchpoint-AI/rackspace-spot-terraform-modules.git//cloudspace?ref=v1.0.0"

  cluster_name         = "my-runners"
  region               = "us-central-dfw-1"
  rackspace_spot_token = var.rackspace_spot_token
}

module "cluster_base" {
  source = "git::https://github.com/Matchpoint-AI/rackspace-spot-terraform-modules.git//cluster-base?ref=v1.0.0"

  cluster_endpoint       = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
  cluster_token          = module.cloudspace.cluster_token
}

module "argocd_apps" {
  source = "git::https://github.com/Matchpoint-AI/rackspace-spot-terraform-modules.git//argocd-apps?ref=v1.0.0"

  cluster_endpoint       = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
  cluster_token          = module.cloudspace.cluster_token
  github_token           = var.github_token
  repo_url               = "https://github.com/your-org/your-runners-repo"
}
```

## Local Development

For local testing, use `--terragrunt-source` to override the remote source:

```bash
terragrunt plan --terragrunt-source ../../../rackspace-spot-terraform-modules//cloudspace
```

## License

MIT
