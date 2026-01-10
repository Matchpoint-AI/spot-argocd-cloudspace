# ArgoCD Bootstrap Module - Input Variables

# -----------------------------------------------------------------------------
# Kubeconfig Components (from cloudspace module)
# -----------------------------------------------------------------------------
variable "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  type        = string
  sensitive   = true
}

variable "cluster_token" {
  description = "Authentication token for the cluster"
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Application Configuration (Required)
# -----------------------------------------------------------------------------
variable "application_name" {
  description = "Name of the bootstrap ArgoCD Application"
  type        = string
}

variable "repo_url" {
  description = "Git repository URL for ArgoCD to sync from"
  type        = string
}

variable "sync_path" {
  description = "Path in the Git repository to sync applications from"
  type        = string
}

# -----------------------------------------------------------------------------
# Application Configuration (Optional)
# -----------------------------------------------------------------------------
variable "target_revision" {
  description = "Git branch, tag, or commit SHA for ArgoCD to sync"
  type        = string
  default     = "main"
}

variable "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD is installed"
  type        = string
  default     = "argocd"
}

variable "argocd_project" {
  description = "ArgoCD project to use for the application"
  type        = string
  default     = "default"
}

# -----------------------------------------------------------------------------
# Sync Policy Configuration
# -----------------------------------------------------------------------------
variable "auto_prune" {
  description = "Enable automatic pruning of resources no longer in Git"
  type        = bool
  default     = true
}

variable "self_heal" {
  description = "Enable automatic self-healing of drifted resources"
  type        = bool
  default     = true
}
