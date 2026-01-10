# ArgoCD Bootstrap Module - Outputs

output "application_name" {
  description = "Name of the bootstrap ArgoCD Application"
  value       = kubernetes_manifest.bootstrap_application.manifest.metadata.name
}

output "application_namespace" {
  description = "Namespace of the bootstrap ArgoCD Application"
  value       = var.argocd_namespace
}

output "sync_source" {
  description = "ArgoCD sync source configuration"
  value = {
    repo_url        = var.repo_url
    target_revision = var.target_revision
    path            = var.sync_path
  }
}
