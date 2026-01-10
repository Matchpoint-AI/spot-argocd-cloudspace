# Cluster Base Module - Input Variables

# -----------------------------------------------------------------------------
# Cluster Authentication
# These are passed from the cloudspace dependency in terragrunt
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
# ArgoCD Helm Configuration
# -----------------------------------------------------------------------------
variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6" # Maps to ArgoCD 2.10.x
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_helm_timeout" {
  description = "Timeout in seconds for ArgoCD Helm installation"
  type        = number
  default     = 600 # 10 minutes
}

variable "argocd_service_type" {
  description = "ArgoCD server service type"
  type        = string
  default     = "ClusterIP"
}

variable "argocd_dex_enabled" {
  description = "Enable Dex for ArgoCD SSO"
  type        = bool
  default     = false
}

variable "argocd_repo_server_replicas" {
  description = "Number of ArgoCD repo server replicas"
  type        = number
  default     = 1
}

variable "argocd_project" {
  description = "ArgoCD project to use for bootstrap application"
  type        = string
  default     = "default"
}

# -----------------------------------------------------------------------------
# Bootstrap Application Configuration (Optional)
# Set bootstrap_enabled = true to create a bootstrap Application
# -----------------------------------------------------------------------------
variable "bootstrap_enabled" {
  description = "Enable bootstrap ArgoCD Application creation"
  type        = bool
  default     = false
}

variable "bootstrap_app_name" {
  description = "Name of the bootstrap ArgoCD Application"
  type        = string
  default     = "bootstrap"
}

variable "bootstrap_repo_url" {
  description = "Git repository URL for ArgoCD to sync from"
  type        = string
  default     = ""
}

variable "bootstrap_sync_path" {
  description = "Path in the Git repository to sync applications from"
  type        = string
  default     = "argocd"
}

variable "bootstrap_target_revision" {
  description = "Git branch, tag, or commit SHA"
  type        = string
  default     = "main"
}

variable "bootstrap_auto_prune" {
  description = "Enable automatic pruning of resources"
  type        = bool
  default     = true
}

variable "bootstrap_self_heal" {
  description = "Enable automatic self-healing"
  type        = bool
  default     = true
}
