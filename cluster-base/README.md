# Cluster Base Module

Installs ArgoCD on a Kubernetes cluster via Helm.

## Usage

```hcl
module "cluster_base" {
  source = "git::https://github.com/Matchpoint-AI/rackspace-spot-terraform-modules.git//cluster-base?ref=v1.0.0"

  cluster_endpoint       = module.cloudspace.cluster_endpoint
  cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
  cluster_token          = module.cloudspace.cluster_token
  argocd_chart_version   = "5.51.6"
}
```

## Dependencies

This module requires kubeconfig outputs from the cloudspace module.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| kubernetes | >= 2.23.0 |
| helm | >= 2.11.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_endpoint | Kubernetes API endpoint | string | n/a | yes |
| cluster_ca_certificate | Base64-encoded CA cert | string | n/a | yes |
| cluster_token | Auth token | string | n/a | yes |
| argocd_chart_version | Helm chart version | string | "5.51.6" | no |
| argocd_namespace | ArgoCD namespace | string | "argocd" | no |
| argocd_helm_timeout | Helm timeout (seconds) | number | 600 | no |

## Outputs

| Name | Description |
|------|-------------|
| argocd_namespace | Namespace where ArgoCD is installed |
| argocd_release_name | Helm release name |
| argocd_chart_version | Installed chart version |
