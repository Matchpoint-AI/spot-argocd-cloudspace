# ARC Prerequisites Module
#
# Creates the Kubernetes resources required before ArgoCD can sync ARC applications:
# - arc-systems namespace (for controller)
# - arc-runners namespace (for runner pods)
# - GitHub token secret (for runner registration)
#
# This module should be applied BEFORE argocd-bootstrap, which creates the
# ArgoCD Application that syncs the actual ARC deployments.
#
# Usage:
#   module "arc_prereqs" {
#     source = "git::https://github.com/Matchpoint-AI/spot-argocd-cloudspace.git//arc-prereqs?ref=v1.2.0"
#
#     cluster_endpoint       = module.cloudspace.cluster_endpoint
#     cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
#     cluster_token          = module.cloudspace.cluster_token
#
#     github_token = var.github_token
#   }

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Provider Configuration
# -----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token                  = var.cluster_token
}

locals {
  arc_namespace    = var.arc_namespace
  runner_namespace = var.arc_runners_namespace
}

# -----------------------------------------------------------------------------
# ARC System Namespace (for controller)
# -----------------------------------------------------------------------------
resource "kubernetes_namespace_v1" "arc_systems" {
  metadata {
    name = local.arc_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/component"  = "arc-controller"
    }
  }
}

# -----------------------------------------------------------------------------
# ARC Runners Namespace (for runner pods)
# -----------------------------------------------------------------------------
resource "kubernetes_namespace_v1" "arc_runners" {
  metadata {
    name = local.runner_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/component"  = "arc-runners"
    }
  }
}

# -----------------------------------------------------------------------------
# GitHub Token Secret for Runner Registration
# Uses PAT with admin:org and manage_runners:org scopes
# This must exist before ArgoCD syncs the runner Application
# -----------------------------------------------------------------------------
resource "kubernetes_secret_v1" "github_token" {
  metadata {
    name      = var.github_secret_name
    namespace = local.runner_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/component"  = "arc-runners"
    }
  }

  data = {
    github_token = var.github_token
  }

  depends_on = [kubernetes_namespace_v1.arc_runners]
}
