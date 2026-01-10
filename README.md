# Spot ArgoCD Cloudspace

Generic Terraform modules for deploying ArgoCD-managed workloads on Rackspace Spot infrastructure.

## Modules

| Module | Description |
|--------|-------------|
| [cloudspace](./cloudspace) | Rackspace Spot managed Kubernetes cluster and node pool |
| [cluster-base](./cluster-base) | ArgoCD installation + optional bootstrap Application |

## 2-Stage Architecture

This repo enables a clean 2-stage GitOps architecture:

```
Stage 1: cloudspace     → Creates Kubernetes cluster
Stage 2: cluster-base   → Installs ArgoCD + Bootstrap Application
                          └─> ArgoCD syncs from Git:
                              ├── prereqs/
                              │   ├── namespaces.yaml
                              │   └── external-secrets.yaml
                              └── applications/
                                  └── my-app.yaml
```

After Stage 2, ArgoCD manages everything else from Git manifests.

## Usage with Terragrunt

### versions.hcl

```hcl
locals {
  remote_modules  = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git"
  modules_version = "v4.0.0"
}
```

### 1-cloudspace/terragrunt.hcl

```hcl
terraform {
  source = "${local.versions.locals.remote_modules}//cloudspace?ref=${local.versions.locals.modules_version}"
}

inputs = {
  cluster_name         = "my-cluster"
  region               = "us-central-dfw-1"
  rackspace_spot_token = get_env("RACKSPACE_SPOT_TOKEN")
}
```

### 2-cluster-base/terragrunt.hcl

```hcl
terraform {
  source = "${local.versions.locals.remote_modules}//cluster-base?ref=${local.versions.locals.modules_version}"
}

inputs = {
  cluster_endpoint       = dependency.cloudspace.outputs.cluster_endpoint
  cluster_ca_certificate = dependency.cloudspace.outputs.cluster_ca_certificate
  cluster_token          = dependency.cloudspace.outputs.cluster_token

  # Enable bootstrap Application
  bootstrap_enabled         = true
  bootstrap_app_name        = "my-app-bootstrap"
  bootstrap_repo_url        = "https://github.com/my-org/my-app"
  bootstrap_sync_path       = "argocd"
  bootstrap_target_revision = "main"
}
```

## Direct Terraform Usage

```hcl
module "cloudspace" {
  source = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git//cloudspace?ref=v4.0.0"

  cluster_name         = "my-cluster"
  region               = "us-central-dfw-1"
  rackspace_spot_token = var.rackspace_spot_token
}

module "cluster_base" {
  source = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git//cluster-base?ref=v4.0.0"

  cluster_endpoint       = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
  cluster_token          = module.cloudspace.cluster_token

  bootstrap_enabled         = true
  bootstrap_app_name        = "my-app-bootstrap"
  bootstrap_repo_url        = "https://github.com/my-org/my-app"
  bootstrap_sync_path       = "argocd"
  bootstrap_target_revision = "main"
}
```

## License

MIT
