# Example usage of the GitHub repository extension
# This demonstrates how to create a GitHub repository with OIDC federated credentials

# Create example Azure AD resources (normally these would come from your spoke deployment)
resource "azuread_application" "example" {
  display_name = "example-spoke-app"
}

resource "azuread_service_principal" "example" {
  client_id = azuread_application.example.client_id
}

# Get current Azure context
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Use the GitHub repository extension
module "github_repo_extension" {
  source = "../../src"

  # Global variables that would come from spoke deployment
  service_principal_client_id = azuread_application.example.client_id
  azure_tenant_id             = data.azurerm_client_config.current.tenant_id
  azure_subscription_id       = data.azurerm_subscription.current.subscription_id
  environments                = ["dev", "test", "prod"]

  # GitHub repository configuration
  github_organization      = "xebia"  # Change this to your organization
  github_oidc_issuer        = "https://token.actions.githubusercontent.com"  # For GitHub Enterprise: "https://github.your-enterprise.com/_services/token"
  github_repo_name         = "example-spoke-repo"
  github_repo_description  = "Example repository for Azure Spoke deployment"
  github_repo_visibility   = "private"
  github_repo_auto_init    = true
}