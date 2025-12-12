# Get the existing Azure AD application (service principal) from the spoke
data "azuread_application" "spoke_app" {
  client_id = var.service_principal_client_id
}

# Create GitHub repository only if configured to create
resource "github_repository" "spoke_repo" {
  count = var.create_repo ? 1 : 0

  name        = var.repo_name
  description = var.repo_description
  visibility  = var.repo_visibility
  auto_init   = var.repo_auto_init

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

# Reference either the newly created repository or the existing one
locals {
  github_repo = var.create_repo ? github_repository.spoke_repo[0] : var.repo_name
}

# Create GitHub repository environment
resource "github_repository_environment" "spoke_environment" {
  environment = var.environment_name
  repository  = local.github_repo.name
}

# Create federated identity credential for environment-specific deployments
resource "azuread_application_federated_identity_credential" "spoke_github_environment" {
  application_id = data.azuread_application.spoke_app.id
  display_name   = "${local.github_repo.name}-${github_repository_environment.spoke_environment.environment}-federated-credential"
  description    = "Federated identity credential for ${local.github_repo.name} ${github_repository_environment.spoke_environment.environment} environment"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.oidc_issuer
  subject        = "repo:${var.organization}/${local.github_repo.name}:environment:${github_repository_environment.spoke_environment.environment}"
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
