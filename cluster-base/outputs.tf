# Cluster Base Module - Outputs

output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = kubernetes_namespace_v1.argocd.metadata[0].name
}

output "argocd_chart_version" {
  description = "Installed ArgoCD Helm chart version"
  value       = helm_release.argocd.version
}

# -----------------------------------------------------------------------------
# Bootstrap Application Outputs (when enabled)
# -----------------------------------------------------------------------------
output "bootstrap_enabled" {
  description = "Whether bootstrap application was created"
  value       = var.bootstrap_enabled
}

output "bootstrap_app_name" {
  description = "Name of the bootstrap ArgoCD Application"
  value       = var.bootstrap_enabled ? var.bootstrap_app_name : null
}

output "bootstrap_sync_source" {
  description = "ArgoCD sync source configuration"
  value = var.bootstrap_enabled ? {
    repo_url        = var.bootstrap_repo_url
    target_revision = var.bootstrap_target_revision
    path            = var.bootstrap_sync_path
  } : null
}
