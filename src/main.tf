# Get the existing Azure AD application (service principal) from the spoke
data "azuread_application" "spoke_app" {
  client_id = var.service_principal_client_id
}

# Create GitHub repository
resource "github_repository" "spoke_repo" {
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

# Create federated identity credential for main branch
resource "azuread_application_federated_identity_credential" "spoke_github_main" {
  application_id = data.azuread_application.spoke_app.id
  display_name   = "${var.github_repo_name}-main-federated-credential"
  description    = "Federated identity credential for ${var.github_repo_name} main branch"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.github_oidc_issuer
  subject        = "repo:${var.github_organization}/${var.github_repo_name}:ref:refs/heads/main"
}

# Create federated identity credential for environment-specific deployments
resource "azuread_application_federated_identity_credential" "spoke_github_environment" {
  for_each = toset(var.environments)

  application_id = data.azuread_application.spoke_app.id
  display_name   = "${var.github_repo_name}-${each.key}-federated-credential"
  description    = "Federated identity credential for ${var.github_repo_name} ${each.key} environment"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.github_oidc_issuer
  subject        = "repo:${var.github_organization}/${var.github_repo_name}:environment:${each.key}"
}

# Create GitHub repository secrets for Azure authentication
resource "github_actions_secret" "azure_client_id" {
  repository      = github_repository.spoke_repo.name
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = var.service_principal_client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  repository      = github_repository.spoke_repo.name
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = var.azure_tenant_id
}

resource "github_actions_secret" "azure_subscription_id" {
  repository      = github_repository.spoke_repo.name
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = var.azure_subscription_id
}