# Get the existing Azure AD application (service principal) from the spoke
data "azuread_application" "spoke_app" {
  client_id = var.service_principal_client_id
}

# Check if the GitHub repository already exists (only used as fallback when resource not in state)
data "github_repository" "existing_repo" {
  count     = var.github_create_repo ? 0 : 1
  full_name = "${var.github_organization}/${var.github_repo_name}"
}

# Create GitHub repository only if configured to create
resource "github_repository" "spoke_repo" {
  count = var.github_create_repo ? 1 : 0

  name        = var.github_repo_name
  description = var.github_repo_description
  visibility  = var.github_repo_visibility
  auto_init   = var.github_repo_auto_init

  # Basic repository settings
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true

  # Archive settings
  archived           = false
  archive_on_destroy = true

  # Topics/tags for the repository
  topics = ["azure", "terraform", "spoke-deployment"]
}

# Handle migration from non-count to count resource
moved {
  from = github_repository.spoke_repo
  to   = github_repository.spoke_repo[0]
}

# Reference either the newly created repository or the existing one
locals {
  github_repo = var.github_create_repo ? github_repository.spoke_repo[0] : data.github_repository.existing_repo[0]
}

# Create GitHub repository environment
resource "github_repository_environment" "spoke_environment" {
  environment = var.github_environment_name
  repository  = local.github_repo.name
}

# Create federated identity credential for environment-specific deployments
resource "azuread_application_federated_identity_credential" "spoke_github_environment" {
  application_id = data.azuread_application.spoke_app.id
  display_name   = "${var.github_repo_name}-${var.github_environment_name}-federated-credential"
  description    = "Federated identity credential for ${var.github_repo_name} ${var.github_environment_name} environment"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.github_oidc_issuer
  subject        = "repo:${var.github_organization}/${var.github_repo_name}:environment:${var.github_environment_name}"
}

# Create GitHub environment secrets for Azure authentication
resource "github_actions_environment_secret" "azure_client_id" {
  environment     = github_repository_environment.spoke_environment.environment
  repository      = local.github_repo.name
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = var.service_principal_client_id
}

resource "github_actions_environment_secret" "azure_tenant_id" {
  environment     = github_repository_environment.spoke_environment.environment
  repository      = local.github_repo.name
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = var.azure_tenant_id
}

resource "github_actions_environment_secret" "azure_subscription_id" {
  environment     = github_repository_environment.spoke_environment.environment
  repository      = local.github_repo.name
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = var.azure_subscription_id
}
