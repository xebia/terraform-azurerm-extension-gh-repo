# GitHub repository configuration variables
variable "github_organization" {
  description = "The GitHub organization name where the repository will be created."
  type        = string
}

variable "github_oidc_issuer" {
  description = "The GitHub OIDC issuer URL. For GitHub.com use 'https://token.actions.githubusercontent.com', for GitHub Enterprise use your enterprise URL."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "github_repo_name" {
  description = "The name of the GitHub repository to create."
  type        = string
}

variable "github_repo_description" {
  description = "A description of the repository."
  type        = string
  default     = "Repository managed by Azure Spoke deployment"
}

variable "github_repo_visibility" {
  description = "The visibility of the repository. Can be 'public', 'private', or 'internal'."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.github_repo_visibility)
    error_message = "Repository visibility must be 'public', 'private', or 'internal'."
  }
}

variable "github_repo_auto_init" {
  description = "Whether to initialize the repository with a README file."
  type        = bool
  default     = true
}