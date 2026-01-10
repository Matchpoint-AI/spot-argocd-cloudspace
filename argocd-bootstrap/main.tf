# ArgoCD Bootstrap Module
#
# Creates a bootstrap ArgoCD Application that syncs from a Git repository.
# This is a generic module - it only creates the Application CRD.
# Any application-specific resources (namespaces, secrets, etc.) should be
# managed by ArgoCD via manifests in the synced repository.
#
# Usage:
#   module "argocd_bootstrap" {
#     source = "git::https://github.com/Matchpoint-AI/rackspace-spot-terraform-modules.git//argocd-bootstrap?ref=v1.1.0"
#
#     cluster_endpoint       = module.cloudspace.cluster_endpoint
#     cluster_ca_certificate = module.cloudspace.cluster_ca_certificate
#     cluster_token          = module.cloudspace.cluster_token
#
#     application_name = "my-app-bootstrap"
#     repo_url         = "https://github.com/my-org/my-app"
#     sync_path        = "argocd/applications"
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

# -----------------------------------------------------------------------------
# Bootstrap ArgoCD Application
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "bootstrap_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.application_name
      namespace = var.argocd_namespace
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = var.argocd_project
      source = {
        repoURL        = var.repo_url
        targetRevision = var.target_revision
        path           = var.sync_path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_namespace
      }
      syncPolicy = {
        automated = {
          prune    = var.auto_prune
          selfHeal = var.self_heal
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}
