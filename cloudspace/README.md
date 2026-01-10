# Cloudspace Module

Creates a Rackspace Spot managed Kubernetes cluster and node pool.

## Usage

```hcl
module "cloudspace" {
  source = "git::https://github.com/Matchpoint-AI/rackspace-spot-terraform-modules.git//cloudspace?ref=v1.0.0"

  cluster_name         = "my-runners"
  region               = "us-central-dfw-1"
  rackspace_spot_token = var.rackspace_spot_token
  server_class         = "gp.vs1.large"
  min_nodes            = 2
  max_nodes            = 15
}
```

## Timing

Control plane provisioning takes **50-60 minutes**. Plan workflows accordingly.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| spot | >= 0.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the Kubernetes cluster | string | n/a | yes |
| region | Rackspace Spot region | string | n/a | yes |
| rackspace_spot_token | Rackspace Spot API token | string | n/a | yes |
| server_class | Node pool server class | string | "gp.vs1.xlarge-dfw" | no |
| min_nodes | Minimum nodes in pool | number | 4 | no |
| max_nodes | Maximum nodes in pool | number | 30 | no |
| bid_price | Bid price per node per hour | number | 0.35 | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudspace_name | Name of the cluster |
| cluster_endpoint | Kubernetes API endpoint |
| cluster_ca_certificate | Base64-encoded CA cert |
| cluster_token | Auth token for cluster |
