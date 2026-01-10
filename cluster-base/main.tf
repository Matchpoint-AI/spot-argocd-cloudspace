# Cluster Base Module
#
# Installs ArgoCD on the cluster and optionally creates a bootstrap Application.
# This follows the "App of Apps" GitOps pattern where:
# 1. Terraform creates the cluster (cloudspace module)
# 2. This module installs ArgoCD + creates bootstrap Application
# 3. ArgoCD syncs and manages everything else from Git

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Provider Configuration
# Uses variables passed from terragrunt dependency outputs
# -----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token                  = var.cluster_token
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    token                  = var.cluster_token
  }
}

# -----------------------------------------------------------------------------
# ArgoCD Namespace
# -----------------------------------------------------------------------------
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

# -----------------------------------------------------------------------------
# ArgoCD Installation via Helm
# -----------------------------------------------------------------------------
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name

  wait    = true
  timeout = var.argocd_helm_timeout

  values = [yamlencode({
    server = {
      service = {
        type = var.argocd_service_type
      }
    }
    dex = {
      enabled = var.argocd_dex_enabled
    }
    repoServer = {
      replicas = var.argocd_repo_server_replicas
    }
  })]

  depends_on = [kubernetes_namespace_v1.argocd]
}

# -----------------------------------------------------------------------------
# Bootstrap ArgoCD Application (Optional)
# Creates an Application that syncs from a Git repository.
# ArgoCD will then manage all other resources from Git manifests.
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "bootstrap_application" {
  count = var.bootstrap_enabled ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.bootstrap_app_name
      namespace = var.argocd_namespace
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = var.argocd_project
      source = {
        repoURL        = var.bootstrap_repo_url
        targetRevision = var.bootstrap_target_revision
        path           = var.bootstrap_sync_path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_namespace
      }
      syncPolicy = {
        automated = {
          prune    = var.bootstrap_auto_prune
          selfHeal = var.bootstrap_self_heal
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [helm_release.argocd]
}
