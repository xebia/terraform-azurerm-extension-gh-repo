# GitHub repository configuration variables
variable "organization" {
  description = "The GitHub organization name where the repository will be created."
  type        = string
}

variable "oidc_issuer" {
  description = "The GitHub OIDC issuer URL. For GitHub.com use 'https://token.actions.githubusercontent.com', for GitHub Enterprise use your enterprise URL."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "repo_name" {
  description = "The name of the GitHub repository to create."
  type        = string
}

variable "repo_description" {
  description = "A description of the repository."
  type        = string
  default     = "Repository managed by Azure Spoke deployment"
}

variable "repo_visibility" {
  description = "The visibility of the repository. Can be 'public', 'private', or 'internal'."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.repo_visibility)
    error_message = "Repository visibility must be 'public', 'private', or 'internal'."
  }
}

variable "repo_auto_init" {
  description = "Whether to initialize the repository with a README file."
  type        = bool
  default     = true
}

variable "environment_name" {
  description = "The name of the GitHub repository environment (e.g., 'dev', 'prod'). This environment will be created in the repository for storing environment-specific secrets and configuring OIDC."
  type        = string
}

variable "create_repo" {
  description = "Whether to create a new GitHub repository. Set to false if the repository already exists and you only want to manage the environment and secrets."
  type        = bool
  default     = true
}
