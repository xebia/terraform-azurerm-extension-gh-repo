# terraform-azurerm-extension-gh-repo

Extension to connect an Azure Spoke deployment to a GitHub repository with OIDC federated identity credentials.

## Overview

This Terraform module creates:
- A GitHub repository with sensible default settings (optional, can use existing repository)
- A GitHub repository environment for storing environment-specific secrets
- Azure AD federated identity credentials for OIDC authentication to the environment
- GitHub Actions environment secrets for Azure authentication

The module can either create a new repository or work with an existing one by setting the `github_create_repo` variable.

## Features

- **Flexible Repository Management**: Create a new repository or manage environments in existing repositories
- **OIDC Authentication**: Sets up federated identity credentials tied to environment deployments
- **Environment Secrets**: Stores Azure credentials as environment-level secrets for better security isolation
- **Simple Configuration**: Minimal JSON configuration required
- **Azure Integration**: Automatically configures GitHub environment secrets for Azure authentication

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
      "environment_name": "dev"
    }
  }
}
```

**Full configuration:**

```json
{
  "extensions": {
    "github": {
      "enabled": true,
      "organization": "your-github-org",
      "repository": "my-repo",
      "environment_name": "prod",
      "repository_description": "My Azure workload repository",
      "repository_visibility": "private"
    }
  }
}
```

**Using an existing repository:**

```json
{
  "extensions": {
    "github": {
      "enabled": true,
      "repository": "existing-repo",
      "environment_name": "prod",
      "create_repository": false
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
  github_organization     = "your-github-org"
  github_repo_name        = "your-repo-name"
  github_environment_name = "prod"

  # Optional: Additional configuration
  github_create_repo      = true  # Set to false to use existing repository
| Variable | Description | Type |
|----------|-------------|------|
| `service_principal_client_id` | The client ID of the spoke's service principal | `string` |
| `azure_tenant_id` | The Azure tenant ID | `string` |
| `azure_subscription_id` | The Azure subscription ID | `string` |
| `github_organization` | The GitHub organization name | `string` |
| `github_repo_name` | The GitHub repository name | `string` |
| `github_environment_name` | The GitHub repository environment name (e.g., 'dev', 'prod') | `string` |

### Optional Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `github_create_repo` | Whether to create the repository (true) or use existing (false) | `bool` | `true` |
| `github_repo_description` | Repository description | `string` | `"Repository managed by Azure Spoke deployment"` |
| `github_repo_visibility` | Repository visibility (public/private/internal) | `string` | `"private"` |
| `github_repo_auto_init` | Initialize with README | `bool` | `true` |
| `github_oidc_issuer` | GitHub OIDC issuer URL | `string` | `"https://token.actions.githubusercontent.com"` |

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

This module creates a federated identity credential tied to the GitHub environment:

- **Environment**: For environment-specific deployments
  - Subject: `repo:org/repo:environment:environment-name`

## GitHub Actions Usage

After the module creates your repository and environment, you can use the following in your GitHub Actions workflows:

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
    environment: prod
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
| `github_environment_name` | The name of the GitHub environment |
| `federated_credential_environment_id` | ID of the environment federated credential |

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