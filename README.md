# terraform-azurerm-extension-gh-repo

Extension to connect an Azure Spoke deployment to a GitHub repository with OIDC federated identity credentials.

## Overview

This Terraform module creates:
- A GitHub repository with sensible default settings
- Azure AD federated identity credentials for OIDC authentication
- GitHub Actions secrets for Azure authentication

## Features

- **OIDC Authentication**: Sets up federated identity credentials for both main branch and environment-specific deployments
- **Simple Configuration**: Minimal JSON configuration required
- **Azure Integration**: Automatically configures GitHub secrets for Azure authentication
- **Extensible**: Ready for future enhancements

## Usage

## Configuration

### Common Configuration (common.tf) - Optional

You can optionally configure organization-wide defaults in `common.tf.sample`:

```hcl
locals {
  ghinfo = {
    OrganizationName = "your-github-org"
    OidcIssuer = "https://token.actions.githubusercontent.com"  # For GH Enterprise: "https://github.your-enterprise.com/_services/token"
  }
}
```

When these are defined, you can omit `organization` and `oidc_issuer` from your JSON configuration.

### In your spoke deployment configuration file (JSON)

**Simple configuration** (uses defaults from common.tf):

```json
{
  "extensions": {
    "github": {
      "enabled": true,
      "repository_name": "my-repo",
      "environments": ["dev", "test", "prod"]
    }
  }
}
```

**Simple configuration:**

```json
{
  "extensions": {
    "github": {
      "enabled": true,
      "organization": "your-github-org",
      "repository_name": "my-repo"
    }
  }
}
```

**With optional overrides:**

```json
{
  "extensions": {
    "github": {
      "enabled": true,
      "organization": "my-custom-org",
      "oidc_issuer": "https://github.your-enterprise.com/_services/token",
      "repository_name": "my-repo",
      "repository_description": "My Azure workload repository",
      "repository_visibility": "private",
      "environments": ["dev", "test", "prod"]
    }
  }
}
```

**Note for GitHub Enterprise**: Set the `oidc_issuer` to your GitHub Enterprise server URL with `/_services/token` path. For GitHub.com, this field can be omitted (defaults to `https://token.actions.githubusercontent.com`).

### In your spoke deployment Terraform

The extension is automatically included via `ext_github.tf` when enabled in the configuration.

### Direct module usage

```hcl
module "github_repo_extension" {
  source = "github.com/xebia/terraform-azurerm-extension-gh-repo//src"

  # Required: Global variables from spoke deployment
  service_principal_client_id = var.service_principal_client_id
  azure_tenant_id             = var.azure_tenant_id
  azure_subscription_id       = var.azure_subscription_id
  
  # Required: GitHub configuration
  github_organization = "your-github-org"
  github_repo_name    = "your-repo-name"
  
  # Optional: Additional configuration
  github_repo_description = "My Azure workload repository"
  github_repo_visibility  = "private"
  github_oidc_issuer      = "https://token.actions.githubusercontent.com"
  environments            = ["dev", "test", "prod"]
}
```

## Configuration Options

### Required Variables

| Variable | Description | Type |
|----------|-------------|------|
| `service_principal_client_id` | The client ID of the spoke's service principal | `string` |
| `azure_tenant_id` | The Azure tenant ID | `string` |
| `azure_subscription_id` | The Azure subscription ID | `string` |
| `github_organization` | The GitHub organization name | `string` |
| `github_repo_name` | The GitHub repository name | `string` |

### Optional Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `github_repo_description` | Repository description | `string` | `"Repository managed by Azure Spoke deployment"` |
| `github_repo_visibility` | Repository visibility (public/private/internal) | `string` | `"private"` |
| `github_repo_auto_init` | Initialize with README | `bool` | `true` |
| `github_oidc_issuer` | GitHub OIDC issuer URL | `string` | `"https://token.actions.githubusercontent.com"` |
| `environments` | List of environment names for federated credentials | `list(string)` | `[]` |

## GitHub Enterprise Configuration

For GitHub Enterprise Server deployments, you need to configure the OIDC issuer URL:

```json
{
  "extensions": {
    "github": {
      "enabled": true,
      "organization": "your-enterprise-org",
      "oidc_issuer": "https://github.your-enterprise.com/_services/token",
      "repository_name": "your-repo-name"
    }
  }
}
```

Or in direct module usage:

```hcl
module "github_repo_extension" {
  source = "github.com/xebia/terraform-azurerm-extension-gh-repo//src"

  github_organization = "your-enterprise-org"
  github_oidc_issuer  = "https://github.your-enterprise.com/_services/token"
  github_repo_name    = "your-repo-name"
  # ... other variables
}
```

**OIDC Issuer URLs:**
- **GitHub.com**: `https://token.actions.githubusercontent.com` (default)
- **GitHub Enterprise Server**: `https://github.your-enterprise.com/_services/token`

## OIDC Configuration

This module creates two types of federated identity credentials:

1. **Main Branch**: For deployments from the main branch
   - Subject: `repo:org/repo:ref:refs/heads/main`

2. **Environments**: For environment-specific deployments (when `environments` are specified)
   - Subject: `repo:org/repo:environment:environment-name` (one credential per environment)

## GitHub Actions Usage

After the module creates your repository, you can use the following in your GitHub Actions workflows:

```yaml
name: Deploy to Azure
on:
  push:
    branches: [main]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Deploy resources
        run: |
          echo "Successfully authenticated to Azure!"
          az account show --output table
```

## Outputs

| Output | Description |
|--------|-------------|
| `repository_name` | The name of the GitHub repository |
| `repository_url` | The URL of the GitHub repository |
| `repository_clone_url` | The clone URL of the repository |
| `federated_credential_main_id` | ID of the main branch federated credential |
| `federated_credential_environment_ids` | IDs of the environment federated credentials | Map of environment names to credential IDs |

## Examples

See the [examples directory](./examples/) for complete usage examples.

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.1, <= 1.10.1 |
| azurerm | ~> 3.116.0 |
| azuread | ~> 2.51.0 |
| github | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| azuread | ~> 2.51.0 |
| github | ~> 6.0 |

## License

Apache 2.0 Licensed. See [LICENSE](./LICENSE) for full details.